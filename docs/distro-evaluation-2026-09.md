# Distro evaluation, September 2026

Working notes from an ongoing conversation about which base this image should
sit on. Not a decision. Kept here so the reasoning survives.

## Criteria

Stated ideal: **immutable, runs Homebrew and Flatpak, can layer packages if
needed.** Implicit but non-negotiable: niri plus DankMaterialShell (DMS), and
the existing ujust / Brewfile / dotfile setup carrying over. Nice to have: the
custom-image-in-CI workflow this repo already uses.

## Why the question came up

Bluefin is splitting into Dakota (flagship, GNOME OS built from source with
BuildStream) and Utah (Fedora Hummingbird, keeps the RPM package contract).
Dakota was investigated first.

### Dakota verdict: not viable for this stack today

| Component | On Dakota |
| --- | --- |
| dotfiles, ujust recipes, Brewfile, flatpaks | port unchanged via a thin `FROM dakota` Containerfile |
| Tailscale, JetBrains Mono Nerd Font | already in the base |
| niri, xwayland-satellite, fuzzel | feasible as BuildStream elements; the SDK ships Rust 1.98 and every niri dependency, and Dakota's `sudo-rs.bst` is the template |
| Alacritty, kitty, Remmina | Flathub |
| **DMS (quickshell)** | **blocked**: needs Qt 6 private APIs; no Qt 6 BuildStream metadata exists, no Homebrew formula, the DMS installer does not target GNOME OS |
| `rpm-ostree` rechunk, bootc-image-builder | replaced by chunkah; BIB support unverified |

Would reopen the question: Qt 6 BuildStream metadata appearing, DMS shipping a
self-contained build, or Utah publishing installable images.

**Update, 2026-09-19:** Qt 6 BuildStream metadata exists. The Tromso family
(tuna-os/tromso, hanthor/tromso, whelanh/tromso_x with kde-build-meta-x)
builds KDE Plasma 6 on freedesktop-sdk as a bootc image with ~30 Qt 6
elements including qtbase, qtdeclarative, qtwayland, qtshadertools and qtsvg.
KDE itself maintains KDE/kde-buildstream and KDE Linux is moving to
BuildStream. This changes Dakota from "blocked" to "medium project":

- port the handful of Qt elements quickshell needs into a Dakota-based
  project, rebuilt against Dakota's freedesktop-sdk (Tromso tracks 25.08,
  Dakota testing tracks 26.08, so the artifacts are not shareable)
- write quickshell, dms, matugen and dgop elements, plus niri and
  xwayland-satellite
- assemble the image; Tromso's multi-runner CI is the reference for
  building Qt without a public artifact cache
- BuildStream rebuilds quickshell automatically whenever Qt changes, which
  fits quickshell's rebuild-on-every-Qt-release requirement better than RPMs
  do

Rough effort: one to two weeks of evenings, then low maintenance. Still
cheaper if a portable DMS build or Utah images appear first.

**Experiment result, 2026-09-19:** both test elements built against Dakota's
SDK (freedesktop-sdk 26.08.1) in a clone of projectbluefin/dakota:

