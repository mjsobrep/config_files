#!/bin/bash
# network-audit.sh — Verify sandbox network egress filtering
# Runs inside the Docker container to test connectivity from the sandbox's perspective.
# Tests that allowlisted services are reachable and everything else is blocked.

set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Counters
PASS=0
FAIL=0
WARN=0
ERRORS=()

# Test timeout (seconds)
TIMEOUT=5

##############################################################################
# Helpers
##############################################################################

test_https() {
    local label="$1"
    local url="$2"
    local expect_success="$3"  # "allow" or "block"

    local status
    local http_code
    local result

    # Use curl to test HTTPS through the proxy. Capture HTTP code.
    # Do NOT follow redirects (-L): some endpoints (MCP SSE servers) redirect to
    # domains not on the allowlist. A 3xx proves the proxy allowed the CONNECT,
    # which is all we need to verify. Following the redirect would test the
    # redirect target, not the original domain.
    # --connect-timeout for TCP connect, --max-time for total request.
    http_code=$(curl -s -o /dev/null -w '%{http_code}' \
        --connect-timeout "$TIMEOUT" --max-time "$((TIMEOUT * 2))" \
        "$url" 2>/dev/null) || true

    # Any HTTP response (even 3xx/4xx/5xx) means the connection succeeded through
    # the proxy. 000 means curl couldn't connect (proxy blocked it or timeout).
    if [[ "$http_code" != "000" ]]; then
        status="reachable"
    else
        status="blocked"
    fi

    if [[ "$expect_success" == "allow" ]]; then
        if [[ "$status" == "reachable" ]]; then
            result="${GREEN}PASS${NC}"
            ((PASS++))
        else
            result="${RED}FAIL${NC} (expected reachable, got blocked)"
            ((FAIL++))
            ERRORS+=("ALLOW $label ($url) — blocked but should be reachable")
        fi
    else
        if [[ "$status" == "blocked" ]]; then
            result="${GREEN}PASS${NC}"
            ((PASS++))
        else
            result="${RED}FAIL${NC} (expected blocked, got HTTP $http_code)"
            ((FAIL++))
            ERRORS+=("BLOCK $label ($url) — reachable but should be blocked")
        fi
    fi

    printf "  %-42s %-8s %b\n" "$label" "($http_code)" "$result"
}

test_dns() {
    local label="$1"
    local domain="$2"
    local expect_success="$3"

    local result
    if getent hosts "$domain" >/dev/null 2>&1; then
        if [[ "$expect_success" == "allow" ]]; then
            result="${GREEN}PASS${NC}"
            ((PASS++))
        else
            result="${YELLOW}WARN${NC} (DNS resolved but may still be blocked by proxy)"
            ((WARN++))
        fi
    else
        if [[ "$expect_success" == "block" ]]; then
            result="${GREEN}PASS${NC}"
            ((PASS++))
        else
            result="${RED}FAIL${NC} (DNS resolution failed)"
            ((FAIL++))
            ERRORS+=("DNS $label ($domain) — resolution failed")
        fi
    fi

    printf "  %-42s          %b\n" "$label" "$result"
}

test_raw_tcp() {
    local label="$1"
    local host="$2"
    local port="$3"
    local expect_success="$4"

    local result
    if timeout "$TIMEOUT" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        if [[ "$expect_success" == "allow" ]]; then
            result="${GREEN}PASS${NC}"
            ((PASS++))
        else
            result="${RED}FAIL${NC} (raw TCP connected — proxy bypass!)"
            ((FAIL++))
            ERRORS+=("RAW TCP $label ($host:$port) — connected but should be blocked")
        fi
    else
        if [[ "$expect_success" == "block" ]]; then
            result="${GREEN}PASS${NC}"
            ((PASS++))
        else
            result="${RED}FAIL${NC} (could not connect)"
            ((FAIL++))
            ERRORS+=("RAW TCP $label ($host:$port) — blocked but should be reachable")
        fi
    fi

    printf "  %-42s :%s      %b\n" "$label" "$port" "$result"
}

section() {
    echo ""
    echo -e "${BOLD}${CYAN}$1${NC}"
    echo -e "${DIM}$(printf '%.0s─' {1..60})${NC}"
}

##############################################################################
# Header
##############################################################################

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║          Claude Sandbox Network Audit                   ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${DIM}Testing from inside the sandbox container.${NC}"
echo -e "${DIM}Timeout: ${TIMEOUT}s per test. $(date -Iseconds)${NC}"

# Check proxy configuration
echo ""
if [[ -n "${https_proxy:-}" ]]; then
    echo -e "  Proxy: ${GREEN}${https_proxy}${NC}"
