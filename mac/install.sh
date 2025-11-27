#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$REPO_ROOT/scripts/common.sh"
source "$REPO_ROOT/scripts/shared.sh"

ensure_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "Missing required command: $cmd"
    exit 1
  fi
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew already installed"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv || brew shellenv)"
    return
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
}

install_brew_packages() {
  local packages=(
    git
    curl
    zsh
    tmux
    neovim
    kitty
    ripgrep
    fd
    fzf
    python
    pipx
    shellcheck
    zoxide
    universal-ctags
    the_silver_searcher
    clang-format
    llvm
    cmake
  )

  log "Installing base brew packages"
  brew update
  brew install "${packages[@]}"

  if brew list --cask karabiner-elements >/dev/null 2>&1; then
    log "Karabiner-Elements already installed"
  else
    brew install --cask karabiner-elements
  fi

  if [[ -x "$(brew --prefix)/opt/fzf/install" ]]; then
    "$(brew --prefix)/opt/fzf/install" --completion --key-bindings --no-update-rc
  fi
}

install_python_packages() {
  ensure_command python3
  if ! command -v pipx >/dev/null 2>&1; then
    log "pipx not found; attempting to install via Homebrew"
    brew install pipx
  fi

  pipx ensurepath

  local packages=(
    pipenv
    pylint
    autopep8
    yamllint
    pynvim
    neovim-remote
    proselint
    yamlfix
    jedi-language-server
  )

  for pkg in "${packages[@]}"; do
    pipx install "$pkg" --force
  done
}

install_node_stack() {
  bash "$REPO_ROOT/node/install_node.sh"
  if command -v npm >/dev/null 2>&1; then
    npm install -g remark remark-lint remark-cli remark-preset-lint-recommended remark-lint-ordered-list-marker-value remark-stringify alex
  fi
}

install_zoxide() {
  if command -v zoxide >/dev/null 2>&1; then
    log "zoxide already installed"
    return
  fi
  log "zoxide not found; installing via brew"
  brew install zoxide
}

install_fonts() {
  log "Installing fonts (nerd/powerline)"
  brew install --cask font-hack-nerd-font font-meslo-lg-nerd-font font-fira-code-nerd-font font-inconsolata-for-powerline
}

link_mac_configs() {
  link_file "$REPO_ROOT/mac/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
  link_file "$REPO_ROOT/mac/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
}

main() {
  install_homebrew
  install_brew_packages
  install_zoxide
  install_fonts
  install_python_packages
  install_node_stack
  install_shared_tooling
  link_mac_configs

  log "macOS setup complete. Start Karabiner-Elements to apply keyboard mappings."
}

main "$@"
