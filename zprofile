# Homebrew environment: macOS (Apple Silicon or Intel) or Linuxbrew, if present.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x $_brew ]]; then
    eval "$($_brew shellenv)"
    break
  fi
done
unset _brew

# JetBrains Toolbox command-line launchers (macOS and Linux locations).
for _toolbox in "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" \
                "$HOME/.local/share/JetBrains/Toolbox/scripts"; do
  [[ -d $_toolbox ]] && path+=("$_toolbox")
done
unset _toolbox