else
    echo -e "  Proxy: ${RED}NOT SET${NC} (egress filtering may be disabled)"
fi

##############################################################################
# Tests: Allowed domains (should be reachable)
##############################################################################

section "Anthropic / Claude Services (should be reachable)"
test_https "claude.ai"                    "https://claude.ai"                 allow
test_https "api.anthropic.com"            "https://api.anthropic.com"         allow

section "MCP Plugin Endpoints (should be reachable)"
test_https "mcp.slack.com"                "https://mcp.slack.com"             allow
test_https "mcp.linear.app"              "https://mcp.linear.app"            allow
test_https "api.notion.com"              "https://api.notion.com"            allow

section "GitHub (should be reachable)"
test_https "api.github.com"              "https://api.github.com"            allow
test_https "github.com"                  "https://github.com"                allow
test_https "cli.github.com"             "https://cli.github.com"            allow
test_https "raw.githubusercontent.com"   "https://raw.githubusercontent.com" allow

section "Google Workspace (should be reachable)"
test_https "googleapis.com"              "https://www.googleapis.com"        allow
test_https "accounts.google.com"         "https://accounts.google.com"       allow

section "Package Registries (should be reachable)"
test_https "registry.npmjs.org"          "https://registry.npmjs.org"        allow
test_https "pypi.org"                    "https://pypi.org"                  allow
test_https "crates.io"                   "https://crates.io"                 allow
test_https "static.rust-lang.org"        "https://static.rust-lang.org"      allow

section "Other Allowed Services (should be reachable)"
test_https "api.openai.com"              "https://api.openai.com"            allow
test_https "context7.com"               "https://context7.com"              allow

##############################################################################
# Tests: Blocked domains (should NOT be reachable)
##############################################################################

section "General Internet (should be BLOCKED)"
test_https "google.com"                  "https://www.google.com"            block
test_https "example.com"                 "https://example.com"               block
test_https "amazon.com"                  "https://www.amazon.com"            block
test_https "twitter.com/x.com"          "https://x.com"                     block
test_https "reddit.com"                  "https://www.reddit.com"            block
test_https "stackoverflow.com"           "https://stackoverflow.com"         block
test_https "pastebin.com"               "https://pastebin.com"              block

section "Cloud Providers (should be BLOCKED)"
test_https "aws.amazon.com"              "https://aws.amazon.com"            block
test_https "azure.microsoft.com"         "https://azure.microsoft.com"       block
test_https "cloud.google.com"            "https://cloud.google.com"          block

section "Data Exfiltration Targets (should be BLOCKED)"
test_https "webhook.site"                "https://webhook.site"              block
test_https "requestbin.net"              "https://requestbin.net"            block
test_https "ngrok.io"                    "https://ngrok.io"                  block
test_https "pipedream.net"               "https://pipedream.net"             block

##############################################################################
# Tests: Raw TCP bypass attempts (should all fail on --internal network)
##############################################################################

section "Raw TCP Bypass (should be BLOCKED)"
test_raw_tcp "Direct to github.com"       "github.com"       443  block
test_raw_tcp "Direct to google.com"       "google.com"       443  block
test_raw_tcp "Direct to 8.8.8.8 (DNS)"   "8.8.8.8"          53   block

##############################################################################
# Tests: DNS resolution
# On the --internal Docker network, external DNS resolution is disabled by
# design. The proxy resolves external domains on behalf of the container.
# Only container-name resolution (Docker embedded DNS) works.
##############################################################################

section "DNS Resolution (internal network)"
test_dns "proxy container name"            "claude-sandbox-proxy"  allow
test_dns "external domain (expect fail)"   "github.com"            block
test_dns "blocked domain (expect fail)"    "google.com"            block

##############################################################################
# Summary
##############################################################################

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"

TOTAL=$((PASS + FAIL + WARN))
echo -e "${BOLD}║  Results: ${GREEN}${PASS} passed${NC}${BOLD} / ${RED}${FAIL} failed${NC}${BOLD} / ${YELLOW}${WARN} warnings${NC}${BOLD}  (${TOTAL} total)  ║${NC}"

if [[ $FAIL -eq 0 ]]; then
    echo -e "${BOLD}║  ${GREEN}All tests passed — egress filtering is working correctly${NC}${BOLD}  ║${NC}"
else
    echo -e "${BOLD}║  ${RED}Some tests failed — review errors below${NC}${BOLD}                  ║${NC}"
fi

echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"

if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}${BOLD}Errors:${NC}"
    for err in "${ERRORS[@]}"; do
        echo -e "  ${RED}• $err${NC}"
    done
fi

echo ""
exit "$FAIL"
