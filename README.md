# dotfiles

## Installation

Arch:

```bash
sudo pacman -S chezmoi
```

## Recommendation

Install the following beforehand:

### rbw (Rust-based BitWarden CLI)

Arch:

```bash
sudo pacman -S rbw
```

Setup the correct server and email, e.g.:

```bash
rbw config set base_url https://api.bitwarden.eu
rbw config set email <email>
```

Register the device using the [personal BitWarden API key](https://vault.bitwarden.eu/#/settings/security/security-keys):

```bash
rbw register
```

[_Docs: CLI Authentication via API key_](https://bitwarden.com/help/personal-api-key/)

Lastly, login and sync local database:

```bash
rbw login
rbw sync
```

### Pixi and/or MiniForge

Pixi for Linux:

```bash
curl -fsSL https://pixi.sh/install.sh | sh
```

Autocompletion is handled by chezmoi

Miniforge for Linux:

```bash
curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh | sh
```

Do not add to .zsh, it is handled by chezmoi

## Usage

Pull dotfiles:

```bash
chezmoi init https://github.com/andreasHovaldt/dotfiles.git
```

Check pending dotfile changes:

```bash
chezmoi diff
```

Appy dotfile changes:

```bash
chezmoi apply
```

### One-liner for directly applying dotfiles

```bash
chezmoi init --apply andreasHovaldt
```
