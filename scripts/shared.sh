#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_shared_configs() {
  link_file "$REPO_ROOT/zsh/zshrc" "$HOME/.zshrc"
  link_file "$REPO_ROOT/tmux/tmux.conf" "$HOME/.tmux.conf"
  link_file "$REPO_ROOT/git/global_ignore" "$HOME/.gitignore_global"
  link_file "$REPO_ROOT/nvim/init.vim" "$HOME/.config/nvim/init.vim"
}

install_shared_tooling() {
  install_antigen
  install_vim_plug
  set_git_ignore
  install_shared_configs
  maybe_run_nvim_plug_install
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  install_shared_tooling
fi
