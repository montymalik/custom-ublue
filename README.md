# Custom Bluefin DX - Niri Edition

A [bootc](https://github.com/bootc-dev/bootc) image derived from
[Bluefin DX](https://projectbluefin.io/) that adds the
[niri](https://github.com/YaLTeR/niri) scrolling Wayland compositor,
[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) and a
curated set of terminals, fonts and tools. Everything else Bluefin DX ships
(GNOME, Homebrew, distrobox, Docker) stays available; niri is an additional
session in the login screen. The only removal is VS Code.

Built weekly from `ghcr.io/ublue-os/bluefin-dx:latest`, published to
`ghcr.io/montymalik/custom-ublue` and signed with Cosign.

## What is added on top of Bluefin DX

| Area | Packages |
| --- | --- |
| Desktop | niri, quickshell-git, dms (DankMaterialShell), fuzzel |
| Terminals | kitty, alacritty |
| Remote desktop | remmina (RDP, VNC, secret plugins), freerdp |
| Fonts | Fira Code, Noto Sans Mono, Droid Sans Mono, and a pinned Nerd Fonts release under `/usr/share/fonts/nerd-fonts` |
| Removed | VS Code (`code`) |

COPR repositories: `yalter/niri`, `avengemedia/danklinux`, `avengemedia/dms`.

The Qt 6 stack is upgraded to Fedora updates during the build so that the COPR
quickshell build never runs against an older Qt than it was built with.

## Switching to the image

From any Bluefin, Aurora, Bazzite or Fedora Atomic machine:

```bash
sudo bootc switch ghcr.io/montymalik/custom-ublue:latest
systemctl reboot
```

Tags: `latest`, `latest.YYYYMMDD` and `YYYYMMDD`. Use a dated tag to pin a
build.

To verify signatures, `cosign.pub` in this repository is the public key that
matches the signing key used by the build workflow.

## After the first boot

Everything user-level is set up with `ujust`:

```bash
ujust setup-all
```

which runs, in order:

| Command | What it does |
| --- | --- |
| `ujust install-brew-packages` | `brew bundle` from `/usr/share/ublue-os/homebrew/custom.Brewfile` (emacs, neovim, lazygit, mise, atuin, yazi, kubectl, helm, talosctl, flux, ...) |
| `ujust install-flatpaks` | installs the user flatpaks listed in `custom/flatpaks/flatpaks` from Flathub |
| `ujust install-dotfiles` | **overwrites** `~/.config/{niri,alacritty,kitty,starship,fuzzel,fastfetch}` with the configs from `config/` |
| `ujust set-shell-fish` | makes fish the login shell and wires up Homebrew, atuin, starship and mise |
| `ujust install-editors` | installs Doom Emacs and LazyVim |

Then log out and pick the **niri** session. DMS starts with the session and
provides the bar, launcher, lock screen, notifications and polkit agent. The
niri config includes the files DMS manages under `~/.config/niri/dms/`, so
changes made in the DMS settings UI take effect.

Day to day, `ujust update` (Bluefin's own recipe) updates the system image,
flatpaks and Homebrew in one go.

## Repository layout

```
Containerfile          image build; runs the build/ scripts and lints with bootc
custom-ublue.env       image name, description and labels (read by the Justfile)
build/10-repos.sh      COPR repositories
build/20-packages.sh   dnf5 package removals and installs
build/30-manual.sh     Nerd Fonts download
config/                dotfiles copied to /usr/share/custom-ublue
scripts/               editor installers copied to /usr/share/custom-ublue/scripts
custom/ujust/          ujust recipes installed as 60-custom.just
custom/brew/Brewfile   Homebrew bundle
custom/flatpaks/       user flatpak list
disk_config/           bootc-image-builder configs (disk.toml, iso.toml)
```

## Building locally

Requires `podman` and `just` (both ship with Bluefin).

```bash
just build             # build custom-ublue:latest with podman
just ostree-rechunk    # optional: split into layers like CI does
just lint              # shellcheck on all scripts
just check             # just syntax check
just build-qcow2       # VM disk image via bootc-image-builder
just run-vm-qcow2      # boot it in a browser-accessible VM
just build-iso         # Anaconda installer ISO
```

`just build` runs the same recipe CI uses, so labels and tags match.

## CI

- `build.yml` runs on pushes to `main`, pull requests and a weekly cron
  (Sunday 10:05 UTC). It builds with podman, rechunks with rpm-ostree, pushes
  to GHCR and signs the manifest digest with Cosign. Pull requests build but
  never push.
- `build-disk.yml` is manual (`workflow_dispatch`) and produces a qcow2 and
  an Anaconda ISO with bootc-image-builder, optionally uploading to S3.
- Dependabot bumps the pinned GitHub Action SHAs weekly.

### Signing key

`cosign.key` must never be committed. The private key lives in the
`SIGNING_SECRET` repository secret; regenerate a pair with
`COSIGN_PASSWORD="" cosign generate-key-pair` and update both the secret and
`cosign.pub` if it is ever rotated.

## Upstream

This repository started from the
[Universal Blue image template](https://github.com/ublue-os/image-template).
The [Universal Blue forums](https://universal-blue.discourse.group/) and
[Discord](https://discord.gg/WEu6BdFEtp) are the best places for questions
about bootc images in general.
