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
## MCP Services

Claude in the sandbox connects to external services via [MCP (Model Context Protocol)](https://modelcontextprotocol.io/). All external services are configured for **read-only** access.

### AI Tools

| Service | MCP Server | Auth |
|---------|-----------|------|
| OpenAI Codex | `codex-mcp-server` | `codex login` on host |
| Google Gemini | `gemini-mcp` | `gemini auth login` on host |
| Playwright | `@playwright/mcp` | None (built-in) |

Credentials (`~/.codex/`, `~/.gemini/`) are mounted read-only into the sandbox.

### Token-Based Services (Read-Only)

Set these environment variables on your host. The sandbox passes them through automatically.

| Service | MCP Server | Env Var | Setup |
|---------|-----------|---------|-------|
| Slack | `slack-mcp-server` | `SLACK_MCP_XOXP_TOKEN` | Create a Slack app with read scopes, get user token |
| Notion | `@notionhq/notion-mcp-server` | `NOTION_TOKEN` | Create integration at [notion.so/my-integrations](https://www.notion.so/my-integrations) with "Read content" only |
| GitHub | `github-mcp-server` | `GITHUB_PERSONAL_ACCESS_TOKEN` | Create PAT at [github.com/settings/tokens](https://github.com/settings/tokens). `GITHUB_READ_ONLY` is enforced. |
| Linear | `@tacticlaunch/mcp-linear` | `LINEAR_API_KEY` | Create read-only API key in Linear settings |

Add to your shell profile (`~/.zshrc`):

```bash
export SLACK_MCP_XOXP_TOKEN="xoxp-..."
export NOTION_TOKEN="ntn_..."
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_..."
export LINEAR_API_KEY="lin_api_..."
```

### Google Services (Read-Only, OAuth)

Google Calendar, Gmail, and Google Drive use OAuth credentials mounted from `~/.google-mcp/`.

**One-time setup:**

1. Create a [Google Cloud project](https://console.cloud.google.com) and enable Calendar, Gmail, and Drive APIs
2. Create OAuth 2.0 credentials (Desktop app type) and download the JSON
3. Save to `~/.google-mcp/oauth-credentials.json`
4. Run the auth flow for each service on your host:
   ```bash
   # Calendar
   GOOGLE_OAUTH_CREDENTIALS=~/.google-mcp/oauth-credentials.json \
     npx @cocal/google-calendar-mcp

   # Gmail
   npx @shinzolabs/gmail-mcp auth

   # Drive
   npx @modelcontextprotocol/server-gdrive
   ```
5. Complete the browser OAuth flow for each. Tokens are stored in `~/.google-mcp/`

| Service | MCP Server | Access |
|---------|-----------|--------|
| Google Calendar | `@cocal/google-calendar-mcp` | Read-only (write tools disabled) |
| Gmail | `@shinzolabs/gmail-mcp` | Read-only via OAuth scopes |
| Google Drive | `@modelcontextprotocol/server-gdrive` | Read-only (inherent) |

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
- Google OAuth credentials read-only: `~/.google-mcp/`
- MCP service tokens via env vars (Slack, Notion, GitHub, Linear)

For stronger isolation (e.g., if your project needs Docker-in-Docker), consider running inside a Lima VM.

## License

MIT - Do whatever you want with it.