| Element | Outcome | Notes |
| --- | --- | --- |
| qt6-qtbase (Tromso's element, Qt 6.10.3) | built, 35 min | no patches; needed a `qt:` source alias |
| niri 26.04 | built, ~11 min | two one-line fixes: relax the libdisplay-info crate's `< 0.4.0` bound (SDK has 0.4.0), link against the SDK's `dummy-gbm` stub like mutter does |

The niri binary runs against the SDK libraries and validates its default
config. Dakota's own cache had every dependency except libseat and
libdisplay-info, which built in seconds. The GNOME cache server stalled from
this network and had to be bypassed. Elements and notes live in
`~/projects/dakota-experiment/`.

**Experiment result, 2026-09-20 (quickshell):** the full Qt stack quickshell
needs and quickshell itself, at the exact commit the Fedora COPR ships, built
against Dakota's SDK.

| Element | Time | Notes |
| --- | --- | --- |
| qtbase | 36 min | install into the multiarch libdir (Tromso's `/usr/lib` layout is invisible to the SDK loader) |
| qtdeclarative | 50 min | unchanged from Tromso once qtbase was fixed |
| qtshadertools, qtwayland, qtsvg, cli11 | 2 to 4 min each | unchanged |
| quickshell (master c6a5160) | 5.5 min | first build succeeded; two install-layout fixes: relative `qs` symlink, absolute `INSTALL_QMLDIR` |

Every feature DMS uses is enabled (layer-shell, session lock, toplevel
management, screencopy, tray, PipeWire, MPRIS, PAM, polkit, UPower,
notifications, Bluetooth, network). The binary runs against the SDK
libraries and installs the same QML modules as the Fedora package minus the
X11, Hyprland and i3 ones that were switched off. Remaining for a working
desktop: dms, matugen and dgop elements (Go and Rust, routine), assembling an
image, and booting it.

**Experiment result, 2026-09-21 (dms):** the dms CLI v1.6.2 and the QML
shell built as one element in about 25 minutes, most of it the SDK's Go
toolchain chain that Bluefin's cache did not hold. The release source tarball
ships a complete Go vendor tree, so the build is offline; Dakota's own private
Go 1.26 element covers DMS's Go version requirement. Layout matches Fedora's
dms and dms-cli packages. The static binary runs on the host and reports its
version. Left for step 1: matugen, dgop, xwayland-satellite, and the overlay
checkout script.

**Experiment result, 2026-09-21 (matugen, dgop, xwayland-satellite):** all
three built first try in about 11 minutes, plus Xwayland and a few X
libraries that Dakota's image does not carry (so the overlay must ship
Xwayland). Every compiled component of the niri + DMS desktop now exists as
a BuildStream element against Dakota's SDK: 12 element files in total. Only
the overlay checkout script remains before the Containerfile and VM boot.

**Go/no-go, 2026-09-21: GO.** The overlay checkout script produced a 279 MB
`/usr` overlay (only files Dakota's image lacks, every ELF resolved against
the base by `ldd`). A three-line Containerfile (`FROM dakota:testing` by
digest, `COPY overlay/usr/`, `COPY skel/`, `bootc container lint`) built and
booted in QEMU via `bootc install to-disk`. GNOME initial setup, a Niri
session and DMS auto-loading from the niri config all worked. Two build
fixes came out of the VM: quickshell must install its QML modules under an
absolute `INSTALL_QMLDIR` with the Hyprland/i3/X11 modules on (DMS imports
`Quickshell.Hyprland`), and dms must be built with the `withshell` tag so
the shell is embedded in the binary.

**Step 2, 2026-09-22: standalone project.** The elements moved out of the
Dakota clone into their own BuildStream project, `dakota-niri`, that
junctions projectbluefin/dakota (pinned by full git-describe ref) and
inherits its freedesktop-sdk through it. A `bump-base` script re-pins both
the junction ref and the base image digest together. Hosted on the
self-hosted Gitea, not GitHub.

**Step 3, 2026-09-22: infrastructure on the Talos cluster.** Namespace
`dakota-build` (Flux, `apps/dakota-build/` in homelab-flux): Buildbarn
bb-storage plus bb-remote-asset as the BuildStream artifact and source
cache (210 GiB Longhorn, reachable from the workstation over the tailnet),
and a Gitea act_runner in host mode pinned to node4 with the bst2
container, podman, just and cosign in its image. Gitea Actions workflow:
build elements, push artifacts, assemble overlay, build image, push to the
Gitea registry as `testing` and `testing.YYYYMMDD`, cosign sign. A weekly
`bump-base` workflow opens a PR when Dakota's testing image moves.
Lessons: push only the project's own elements to the cache (`--deps all`
drags the whole SDK through Bluefin's cache and times out); act_runner
gives steps a pty, so cosign must get `COSIGN_PASSWORD` set and stdin
detached or it waits on a password prompt forever; cosign does not read
podman's root auth file, so both tools point at one credential file. First
fully green run: 158, on 2026-09-22. The signed `testing` image verifies
against the repo's `cosign.pub`.

**Step 4, 2026-09-22: user setup ported.** The custom-ublue setup now
lives in the Dakota image using Dakota's own mechanisms rather than
custom glue:

| custom-ublue | dakota-niri |
| --- | --- |
| Brewfile + `ujust install-brew-packages` | Brewfile in `/usr/share/ublue-os/homebrew/preinstall.d/`; Dakota's brew-preinstall installs it for every user at first login and removes packages dropped from it |
| flatpak list + `ujust install-flatpaks` | `/usr/share/flatpak/preinstall.d/` entry (Chrome, Podman Desktop, Remmina); installed system-wide at boot |
| `config/` + `ujust install-dotfiles` | `/usr/share/dakota-niri/config`, seeded into `/etc/skel` at build time; recipe kept for resets |
| kitty, Alacritty RPMs | Alacritty built as a BuildStream element (neither is on Flathub); kitty dropped, Ghostty is in the base |
| fuzzel | DMS launcher |
| `ujust set-shell-fish` (brew/starship/atuin/mise init) | `chsh`; Dakota already wires brew and starship into fish, only atuin and mise are ours |
| `ujust install-editors` | unchanged (Doom Emacs, LazyVim) |

`dms setup` is blocked by DMS on ostree-style systems; an
`/etc/dms/cli-policy.json` override re-enables it (it only writes user
config). Verified in a fresh VM install: skel dotfiles, both Brewfiles,
the Flatpaks, fish as login shell with brew, starship and atuin on the
path, LazyVim, Alacritty 0.17.0, and niri validating the resulting config.
CI run 163 built and signed the image on the cluster; the first real
compile there surfaced two infrastructure fixes (Talos ships
`user.max_user_namespaces=0`, and the asset cache must answer misses with
NOT_FOUND).

Note: no source confirmed ublue-os/bluefin entering maintenance mode. The
Dakota Alpha 2 post calls Fedora Bluefin "the product". What is documented is
the move of repositories to the projectbluefin org and factory.projectbluefin.io.

## Candidates

| Candidate | Immutable | Homebrew | Flatpak | Layering | niri + DMS | Custom image in CI |
| --- | --- | --- | --- | --- | --- | --- |
| Bluefin DX (today) | bootc | built in | yes | dnf5 in Containerfile | COPRs, working now | yes, this repo |
| Plain Fedora bootc / Silverblue | bootc | install Bluefin's tarball yourself | yes | same | same COPRs | same repo, swap FROM |
| Utah (future) | bootc | expected | yes | RPM contract kept | same COPRs, unverified | same repo, swap FROM |
| Aurora / Bazzite | bootc | built in | yes | same | same COPRs | same repo, swap FROM |
| Dakota | bootc | built in | yes | no (BuildStream overlay instead) | working: niri + DMS built from source, booted in a VM | BuildStream project on Gitea, working |
| openSUSE Aeon / Kalpa | btrfs snapshots | works | yes | transactional-update, officially discouraged | niri in Tumbleweed; DMS via danklinux OBS | none |
| Vanilla OS 2 | Vib images | works | yes | Vib recipes | no Debian niri package; DMS has Debian 13 OBS builds | Vib, not bootc |
| NixOS | declarative, not image-based | replaced by nix | yes | trivial | niri-flake and an official DMS flake; best support outside Arch/Fedora | flake |

## Recommendations (as of 2026-09-19)

1. **Stay on Fedora Bluefin DX for now.** It is the only candidate that clears
   every column, and the review and two PRs done in September leave the repo
   in good shape.
2. **Keep the Bluefin-specific surface small so a base swap stays cheap.** If
   ublue-os/bluefin ever goes quiet, the migration is one FROM line
   (fedora-bootc or Silverblue) plus vendoring three things: the Homebrew
   tarball install, the ujust runner, and the update timer. COPRs, dotfiles,
   Brewfile and flatpak list do not change. Optional hardening now:
   - stop depending on Bluefin's Brewfile directory and update recipe
   - pin the base image by digest so upstream surprises can't land on a
     weekly build unnoticed
3. **Utah is the natural successor.** Same RPM contract, so a FROM swap once
   images are published. niri and DMS COPR compatibility still to verify.
4. **NixOS is the second-best option**, ahead of Dakota or Aeon. It has the
   best niri and DMS support of anything considered. The objection is config
   authoring, not the model, and that is worth a no-commitment VM experiment.
5. **Not a fit:** Dakota (DMS), Aeon/Kalpa (layering discouraged, no image
   pipeline), Vanilla OS (no niri on Debian).

## Where this stands (2026-09-22)

Recommendations 1 to 5 above were written when DMS looked blocked. Since
then the Dakota path was built end to end and works, so the live question
is no longer feasibility but whether to switch. The Dakota image now exists
as a separate project (`dakota-niri` on Gitea) alongside this repo; this
repo remains the daily driver and the rollback.

## Open threads

- Step 5 finding (2026-09-22/23): an in-place `bootc switch` from Bluefin
  to dakota-niri does not work and cannot be made to, short of rewriting
  the user database. Dakota's kernel, initramfs and ostree root boot fine,
  but Fedora's system users and groups live in `/usr/lib/passwd` and
  `/usr/lib/group` (gone with the old `/usr`), Dakota's live in the image's
  `/etc` (never merged because the local `/etc/passwd` wins), uids and gids
  differ from what owns `/var`, and sysusers runs before `/etc` is writable.
  Fedora-specific state (SELinux, authselect, firewalld zones) stays behind
  as well. Moving to Dakota means a fresh install plus restoring the home
  directory and a few system settings, both for the test VM and the real
  machine. The image itself is fine on a fresh install (verified in QEMU).
- Next: fresh-install the Proxmox test VM by importing the raw disk (needs
  UEFI), verify Remote Login and the ujust setup, then plan the real
  machine's fresh install; check DMS's input-group needs on real hardware.
- Retarget dakota-niri to Dakota stable once freedesktop-sdk 26.08 reaches
  it (testing tracks 26.08, stable 25.08; artifacts are not shareable).
- Tighten the runner's Cilium egress once Hubble shows what it really needs.
- Still worth watching: Utah images, and whether upstream Dakota grows a
  niri or Qt story that makes the overlay unnecessary.
