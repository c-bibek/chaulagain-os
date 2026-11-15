# Chaulagain OS: notes for AI coding sessions

## Working with the owner
- The owner relies on Claude for all of the engineering. Explain things in plain language, recommend one option instead of listing many, and say clearly what the owner must do themselves (installing things on Windows, clicking in a VM, judging the look).
- Every change goes on a branch, then a pull request (the PR build checks it), then a merge into `main` (which publishes it). Never push straight to `main`.

## Goals
1. A macOS-inspired look and feel. It must be *inspired by* macOS, never copied: no Apple logo, no Apple names (macOS, Finder, …), no Apple wallpapers, no SF fonts.
2. The owner's Pixel phone and the computer should work as one. KDE Connect is the core, with scrcpy for mirroring, Google Messages web, and Pixel webcam mode.
3. Over-the-air updates: a merge into `main` reaches installed machines on their next restart, with no reinstall.

## Decisions so far
- **Base:** `ghcr.io/ublue-os/kinoite-main:45`, which is Fedora KDE atomic plus codecs and Flathub. The base image already turns on staged automatic updates (`rpm-ostreed-automatic.timer`) and Flatpak update timers.
- **Desktop:** KDE Plasma, because KDE Connect is built into it.
- **Hosting:** the public GitHub repo `c-bibek/chaulagain-os`, with the image at `ghcr.io/c-bibek/chaulagain-os:latest`. The image is rebuilt daily and on every push to `main`.
- **Signing:** `SIGNING_SECRET` holds a P-256 PEM private key made with OpenSSL. CI converts it with `cosign import-key-pair`, then signs. The public key is in `cosign.pub` and is also shipped at `/etc/pki/containers/chaulagain-os.pub`. Installed systems do **not** enforce signatures yet. That's planned as an OTA change, to be tested in the VM first (rolling back is safe because the previous deployment has no enforcement).
- **Installer:** an Anaconda ISO built on demand by `build-disk.yml`. Its kickstart runs `bootc switch` to our image.

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
1. Foundation: builds, signing, ISO, OTA verified in the VM
2. Phone: pairing at first boot (QR code), a Phone menu in the top bar (battery, photos, messages, mirror, send file, ring), Send to Pixel in Share menus
3. Full Mac-inspired design: theme (start from WhiteSur, then customise), Inter font, dock polish, startup screen, wallpapers, logo
4. A companion Android app (a KDE Connect fork, branded) and polish
