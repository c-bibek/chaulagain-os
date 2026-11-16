# Chaulagain OS: notes for AI coding sessions

## Working with the owner
- The owner relies on Claude for all of the engineering. Explain things in plain language, recommend one option instead of listing many, and say clearly what the owner must do themselves (installing things on Windows, clicking in a VM, judging the look).
- Every change goes on a branch, then a pull request (the PR build checks it), then a merge into `main` (which publishes it). `main` is protected, admins included: it needs a pull request and a passing `Build and push image` check, so pull requests must always run that build.

## Goals
1. A macOS-inspired look and feel. It must be *inspired by* macOS, never copied: no Apple logo, no Apple names (macOS, Finder, …), no Apple wallpapers, no SF fonts.
2. The owner's Pixel phone and the computer should work as one. KDE Connect is the core, with scrcpy for mirroring, Google Messages web, and Pixel webcam mode.
3. Over-the-air updates: a merge into `main` reaches installed machines on their next restart, with no reinstall.

## Decisions so far
- **Base:** `ghcr.io/ublue-os/kinoite-main:45`, which is Fedora KDE atomic plus codecs and Flathub. The base image already turns on staged automatic updates (`rpm-ostreed-automatic.timer`) and Flatpak update timers.
- **Desktop:** KDE Plasma, because KDE Connect is built into it.
- **Hosting:** the public GitHub repo `c-bibek/chaulagain-os`, with the image at `ghcr.io/c-bibek/chaulagain-os` (channels below). The image is rebuilt daily and on every push to `main`.
- **Hosting stays on the personal account `c-bibek`** (the owner chose this). Installed computers follow `ghcr.io/c-bibek/chaulagain-os`, so the account must never be renamed.
- **Encryption:** off by default (the owner chose this).
- **Signing:** `SIGNING_SECRET` holds a P-256 PEM private key made with OpenSSL. The owner keeps a backup in their password manager; never print or commit it. CI converts it with `cosign import-key-pair`, then signs. The public key is in `cosign.pub` and is also shipped at `/etc/pki/containers/chaulagain-os.pub`. Installed systems do **not** enforce signatures yet. That's planned as an OTA change, to be tested in the VM first (rolling back is safe because the previous deployment has no enforcement).
- **Channels:** builds publish to `:testing` (`DEFAULT_TAG` in `image-template.env`). `promote.yml` copies the testing digest to `:stable` weekly (Mondays) or on demand, which keeps the signature valid. Real computers follow stable, and the test VM follows testing. There is no `:latest` any more.
- **Escape hatch:** `/usr/share/chaulagain-os/update-source` holds the image address without a tag. `chaulagain-update-source.timer` runs `/usr/libexec/chaulagain-update-source`, which moves the computer (same tag) when the address changes. To move the image, ship the new address in an update that is published at both the old and new addresses. Test the script with `CHAULAGAIN_DRY_RUN=1 CHAULAGAIN_CURRENT_IMAGE=…`.
- **Installer:** an Anaconda ISO built on demand by `build-disk.yml`, with a `channel` input. The kickstart in `disk_config/iso.toml` has an `@CHANNEL@` placeholder that the workflow fills in, so the file can't be used for a local build as it is. The disk format is Btrfs: the image declares it in `/usr/lib/bootc/install/00-chaulagain-os.toml`, `build-disk.yml` passes `--rootfs btrfs` (bootc-image-builder refuses to build without a default root filesystem, and `kinoite-main` doesn't set one), and Fedora's "Automatic" partitioning defaults to Btrfs. There is no kickstart partitioning, so the installer stays interactive and safe for dual boot.
- **Installer and Fedora 45:** Fedora 45 moved repo files to `/usr/share/dnf5/repos.d`, but bootc-image-builder's anaconda-iso reads only `/etc/yum.repos.d` (osbuild/image-builder#2704). `build-disk.yml` therefore builds the ISO from a derived copy of the channel image with the repo files copied into `/etc`, and runs bootc-image-builder with `podman run` directly (the old action is deprecated). Remove the workaround once upstream fixes it, or move to image-builder's ISO flow. The backup route is the official Fedora Kinoite ISO plus `rpm-ostree rebase ostree-unverified-registry:ghcr.io/c-bibek/chaulagain-os:<channel>`.

