# dotfiles

## Installation

Arch:

```bash
sudo pacman -S chezmoi
```

## Recommendation

Install the following beforehand:

### BitWarden CLI

Arch:

```bash
sudo pacman -S bitwarden-cli
```

Then setup the correct server and login, e.g.:

```bash
bw config server https://vault.bitwarden.eu
bw login
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
