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

### External Services (Read-Only)

All external service integrations are read-only. Claude can search and read but cannot create, modify, or delete data.

| Plugin | Service | Auth | Enforcement |
|--------|---------|------|-------------|
| `github` | GitHub (PRs, issues, code search) | Read-only fine-grained PAT | API-layer (token scopes) |
| `slack` | Slack (messages, channels, search) | OAuth | Deny list (write tools blocked) |
| `linear` | Linear (issues, projects) | OAuth | Deny list (write tools blocked) |
| `Notion` | Notion (pages, databases, docs) | OAuth | Deny list (write tools blocked) |

**GitHub setup** -- a read-only fine-grained PAT is **required** (not optional):
1. Go to [GitHub Settings > Fine-grained tokens](https://github.com/settings/personal-access-tokens/new)
2. Set **Repository access** to "All repositories" (or select specific repos)
3. Under **Permissions**, grant **read-only** access to:
   - Repository permissions: Contents, Issues, Pull requests, Metadata
   - Do NOT grant any write permissions
4. Add to `~/.zshrc`:
   ```bash
   export GITHUB_PERSONAL_ACCESS_TOKEN="github_pat_..."
   ```

For Slack, Linear, and Notion: just use them -- the OAuth flow happens automatically on first use inside the sandbox. Write operations are blocked by the deny list in `settings.json`.

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
- GitHub PAT via env var (read-only fine-grained PAT for GitHub plugin)
- Google OAuth credentials via env var (read-only scopes for Google Workspace)
- Google Workspace token cache (read-write, for OAuth token persistence)

For stronger isolation (e.g., if your project needs Docker-in-Docker), consider running inside a Lima VM.

## Read-Only Enforcement

External service integrations use defense-in-depth:

1. **Claude Code deny list**: Write tool names are blocked in `settings.json` `permissions.deny`. Claude cannot call these tools even though plugins expose them. (27 tools blocked across Slack, Linear, and Notion.)
2. **API-layer restrictions**: GitHub uses a read-only fine-grained PAT. Google Workspace uses `--read-only` mode which requests only `*.readonly` OAuth scopes.

To apply read-only enforcement to an existing sandbox:
1. Rebuild: `claude-sandbox --build`
2. Delete the plugin setup marker: `rm ~/.claude-sandbox-auth/.plugins-setup-v1`
3. Restart -- plugins will re-install with the fixed Notion name and deny list will be merged

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
   export GOOGLE_OAUTH_CLIENT_ID="your-client-id"
   export GOOGLE_OAUTH_CLIENT_SECRET="your-client-secret"
   ```
7. On first use inside the sandbox, an OAuth consent flow will open in your browser

## License

MIT - Do whatever you want with it.
