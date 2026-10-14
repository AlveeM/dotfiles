#!/bin/sh
# Bootstrap a machine from this dotfiles repo: install what mise needs, install
# mise, then run `mise bootstrap` from the repo. Safe to re-run.
#
# Usage: bootstrap.sh [personal] <repo-url[?ref=tag]> [extra mise bootstrap flags]
#   personal   use the personal tool set and persist MISE_ENV=personal
#   repo-url   e.g. https://github.com/<you>/dotfiles.git?ref=v1 (or set DOTFILES_URL)
# Env: DOTFILES_DIR (default ~/.zsh), MISE_VERSION (pin the mise version).
set -eu

env_name=""
if [ "${1:-}" = personal ]; then
  env_name=personal
  shift
fi
url=${1:-${DOTFILES_URL:-}}
[ -n "$url" ] || { echo "usage: $0 [personal] <repo-url[?ref=tag]> [flags]" >&2; exit 2; }
[ $# -eq 0 ] || shift
dest=${DOTFILES_DIR:-$HOME/.zsh}

have() { command -v "$1" >/dev/null 2>&1; }

case "$(uname -s)" in
  Linux)
    missing=""
    have curl || missing="$missing curl"
    have git || missing="$missing git"
    [ -r /etc/ssl/certs/ca-certificates.crt ] || missing="$missing ca-certificates"
    if [ -n "$missing" ]; then
      echo "Installing prerequisites:$missing"
      if [ "$(id -u)" -eq 0 ]; then sudo=""; else sudo=sudo; fi
      $sudo apt-get update
      # shellcheck disable=SC2086
      $sudo apt-get install -y $missing
    fi
    ;;
  Darwin)
    have git || { echo "git not found: run 'xcode-select --install' and re-run." >&2; exit 1; }
    have curl || { echo "curl not found." >&2; exit 1; }
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

PATH="$HOME/.local/bin:$PATH"
export PATH
if ! have mise; then
  echo "Installing mise"
  curl -fsSL https://mise.run | sh
fi

if [ -n "$env_name" ]; then
  mise -E "$env_name" bootstrap --from "$url" --from-dir "$dest" "$@"
else
  mise bootstrap --from "$url" --from-dir "$dest" "$@"
fi

cat <<MSG

Bootstrap finished. Remaining manual steps:
  - Open a new login session so the zsh login shell takes effect.
  - Ubuntu: install the JetBrains Mono Nerd Font (see README.md) if you use a GUI terminal.
MSG
