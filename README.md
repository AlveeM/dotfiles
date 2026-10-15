# dotfiles

My zsh setup for macOS and Ubuntu. The repo lives at `~/.zsh` and is a
[mise bootstrap project](https://mise.jdx.dev/bootstrap.html): one command installs the
system packages, CLI tools, and symlinks the config files into place.

- Shell: zsh with pinned plugins (no installs or network access at shell startup).
- Tools: starship, zoxide, fzf, eza, bat, fd, ripgrep, helix, gh, and the markdown language servers
  Helix uses (installed by mise).
- Config: `.zshrc`, `.zprofile`, `.gitconfig`, starship, helix, mise.

## Quick start

Pin to a tag (`?ref=v1`) on machines where the config should only change when you
decide it should.

```sh
# Personal machine (base tools + personal tools; persists MISE_ENV=personal)
curl -fsSL https://raw.githubusercontent.com/AlveeM/dotfiles/v1/bootstrap.sh \
  | sh -s -- personal 'https://github.com/AlveeM/dotfiles.git?ref=v1'

# Any other machine (base tools only)
curl -fsSL https://raw.githubusercontent.com/AlveeM/dotfiles/v1/bootstrap.sh \
  | sh -s -- 'https://github.com/AlveeM/dotfiles.git?ref=v1'
```

You are piping a script into `sh`: read `bootstrap.sh` first, and keep the tag pinned.

`bootstrap.sh [personal] <repo-url[?ref=tag]> [extra mise bootstrap flags]`:

1. Ubuntu only: installs `curl`, `git` and `ca-certificates` with apt if missing (uses `sudo`).
   macOS only checks that `git` exists (`xcode-select --install` if not).
2. Installs [mise](https://mise.jdx.dev) with `curl https://mise.run | sh` if missing
   (`MISE_VERSION` pins the version).
3. Runs `mise bootstrap --from <url> --from-dir ~/.zsh` (with `-E personal` for `personal`).

Environment: `DOTFILES_DIR` (default `~/.zsh`), `DOTFILES_URL` (instead of the argument),
`MISE_VERSION`.

After the first run, trust the repo's mise config once so mise stops warning when your
shell is inside `~/.zsh`: `cd ~/.zsh && mise trust`.

Preview without changing anything: add `--dry-run` (the first run only prints the clone
command because no checkout exists yet). To preview the real plan, clone once, then
`cd ~/.zsh && mise trust && mise bootstrap --dry-run`.

## What `mise bootstrap` does here

Defined in [`mise.toml`](mise.toml), in mise's own order:

1. **packages**: apt packages on Ubuntu (`zsh`, `git`, `curl`, `build-essential`, compile
   libraries). apt entries are skipped on macOS; on macOS the JetBrains Mono Nerd Font cask
   is installed. Versions are `latest`: whatever the OS provides.
2. **dotfiles**: symlinks from `$HOME` into this repo (see the table below).
3. **user**: sets the login shell to `/bin/zsh` (takes effect at the next login).
4. **tools**: installs the mise tools.
5. **task**: runs `plugins/setup-plugins.zsh`, which has Antidote check out every zsh plugin at the
   `pin:` commit in `plugins/plugins.txt` and regenerates the plugin loader.

Re-running is safe: parts that already match are left alone.

| Target | Source in this repo |
|---|---|
| `~/.zshrc` | `zshrc` |
| `~/.zprofile` | `zprofile` |
| `~/.gitconfig` | `config/gitconfig` |
| `~/.config/starship.toml` | `config/starship.toml` |
| `~/.config/helix/config.toml` | `config/helix/config.toml` |
| `~/.config/helix/languages.toml` | `config/helix/languages.toml` |
| `~/.config/mise/config.toml` | `config/mise/config.toml` |
| `~/.config/mise/config.personal.toml` | `config/mise/config.personal.toml` |
| `~/.config/mise/config.work.toml` | `config/mise/config.work.toml` |
| `~/.config/mise/mise.lock` | `config/mise/mise.lock` |

If a real file is already where a symlink should go, the run stops and lists the
conflicts. Move or review the file, then re-run with `--force-dotfiles` only if you are
sure you want it replaced.

## Tool sets and `MISE_ENV`

| Environment | Tools |
|---|---|
| none (default) | the base tools in `config/mise/config.toml`: starship, zoxide, fzf, eza, bat, fd, ripgrep, helix, gh, markdown language servers |
| `personal` | base + `config/mise/config.personal.toml` (language runtimes, Kubernetes tools, prettier, and other personal CLIs) |
| `work` | base + `config/mise/config.work.toml` (currently empty) |

`mise -E personal bootstrap ...` on the first run writes `export MISE_ENV=personal` into
`~/.zshenv` (via `mise.personal.toml`), so later shells and plain `mise` commands keep using
the personal set.

## Machine-local files (not in the repo)

| File | Purpose |
|---|---|
| `~/.gitconfig.local` | `[user] name` and `email`, included by `gitconfig` |
| `~/.zshrc.work` | extra exports/config for a specific machine; sourced by `zshrc` if present |
| `~/.zshenv` | `MISE_ENV` (written by a personal bootstrap) |
| `~/.config/mise/mise.personal.lock` | personal tool lockfile written by `mise lock` |

Create `~/.gitconfig.local` on each new machine:

```ini
[user]
	name = Your Name
	email = you@example.com
```

## Fonts

starship and `eza --icons` need a Nerd Font in the terminal. macOS gets JetBrains Mono Nerd
Font from the bootstrap. On Ubuntu with a GUI terminal, install it by hand:

```sh
mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip && rm JetBrainsMono.zip && fc-cache -f
```

Headless servers do not need it: the font belongs to the terminal you connect from.

## Updating

- **Plugins:** change the `pin:` commit in `plugins/plugins.txt`, review the diff upstream, then
  `zsh ~/.zsh/plugins/setup-plugins.zsh` and open a new shell. Nothing updates on its own.
- **Tool versions:** `MISE_ENV=personal mise lock --global --platform macos-arm64,linux-x64,linux-arm64`
  refreshes the lockfiles. Commit `config/mise/mise.lock`; `mise.personal.lock` is machine-local
  (written to `~/.config/mise/` and not tracked here).
- **apt packages:** `mise bootstrap packages upgrade`.
- **Pull repo changes:** `cd ~/.zsh && git pull --ff-only && mise bootstrap`.

## Layout

```
mise.toml  mise.personal.toml     bootstrap project and personal-only settings
bootstrap.sh                      installs prerequisites and mise, then runs mise bootstrap
zshrc  zprofile                   deployed to $HOME; zshrc sources zsh.d/ in a fixed order
zsh.d/                            shell modules: path exports history aliases functions git
                                  abbreviations completion keybindings
plugins/                          plugins.txt (pinned revisions, pin:<sha>) and
                                  setup-plugins.zsh (pins Antidote, regenerates the loader)
config/                           deployed to $HOME / ~/.config by [dotfiles] in mise.toml
  gitconfig  starship.toml        git and prompt config
  helix/  ghostty/                editor and terminal config
  mise/                           tool configs and lockfiles
```

Ignored (recreated by setup): `plugins/antidote/`, `plugins/plugins.zsh`, `*.zwc`.
Plugin checkouts live in `~/.cache/antidote`.

## Not handled

Docker, `gcloud`, `conda`, other GUI apps, and `~/.ssh`. Install those separately.

## Security notes

- Plugins and tools run with your full user privileges. Plugins are pinned by commit;
  mise tools are pinned in the lockfiles.
- Anything pushed here is public. Keep names, emails, hostnames and tokens out of it: use
  the machine-local files above.
- Applying this repo runs code defined in `mise.toml` and `plugins/setup-plugins.zsh`. Review
  changes before updating a machine, and pin `?ref=` to a tag you have reviewed.
