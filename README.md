# Chaulagain OS

A macOS-inspired desktop operating system built on Fedora KDE Plasma. It's designed so your Pixel phone and your computer work as one, and it updates itself over the air.

> **Status:** early development. The foundation is being built and tested in a virtual machine.

## What's in it today

- Fedora KDE Plasma 45, image-based (atomic), with media codecs and Flathub, using the Universal Blue base
- Mac-style layout: a menu bar on top, a dock at the bottom, and window buttons on the left
- KDE Connect pre-installed for phone integration
- Automatic over-the-air updates, with rollback

## How updates work

1. A change is merged into `main`.
2. GitHub Actions builds a new image and publishes it to `ghcr.io/c-bibek/chaulagain-os:latest`, signed with the key in [`cosign.pub`](cosign.pub).
3. Installed computers download it in the background and switch to it on the next restart.
4. If an update misbehaves, pick the previous entry in the boot menu, or run `sudo bootc rollback`.

The image is also rebuilt every day, so Fedora's security fixes arrive automatically.

## Installing

- To test it in a Hyper-V virtual machine, follow [docs/install-hyperv.md](docs/install-hyperv.md).
- The installer ISO is built on demand: **Actions → Build disk images → Run workflow**. Download it from that run's **Artifacts**.
- If you already run Fedora Atomic or another bootc system: `sudo bootc switch ghcr.io/c-bibek/chaulagain-os:latest`

## Roadmap

1. **Foundation** (now): automatic builds, installer, over-the-air updates, basic Mac-style layout
2. **Phone integration**: pair at setup, a Phone menu in the top bar, mirroring, file and photo sharing
3. **Full Mac-inspired design**: dock, menu bar, icons, startup screen
4. **Companion phone app and polish**

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
