#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
  echo "[config_files] $*"
}

ensure_dir() {
  mkdir -p "$1"
}

link_file() {
  local target="$1"
  local dest="$2"

  ensure_dir "$(dirname "$dest")"
  ln -sfn "$target" "$dest"
  log "Linked $dest -> $target"
}

install_antigen() {
  local dest="${ANTIGEN_PATH:-$HOME/.antigen.zsh}"

  if [[ -f "$dest" ]]; then
    log "Antigen already present at $dest"
    return
  fi

  curl -fsSL git.io/antigen -o "$dest"
  log "Downloaded antigen to $dest"
}

install_vim_plug() {
  local dest="$HOME/.local/share/nvim/site/autoload/plug.vim"

  if [[ -f "$dest" ]]; then
    log "vim-plug already present"
    return
  fi

  curl -fLo "$dest" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  log "Installed vim-plug"
}

maybe_run_nvim_plug_install() {
  if ! command -v nvim >/dev/null 2>&1; then
    log "nvim not on PATH; skipping PlugInstall"
    return
  fi

  if nvim --headless +PlugInstall +qall >/dev/null 2>&1; then
    log "Installed/updated vim plugins"
  else
    log "nvim +PlugInstall exited non-zero; open nvim and run :PlugInstall if needed"
  fi
}

set_git_ignore() {
  local ignore_file="$REPO_ROOT/git/global_ignore"
  git config --global core.excludesfile "$ignore_file"
  log "Configured git excludesfile -> $ignore_file"
}

resolve_repo_root() {
  echo "$REPO_ROOT"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  log "This script is meant to be sourced. Try: source scripts/common.sh"
fi
