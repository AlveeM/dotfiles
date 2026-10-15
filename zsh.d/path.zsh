# ================================================================================
# PATH setup (Go, mise shims)
# NOTE: `mise activate` stays in .zshrc and must run last.
# ================================================================================

# Go
export PATH="$PATH:$HOME/go/bin"  # static $(go env GOPATH)/bin to avoid a subprocess at startup

# mise shims go last so already-installed system tools win until mise provides them;
# `mise activate` (end of .zshrc) later puts real tool paths first. The shims make mise-managed
# tools (starship, zoxide, fzf, ...) resolvable for the cached inits earlier in .zshrc.
export PATH="$HOME/.local/bin:$PATH:$HOME/.local/share/mise/shims"
