# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

A custom [bootc](https://github.com/bootc-dev/bootc) OCI container image derived from `ghcr.io/ublue-os/bluefin-dx:latest` (Universal Blue's Bluefin DX). It produces **Custom Bluefin DX - Niri Edition**: a Fedora Atomic desktop image with the Niri Wayland compositor, custom dotfiles, and a curated set of tools. The image is built weekly via GitHub Actions and published to GHCR.

## Common Commands

```bash
# Build the container image locally
just build

# Lint all shell scripts (requires shellcheck)
just lint

# Format all shell scripts (requires shfmt)
just format

# Check/fix Justfile syntax
just check
just fix

# Build a QCOW2 VM image from the container
just build-qcow2

# Run a VM from the built QCOW2
just run-vm-qcow2

# Clean build artifacts
just clean
```

## Architecture

The build is a standard OCI/Containerfile build orchestrated by `just` locally and GitHub Actions in CI.

**Build pipeline** (executed inside the container during `podman build`):
1. `build/10-repos.sh` — adds COPR repos (niri, danklinux, dms, lazygit) and the Tailscale stable repo
2. `build/20-packages.sh` — installs RPM packages via `rpm-ostree` (removes VS Code, adds Niri, Alacritty, Kitty, Tailscale, Remmina, fuzzel, nfs-utils/autofs, fonts)
3. `build/30-manual.sh` — manually downloads Nerd Font zips from GitHub releases into `/usr/share/fonts/nerd-fonts`

**Files copied into the image at build time:**
- `config/` → `/usr/share/custom-ublue/` (dotfiles for niri, alacritty, kitty, starship, fuzzel, fastfetch)
- `scripts/` → `/usr/share/custom-ublue/scripts/` (install-doom.sh, install-lazyvim.sh)
- `custom/ujust/setup.just` → `/usr/share/ublue-os/just/60-custom.just` (ujust commands available after boot)
- `custom/brew/Brewfile` → `/usr/share/ublue-os/brew/Brewfile` (Homebrew packages: emacs, neovim, lazygit, mise, atuin, yazi, etc.)
- `custom/flatpaks/flatpaks` → user flatpak list (Chrome, Podman Desktop)

**Post-boot user setup** (run once after switching to the image via `ujust`):
- `ujust setup-all` — orchestrates: brew bundle, flatpak install, dotfile copy, fish shell setup, editor installs (Doom Emacs + LazyVim)
- `ujust install-dotfiles` — **overwrites** `~/.config/{niri,alacritty,kitty,starship,fuzzel}` from `/usr/share/custom-ublue/`

**CI/CD** (`build.yml`): triggers on push to `main`, weekly cron (Sundays 10:05 UTC), and PRs. Builds with `buildah`, pushes to GHCR, signs with Cosign (`SIGNING_SECRET`). Images are tagged `latest`, `latest.YYYYMMDD`, and `YYYYMMDD`.

**Disk image builds** (`build-disk.yml`): separate workflow using `bootc-image-builder` to produce ISO/QCOW2/raw from the OCI image. Configs live in `disk_config/`.

## Key Constraints

- The `cosign.key` file must **never** be committed — only `cosign.pub` is in the repo. The private key lives in the `SIGNING_SECRET` GitHub Actions secret.
- `rpm-ostree install` runs inside the container build (not on the host), so package changes go in `build/20-packages.sh`.
- The image name in `build.yml` defaults to the GitHub repository name (`IMAGE_NAME: "${{ github.event.repository.name }}"`).
