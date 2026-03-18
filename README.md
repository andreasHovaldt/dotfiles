# dotfiles

## Recommendations

Optionally install the following beforehand:

### Pixi for Linux

```bash
curl -fsSL https://pixi.sh/install.sh | sh
```

Autocompletion is handled by chezmoi.

### Miniforge for Linux:

```bash
curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh | sh
```

Do not add to .zsh when prompted, it is handled by chezmoi.

## Secret Handling using BitWarden

The dotfiles use rbw (a Rust-based BitWarden CLI) for secret handling. Chezmoi will automatically [install rbw](./.chezmoiscripts/run_once_before_install-rbw.sh.tmpl) when applying the dotfiles. During the rbw installation rbw will ask for the [personal BitWarden API key](https://vault.bitwarden.eu/#/settings/security/security-keys) for registering the device, and the BitWarden master password for logging in.

[_Docs: CLI Authentication via API key_](https://bitwarden.com/help/personal-api-key/)

The default BitWarden server is *https://api.bitwarden.eu*. It can be changed in the [rbw install script](./.chezmoiscripts/run_once_before_install-rbw.sh.tmpl).

## Installation

**Install chezmoi:**

```bash
sudo pacman -S chezmoi
```

_Check [chezmoi install page](https://www.chezmoi.io/install/) for other Linux installation methods_

**Pull dotfiles:**

```bash
chezmoi init https://github.com/andreasHovaldt/dotfiles.git
```

**Check pending dotfile changes:**

```bash
chezmoi diff
```

**Appy dotfile changes:**

```bash
chezmoi apply
```

### One-liner for directly applying dotfiles

```bash
chezmoi init --apply andreasHovaldt
```
