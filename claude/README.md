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
├── README.md         # You are here
├── install.sh        # Symlinks files into place
├── claude-sandbox    # Launcher script
├── Dockerfile        # Container definition
└── CLAUDE.md         # Default instructions for Claude in sandbox
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
```

## First Run

On first launch, Claude will prompt you to authenticate in your browser. Credentials are stored in a Docker volume (`claude-auth`) and persist across sessions.

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

### External Services

Plugins connect to official vendor-hosted MCP endpoints. On first use, each service triggers an OAuth flow in your browser — no API tokens to manage.

| Plugin | Service | Auth |
|--------|---------|------|
| `github` | GitHub (PRs, issues, code search) | `GITHUB_PERSONAL_ACCESS_TOKEN` env var |
| `slack` | Slack (messages, channels, search) | OAuth (browser popup on first use) |
| `linear` | Linear (issues, projects) | OAuth (browser popup on first use) |
| `notion` | Notion (pages, databases, docs) | OAuth (browser popup on first use) |

For GitHub, add to `~/.zshrc`:
```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_..."
```

For Slack, Linear, and Notion: just use them — the OAuth flow happens automatically on first use inside the sandbox.

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

| Service | MCP Server | Auth |
|---------|-----------|------|
| OpenAI Codex | `codex-mcp-server` | `codex login` on host |
| Google Gemini | `gemini-mcp` | `gemini auth login` on host |
| Playwright | `@playwright/mcp` | None (sandbox-specific headless config) |
| Google Drive | `@modelcontextprotocol/server-gdrive` | Google OAuth |

Codex/Gemini credentials (`~/.codex/`, `~/.gemini/`) are mounted read-only.

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
docker volume rm claude-auth
```

**Permission denied on project files:**

The container runs as uid 1000. If your Mac user has a different uid, edit the `docker run` command in `claude-sandbox`:

```bash
--user $(id -u):$(id -g)
```

**Container can't access network:**

Network access is enabled by default. If you disabled it and need it back, remove `--network none` from the script.

**Rebuild from scratch:**
```bash
docker rmi claude-sandbox
claude-sandbox --build
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
- GitHub PAT via env var (for GitHub plugin)

For stronger isolation (e.g., if your project needs Docker-in-Docker), consider running inside a Lima VM.

## License

MIT - Do whatever you want with it.