## Changing the look or settings for people who already installed
- **System-wide defaults** (`/etc/xdg/*`, written in `build.sh`) reach every user who hasn't changed that setting themselves. Use these first.
- **Anything else** (panel and dock layout, per-user config, resetting a choice): add `system_files/usr/share/chaulagain-os/user-migrations/NNNN-short-name.sh` with the next number. `/usr/libexec/chaulagain-user-migrations` runs each script once per user, in order, after their next login (from autostart, phase 2, after plasmashell). It stops at a failure and retries at the next login, so scripts must be safe to run again.
- Brand-new users skip all existing scripts, because they already get the current defaults. This is decided before the desktop starts, by `/etc/xdg/plasma-workspace/env/chaulagain-user-migrations.sh`, based on whether `~/.config/plasma-org.kde.plasma.desktop-appletsrc` exists yet.
- `0001-apply-chaulagain-layout.sh` gives users who existed before Chaulagain OS (for example, after switching from Fedora Kinoite) our layout.
- Test the runner locally with `CHAULAGAIN_MIGRATIONS_DIR=<dir> HOME=<fake home> bash system_files/usr/libexec/chaulagain-user-migrations --prepare|--run`.
- The first-login layout itself lives in the look-and-feel package. Change it there and add a migration if existing users should get the change too.

## Desktop defaults: important
- The default layout comes from the look-and-feel package `org.chaulagain.desktop` in `system_files/usr/share/plasma/look-and-feel/`. Plasma applies it **only on a user's first login**.
- To change things for users who already exist, add a Plasma update script under `/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/`. It runs once per user.
- `build.sh` writes system defaults to `/etc/xdg` and to Fedora's kde-settings profile, so ours take priority.

## Testing setup
- Development testing happens in a Hyper-V VM on the owner's second Windows laptop, which keeps Windows for now. `tools/New-ChaulagainVM.ps1` creates the VM, and `docs/install-hyperv.md` is the guide.
- Hyper-V limits: no GPU acceleration (effects look choppy), no USB or Bluetooth passthrough, no touchpad gestures. Wi-Fi phone features need the External switch.
- Real-hardware testing comes later, from an external SSD, so the internal Windows drive is never touched.
- Don't build images locally on the owner's main laptop, which is short on disk space. GitHub Actions does the builds.

## Known limits (tell the owner, don't promise them)
- Toggling the phone's hotspot from the PC isn't possible without root on the phone.
- Phone calls through the PC (Bluetooth HFP) are unreliable on Linux.
- Phone-to-PC clipboard needs a tap, because Android blocks background clipboard access.
- Mac `.dmg` apps can't run. Point to Linux versions or alternatives on Flathub instead.
- `scrcpy` isn't in the Fedora repos, so it needs another source (a COPR or an upstream build) in the phone phase.

## Roadmap
`ROADMAP.md` is the source of truth: the macOS comparison, designs, build phases (0–7) and open questions. Read it before planning work, tick its checkboxes as phases land, and update it when a decision changes.

Key product decisions recorded there:
- **Phone integration is native.** It ships inside the OS image (menu bar panel, file manager, Share menu, notifications, camera picker, Settings page), never as a store app. The phone side needs one background app (KDE Connect, later our own).
- **Backups:** the system needs none (the recipe plus rollback). User files get hourly Btrfs snapshots and scheduled Borg backups (Pika Backup first). This needs the installer to use Btrfs, so decide it before the first real install.
- **Chaulagain Store:** our own Flatpak repository shown in Discover, for optional apps only.
