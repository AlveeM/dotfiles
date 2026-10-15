# dotfiles

My zsh setup for macOS and Ubuntu. The repo lives at `~/.zsh` and is a
[mise bootstrap project](https://mise.jdx.dev/bootstrap.html): one command installs the
system packages, CLI tools, and symlinks the config files into place.

- Shell: zsh with pinned plugins (zsh-defer, completions, autosuggestions, syntax highlighting,
  history substring search, zsh-abbr); no installs or network access at shell startup.
- Tools: starship, zoxide, fzf, eza, bat, fd, ripgrep, helix, tmux, zellij, gh, and the markdown language servers
  Helix uses (installed by mise).
- Config: `.zshrc`, `.zprofile`, `.gitconfig`, starship, helix, ghostty, tmux, zellij, mise.

## Quick start

Pin to a tag (`?ref=v1`) on machines where the config should only change when you
decide it should.

```sh
# Personal machine (base tools + personal tools; persists MISE_ENV=personal)
curl -fsSL https://raw.githubusercontent.com/AlveeM/dotfiles/v1/bootstrap.sh \
  | sh -s -- personal 'https://github.com/AlveeM/dotfiles.git?ref=v1'

# Work machine (base tools + work tools; persists MISE_ENV=work)
curl -fsSL https://raw.githubusercontent.com/AlveeM/dotfiles/v1/bootstrap.sh \
  | sh -s -- work 'https://github.com/AlveeM/dotfiles.git?ref=v1'

# Any other machine (base tools only)
curl -fsSL https://raw.githubusercontent.com/AlveeM/dotfiles/v1/bootstrap.sh \
  | sh -s -- 'https://github.com/AlveeM/dotfiles.git?ref=v1'
```

You are piping a script into `sh`: read `bootstrap.sh` first, and keep the tag pinned.

`bootstrap.sh [personal|work] <repo-url[?ref=tag]> [extra mise bootstrap flags]`:

1. Ubuntu only: installs `curl`, `git` and `ca-certificates` with apt if missing (uses `sudo`).
   macOS only checks that `git` exists (`xcode-select --install` if not).
2. Installs [mise](https://mise.jdx.dev) with `curl https://mise.run | sh` if missing
   (`MISE_VERSION` pins the version).
3. Runs `mise bootstrap --from <url> --from-dir ~/.zsh` (with `-E personal` or `-E work` when given).

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
| `~/.config/ghostty/config` | `config/ghostty/config` |
| `~/.config/tmux/tmux.conf` | `config/tmux/tmux.conf` |
| `~/.config/zellij/config.kdl` | `config/zellij/config.kdl` |
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
| none (default) | the base tools in `config/mise/config.toml`: starship, zoxide, fzf, eza, bat, fd, ripgrep, helix, tmux, zellij, gh, markdown language servers |
| `personal` | base + `config/mise/config.personal.toml` (language runtimes, Kubernetes tools, prettier, and other personal CLIs) |
| `work` | base + `config/mise/config.work.toml` (currently empty) |

`mise -E personal bootstrap ...` (or `-E work`) on the first run writes `export MISE_ENV=personal`
(or `work`) into `~/.zshenv` via `mise.personal.toml` (or `mise.work.toml`), so later shells and
plain `mise` commands keep using that set.

## Machine-local files (not in the repo)

| File | Purpose |
|---|---|
| `~/.gitconfig.local` | `[user] name` and `email`, included by `gitconfig` |
| `~/.zshrc.work` | extra exports/config for a specific machine; sourced by `zshrc` if present |
| `~/.zshenv` | `MISE_ENV` (written by a personal or work bootstrap) |
| `~/.config/mise/mise.personal.lock` | personal tool lockfile written by `mise lock` |

Create `~/.gitconfig.local` on each new machine:

```ini
[user]
	name = Your Name
	email = you@example.com
```

## Shell helpers

Git functions live in `zsh.d/git.zsh`. Anything that discards work asks for confirmation first.

| Command | Does |
|---|---|
| `gm` | switch to the default branch (resolved from `origin/HEAD`) |
| `gcb <name>` | create and switch to `<user>/<name>` |
| `gbf` / `gbd` | fzf branch switch / multi-select force delete |
| `gf` / `gdm` | fetch the current branch / diff against `origin/<main>` |
| `grm` / `gcr <n>` | rebase onto `origin/<main>` / move the last `n` commits onto it |
| `gpu` | push and open a draft PR (refuses from the main branch) |
| `gpf` | force push with a lease (confirms) |
| `gsync` | stash everything, then reset to `origin/<branch>` (confirms) |
| `gdr <branch>` | delete a remote branch (confirms) |
| `gpurge` / `gpurgef` | delete local branches whose upstream is gone (`-d` / `-D`, the latter confirms) |

`zsh.d/abbreviations.zsh` defines the short git abbreviations (zsh-abbr; `abbr -S list` shows them, and the file header explains
the three scopes). An expansion puts the cursor at its first `%` marker; press `Alt-;`
(`zsh.d/keybindings.zsh`) to jump to the next marker and delete it.

The fzf helpers live in `zsh.d/functions.zsh`:

| Command | Does |
|---|---|
| `fsearch <pattern> [path ...]` | ripgrep once, then fuzzy-filter the matching lines |
| `cdf [dir]` | pick a directory (tree preview) and `cd` into it |
| `fe [dir]` | pick a file (syntax-highlighted preview) and open it in `$EDITOR` |
| `fcd [dir]` | pick a file and `cd` into the directory containing it |

`zsh.d/lazy-tools.zsh` loads `conda` and `gcloud` on first use when they are installed.

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
~/.zsh
├── bootstrap.sh          # installs prerequisites and mise, then runs mise bootstrap
├── mise.toml             # bootstrap project
├── mise.personal.toml    # per-env settings
├── mise.work.toml
├── zshrc                 # deployed to $HOME; sources zsh.d/ in a fixed order
├── zprofile
├── zsh.d/                # shell modules (see load order below)
│   └── *.zsh
├── plugins/
│   ├── plugins.txt       # pinned revisions (pin:<sha>)
│   └── setup-plugins.zsh # pins Antidote, regenerates the loader
└── config/               # deployed to $HOME / ~/.config by [dotfiles] in mise.toml
    ├── gitconfig
    ├── starship.toml
    ├── helix/            # editor
    ├── ghostty/          # terminal
    ├── tmux/             # multiplexer
    ├── zellij/           # multiplexer
    └── mise/             # tool configs and lockfiles
```

`zshrc` loads the `zsh.d/` modules in this order:

1. `path`, `lazy-tools`, `exports`, `history`, `aliases`, `functions`, `git`
2. the pinned plugins (`plugins/plugins.zsh`)
3. `abbreviations` and `keybindings` (deferred with zsh-defer when it is available)
4. `completion`

Ignored (recreated by setup): `plugins/antidote/`, `plugins/plugins.zsh`, `*.zwc`, `.mise/`,
`config/mise/mise.personal.lock`.
Plugin checkouts live in `~/.cache/antidote`.

## Not handled

Docker, `gcloud`, `conda`, other GUI apps, and `~/.ssh` are not managed. Install those separately;
the shell config only picks up `conda` and `gcloud` if they exist.

## Security notes

- Plugins and tools run with your full user privileges. Plugins are pinned by commit;
  mise tools are pinned in the lockfiles.
- Anything pushed here is public. Keep names, emails, hostnames and tokens out of it: use
  the machine-local files above.
- Applying this repo runs code defined in `mise.toml` and `plugins/setup-plugins.zsh`. Review
  changes before updating a machine, and pin `?ref=` to a tag you have reviewed.
