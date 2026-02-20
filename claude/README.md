# Claude Sandbox

Run [Claude Code](https://docs.anthropic.com/en/docs/claude-code) in a sandboxed Docker container. Your code is accessible, but your SSH keys, git credentials, and filesystem are not.

## Why?

AI coding tools can execute arbitrary commands. This setup ensures:

- ✅ AI can read/write your project files
- ✅ AI can run builds, tests, dev servers
- ✅ Claude credentials persist across sessions
- ❌ AI cannot access your SSH keys
- ❌ AI cannot access git credentials / push to GitHub
- ❌ AI cannot read files outside the project
- ❌ AI cannot access cloud credentials (AWS, GCP, etc.)

## Files

```
claude-sandbox/
├── README.md           # You are here
├── install.sh          # Symlinks files into place
├── claude-sandbox      # Launcher script
├── Dockerfile          # Container definition (sandbox)
├── Dockerfile.proxy    # Container definition (egress filter proxy)
├── squid.conf          # Squid proxy configuration
├── allowlist.txt       # Domain allowlist for egress filtering
├── network-audit.sh    # Network egress filter verification script
└── CLAUDE.md           # Default instructions for Claude in sandbox
```

## Install

```bash
# Clone your dotfiles, then:
./install.sh

# Build the Docker image (first time only, ~2 min)
claude-sandbox --build
```

If `~/.local/bin` isn't in your PATH, add to `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

```bash
# Start Claude in current directory
cd ~/projects/my-app
claude-sandbox

# Start with an initial prompt
claude-sandbox "explain this codebase"

# Get a shell instead of Claude
claude-sandbox --shell

# Rebuild after Dockerfile changes
claude-sandbox --build

# Disable egress filtering (for debugging network issues)
claude-sandbox --no-egress-filter

# Clean up proxy container and internal network
claude-sandbox --cleanup
```

## First Run

On first launch, Claude will prompt you to authenticate in your browser. Credentials are stored in `~/.claude-sandbox-auth` and persist across sessions.

## What's Installed

| Tool | Version |
|------|---------|
| Node.js | 20.x LTS |
| Yarn | Latest (via corepack) |
| Rust | Stable |
| Python | 3.x |
| pipenv | Latest |
| Git | Latest |
| ripgrep, fd, jq | Latest |
| OpenAI Codex CLI | Latest |
| Google Gemini CLI | Latest |
| TypeScript LSP | Latest |
| Pyright (Python LSP) | Latest |
| rust-analyzer | Latest |

## Plugins (Auto-Installed)

On first launch, the sandbox installs official plugins from the [Anthropic marketplace](https://github.com/anthropics/claude-plugins-official). These provide integrations, code intelligence, and development workflows.

### External Services (Read-Only)

All external service integrations are read-only. Claude can search and read but cannot create, modify, or delete data.

| Integration | Service | Auth | Enforcement |
|-------------|---------|------|-------------|
| `gh` CLI | GitHub (PRs, issues, code search) | Read-only fine-grained PAT | API-layer (token scopes) |
| `slack` plugin | Slack (messages, channels, search) | OAuth | Deny list (4 write tools blocked) |
| `linear` plugin | Linear (issues, projects) | OAuth | Deny list (16 write tools blocked) |
| `Notion` plugin | Notion (pages, databases, docs) | OAuth | Deny list (7 write tools blocked) |
| `fireflies` plugin | Fireflies (meeting transcripts) | OAuth | Read-only (no write tools) |

**GitHub setup** -- a read-only fine-grained PAT is **required** (not optional):
1. Go to [GitHub Settings > Fine-grained tokens](https://github.com/settings/personal-access-tokens/new)
2. Set **Repository access** to "All repositories" (or select specific repos)
3. Under **Permissions**, grant **read-only** access to:
   - Repository permissions: Contents, Issues, Pull requests, Metadata
   - Do NOT grant any write permissions
4. Add to `~/.zshrc`:
   ```bash
   export CLAUDE_SANDBOX_GITHUB_PAT="github_pat_..."
   ```
   Note: The sandbox reads `CLAUDE_SANDBOX_GITHUB_PAT` (not `GITHUB_PERSONAL_ACCESS_TOKEN`) to avoid accidentally passing a broad-access token from other tools.

For Slack, Linear, and Notion: run `claude-sandbox --auth` first to complete the OAuth flow on your host (Docker can't open a browser). After initial auth, tokens persist and work in all future sandbox sessions. Write operations are blocked by the deny list in `settings.json`.

### Code Intelligence (LSP)

Real-time type checking and error detection on every file edit. These require no auth — they use the language server binaries pre-installed in the image.

| Plugin | Language | What It Does |
|--------|----------|-------------|
| `typescript-lsp` | TypeScript/JavaScript | Type errors, missing imports, syntax issues |
| `pyright-lsp` | Python | Type checking, undefined variables, wrong args |
| `rust-analyzer-lsp` | Rust | Borrow checker, type errors, unused code |

### Development Workflows

| Plugin | What It Does |
|--------|-------------|
| `code-review` | Multi-agent automated code review with confidence scoring |
| `security-guidance` | Scans edits for vulnerabilities (XSS, injection, unsafe patterns) |
| `commit-commands` | Git commit, push, and PR creation workflows |
| `context7` | Live library documentation lookup |

### MCP Servers (Non-Plugin)

These remain as MCP server configs (no official plugin available):

| Service | MCP Server | Auth | Mode |
|---------|-----------|------|------|
| OpenAI Codex | `codex-mcp-server` | `codex login` on host | N/A |
| Google Gemini | `gemini-mcp` | `gemini auth login` on host | N/A |
| Playwright | `@playwright/mcp` | None (sandbox-specific headless config) | N/A |
| Google Workspace | `workspace-mcp` | Google OAuth (read-only scopes) | `--read-only` flag |
| Pylon | `pylon-mcp` | API token | Deny list (write tools blocked) |

Codex/Gemini credentials (`~/.codex/`, `~/.gemini/`) are mounted read-only.

**Pylon setup** (customer support platform, read-only):
1. Get your API token from your Pylon account settings
2. Add to `~/.zshrc`:
   ```bash
   export CLAUDE_SANDBOX_PYLON_API_TOKEN="your-pylon-api-token"
   ```
3. Write operations are blocked by the deny list (17 write tools blocked)

## Customizing

Edit the `Dockerfile` and rebuild:

```bash
# Example: add Go
# Add to Dockerfile:
#   RUN wget -q https://go.dev/dl/go1.22.0.linux-amd64.tar.gz \
#       && tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz \
#       && rm go1.22.0.linux-amd64.tar.gz
#   ENV PATH="/usr/local/go/bin:$PATH"

claude-sandbox --build
```

## Resource Limits

The container runs with:
- 8GB memory limit
- 4 CPU cores

Edit `claude-sandbox` script to adjust.

## Troubleshooting

**Reset Claude authentication:**
```bash
rm -rf ~/.claude-sandbox-auth
```

**Permission denied on project files:**

The container runs as your current user (via `--user $(id -u):$(id -g)`). If files inside the container have wrong ownership, ensure your host uid matches the container uid.

**Container can't access network:**

Network egress is filtered by default through a proxy allowlist. If a domain you need is blocked, see [Network Egress Filtering](#network-egress-filtering) for how to add custom domains. For unrestricted access, use `--no-egress-filter`.

**Rebuild from scratch:**
```bash
docker rmi claude-sandbox
claude-sandbox --build
```

**A tool or command fails with a connection error (egress filter):**

The domain may not be on the allowlist. Check the proxy logs:
```bash
# Show denied requests
docker logs claude-sandbox-proxy 2>&1 | grep "TCP_DENIED"

# Follow logs in real-time while reproducing the issue
docker logs -f claude-sandbox-proxy
```

Add the missing domain to `~/.config/claude-sandbox/allowlist.txt`, then reload squid:
```bash
docker exec claude-sandbox-proxy squid -k reconfigure
```

If you baked the allowlist into the image instead of volume-mounting, rebuild:
```bash
docker rm -f claude-sandbox-proxy && docker rmi claude-sandbox-proxy
```

**Proxy won't start or image build fails:**
```bash
# Check proxy container logs
docker logs claude-sandbox-proxy

# Full cleanup and retry
claude-sandbox --cleanup
claude-sandbox --build
```

## Network Egress Filtering

All outbound network traffic from the sandbox is filtered through a squid proxy that enforces a domain allowlist. The sandbox container runs on a Docker internal network with no direct internet access -- all HTTP/HTTPS must pass through the proxy.

**Architecture:**
- The sandbox container sits on an isolated Docker network (`claude-sandbox-net`, `--internal`)
- A squid proxy container (`claude-sandbox-proxy`) bridges the internal and default networks
- Only HTTP/HTTPS to domains in `allowlist.txt` is permitted; everything else is denied
- Raw TCP, UDP, DNS, and ICMP from the sandbox are blocked at the network level

**Allowlisted domains** (see `allowlist.txt` for full list):
- Anthropic API (`.anthropic.com`, `.claude.ai`)
- MCP plugin endpoints (`mcp.slack.com`, `mcp.linear.app`, `api.notion.com`)
- GitHub (`api.github.com`, `github.com`)
- Google Workspace APIs (`.googleapis.com`, `accounts.google.com`)
- Pylon (`api.usepylon.com`)
- Package registries (`registry.npmjs.org`, `pypi.org`, `crates.io`)

**Node.js proxy support:** The `global-agent` npm package is pre-installed and loaded via `NODE_OPTIONS`. This patches Node.js `http`/`https` to respect proxy environment variables, ensuring all Node.js processes (Claude Code, MCP servers, user scripts) route through the proxy. Note: `global-agent` is a usability feature, not the security boundary. The Docker `--internal` network is the real enforcement -- even without `global-agent`, the sandbox cannot reach the internet.

**Playwright browser isolation:** When egress filtering is active, the Chromium browser launched by Playwright MCP cannot access the internet. Playwright is primarily useful for testing local dev servers (`localhost`) in this mode. For web browsing, use the WebFetch tool (which routes through the Anthropic API) or disable egress filtering.

**Trust boundary:** Every domain on the allowlist can see all HTTPS traffic sent to it (they terminate TLS). For first-party and major-vendor domains (Anthropic, Google, GitHub, Slack, Linear, Notion, Pylon) this is expected. Third-party domains (context7.com, fireflies.ai) have a weaker trust boundary. If this is a concern, remove them from `allowlist.txt`.

### Adding Custom Domains

If your project needs to reach an API not on the allowlist:

1. Edit `~/.config/claude-sandbox/allowlist.txt` (or the source file in your dotfiles)
2. Add the domain (one per line; prefix with `.` for subdomain matching)
3. Reload squid to pick up the change (the allowlist is volume-mounted):
   ```bash
   docker exec claude-sandbox-proxy squid -k reconfigure
   ```
   If the proxy was started before the allowlist file existed, rebuild instead:
   ```bash
   docker rm -f claude-sandbox-proxy && docker rmi claude-sandbox-proxy
   ```

### Disabling Egress Filtering

For debugging, you can disable egress filtering entirely:

```bash
claude-sandbox --no-egress-filter
```

This gives the sandbox unrestricted internet access (same as before egress filtering was added).

### Proxy Lifecycle

The proxy container (`claude-sandbox-proxy`) stays running between sandbox sessions to avoid startup latency. Multiple concurrent sandbox sessions share the same proxy. To clean up:

```bash
claude-sandbox --cleanup
```

### Proxy Logs

```bash
# View all proxy logs
docker logs claude-sandbox-proxy

# Follow logs in real-time
docker logs -f claude-sandbox-proxy

# View only denied requests (useful for debugging allowlist)
docker logs claude-sandbox-proxy 2>&1 | grep "TCP_DENIED"
```

## Security Notes

This setup relies on Docker's container isolation. On macOS, Docker Desktop runs containers inside a Linux VM, providing an additional layer of separation from your host.

**Not mounted (safe):**
- `~/.ssh`
- `~/.git-credentials`
- `~/.aws`, `~/.kube`, `~/.config/gcloud`
- Docker socket

**Mounted (accessible to AI):**
- Current working directory only
- Claude auth (separate directory)
- AI tool credentials read-only: `~/.codex/`, `~/.gemini/`
- GitHub PAT via env var (read-only fine-grained PAT, from `CLAUDE_SANDBOX_GITHUB_PAT`)
- Google OAuth credentials via env var (read-only scopes, from `CLAUDE_SANDBOX_GOOGLE_*`)
- Google Workspace token cache (read-write, for OAuth token persistence)
- Pylon API token via env var (write tools blocked by deny list, from `CLAUDE_SANDBOX_PYLON_API_TOKEN`)

For stronger isolation (e.g., if your project needs Docker-in-Docker), consider running inside a Lima VM.

## Read-Only Enforcement

External service integrations use defense-in-depth:

1. **Claude Code deny list**: Write tool names are blocked in `settings.json` `permissions.deny`. Claude cannot call these tools even though plugins expose them. (44 tools blocked across Slack, Linear, Notion, and Pylon.)
2. **API-layer restrictions**: GitHub uses a read-only fine-grained PAT. Google Workspace uses `--read-only` mode which requests only `*.readonly` OAuth scopes.

To apply read-only enforcement to an existing sandbox:
1. Rebuild: `claude-sandbox --build`
2. Delete the plugin setup marker: `rm ~/.claude-sandbox-auth/.plugins-setup-v3`
3. Restart -- plugins will re-install and deny list will be merged

### Google Workspace Setup

Google Workspace integration provides read-only access to Gmail, Drive, Calendar, and Docs.

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create or select a project
3. Enable APIs: Gmail API, Google Drive API, Google Calendar API, Google Docs API
4. **Configure OAuth consent screen**:
   - Add scopes: select ONLY the `*.readonly` variants (`gmail.readonly`, `drive.readonly`, `calendar.readonly`, `documents.readonly`)
   - Do NOT add any write scopes -- this is server-side enforcement that prevents the OAuth client from ever requesting write access, regardless of the `--read-only` flag
5. Create OAuth 2.0 credentials (Desktop application type)
6. Add to `~/.zshrc`:
   ```bash
   export CLAUDE_SANDBOX_GOOGLE_CLIENT_ID="your-client-id"
   export CLAUDE_SANDBOX_GOOGLE_CLIENT_SECRET="your-client-secret"
   ```
7. On first use inside the sandbox, an OAuth consent flow will open in your browser

## License

MIT - Do whatever you want with it.
