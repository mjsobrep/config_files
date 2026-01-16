# Dockerfile.claude-sandbox
FROM ubuntu:24.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    gnupg \
    ripgrep \
    fd-find \
    jq \
    unzip \
    vim \
    less \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN corepack enable && corepack prepare yarn@stable --activate

# Install Rust (system-wide, accessible to all users)
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --no-modify-path --default-toolchain stable

# Install Python + pipenv
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && pip3 install --break-system-packages pipenv

# Install MCAP CLI (robotics recording format tools)
# Note: Only amd64 binary available; on ARM this step will fail and can be removed
RUN curl -fsSL "https://github.com/foxglove/mcap/releases/download/releases%2Fmcap-cli%2Fv0.0.59/mcap-linux-amd64" -o /usr/local/bin/mcap \
    && chmod +x /usr/local/bin/mcap

# Install Claude Code (installs to /root/.local/bin as root)
RUN curl -fsSL https://claude.ai/install.sh | bash

# Claude is installed at /root/.local/bin; also add $HOME/.local/bin to silence doctor warnings
ENV PATH="/home/sandbox/.local/bin:/root/.local/bin:$PATH"

# Create a home directory that will be used at runtime
# The actual UID will be set via --user at runtime, but we need the directory to exist
RUN mkdir -p /home/sandbox && chmod 777 /home/sandbox

# Stable machine-id so Claude auth persists across container runs
RUN echo "claude-sandbox-stable-machine-id" > /etc/machine-id

ENV HOME=/home/sandbox

WORKDIR /workspace

# Git config (global config will be in /home/sandbox at runtime)
RUN git config --system init.defaultBranch main \
    && git config --system --add safe.directory /workspace

# Block dangerous git commands - user should review all changes on host
# Move original to /usr/libexec (never in PATH) to avoid git-* subcommand discovery
RUN mkdir -p /usr/libexec/sandbox \
    && mv /usr/bin/git /usr/libexec/sandbox/git \
    && printf '#!/bin/bash\ncase "$1" in\n  commit) echo "git commit is disabled in sandbox - use: git-draft-commit \"your message\""; exit 1;;\n  push|stash|reset|clean|rebase) echo "git $1 is disabled in sandbox - review and manage on host"; exit 1;;\n  *) exec /usr/libexec/sandbox/git "$@";;\nesac\n' > /usr/bin/git \
    && chmod +x /usr/bin/git

# Draft commit helper - stages are preserved, message written to file for host review
RUN printf '#!/bin/bash\necho "$*" > /workspace/.commit-msg\necho "Commit message saved to .commit-msg"\necho "On host run: git commit -F .commit-msg"\n' > /usr/local/bin/git-draft-commit \
    && chmod +x /usr/local/bin/git-draft-commit

CMD ["claude"]
