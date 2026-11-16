# Chaulagain OS

A macOS-inspired desktop operating system built on Fedora KDE Plasma. It's designed so your Pixel phone and your computer work as one, and it updates itself over the air.

> **Status:** early development. The foundation is being built and tested in a virtual machine.

## What's in it today

- Fedora KDE Plasma 45, image-based (atomic), with media codecs and Flathub, using the Universal Blue base
- Mac-style layout: a menu bar on top, a dock at the bottom, and window buttons on the left
- KDE Connect pre-installed for phone integration
- Automatic over-the-air updates, with rollback

## How updates work

1. A change is merged into `main` (only through a pull request with a passing build).
2. GitHub Actions builds a new image, signs it with the key in [`cosign.pub`](cosign.pub), and publishes it to the **testing** channel: `ghcr.io/c-bibek/chaulagain-os:testing`.
3. Once a week, or by hand at any time, the tested build is promoted to the **stable** channel, `ghcr.io/c-bibek/chaulagain-os:stable`. Real computers follow stable; the test VM follows testing.
4. Installed computers download updates in the background and switch on the next restart.
5. If an update misbehaves, pick the previous entry in the boot menu, or run `sudo bootc rollback`.

The image is also rebuilt every day, so Fedora's security fixes reach testing daily and stable weekly.

Each image also carries its own update address (`/usr/share/chaulagain-os/update-source`). If the image ever moves, an ordinary update ships the new address and every computer follows it, with no manual steps.

## Installing

- To test it in a Hyper-V virtual machine, follow [docs/install-hyperv.md](docs/install-hyperv.md).
- Our own installer ISO (**Actions → Build disk images**) doesn't build for Fedora 45 yet. Until it does, install [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/download) and switch it to Chaulagain OS: `sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/c-bibek/chaulagain-os:stable`, restart, then run `plasma-apply-lookandfeel --apply org.chaulagain.desktop --resetLayout` for the Chaulagain OS layout.
- If you already run Fedora Atomic or another bootc system: `sudo bootc switch ghcr.io/c-bibek/chaulagain-os:stable`

## Roadmap

The full plan is in [ROADMAP.md](ROADMAP.md). It covers a feature-by-feature comparison with macOS, the native phone integration design, Time Machine-style backups, the Chaulagain Store, and the build phases:

0. **Foundation** (now): automatic builds, installer, over-the-air updates, basic Mac-style layout
1. **Install-time decisions**: snapshot-ready disk format, encryption, default apps
2. **Backups**: hourly snapshots and scheduled backups to a USB drive or NAS
3. **Phone integration**, built into the OS: menu bar, file manager, Share menu, notifications, mirroring
4. **Mac-inspired design**
5. **Chaulagain Store** for optional apps
6. **Extras**: our own Pixel app, Auto Unlock, AI assistant
7. **Production install**

## What's where

| Path | What it is |
|---|---|
| `Containerfile` | The recipe: base image plus the build script |
| `build_files/build.sh` | Packages, branding and desktop defaults |
| `system_files/` | Files copied into the OS as they are |
| `disk_config/iso.toml` | Installer settings |
| `.github/workflows/` | Builds: the image (daily and on every merge) and the installer (on demand) |
| `tools/` | Helper scripts, such as creating the Hyper-V test VM |

## Credits

Built with the [Universal Blue image template](https://github.com/ublue-os/image-template), on [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/) and [bootc](https://github.com/bootc-dev/bootc). Chaulagain OS is not affiliated with Apple.
