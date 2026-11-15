# Chaulagain OS roadmap

This is the plan for Chaulagain OS: what it should be, how it compares to macOS, and the order we build it in. Update it whenever a decision changes.

## Vision

A computer that feels like a Mac, works with a Pixel phone the way a Mac works with an iPhone, and keeps itself up to date.

1. **macOS-inspired look and feel.** Inspired by macOS, never copied: no Apple logo, Apple names, Apple wallpapers or Apple fonts.
2. **Phone and computer as one.** The Pixel is built into the OS (menu bar, file manager, Share menu, notifications, camera), not added as a separate app.
3. **Over-the-air updates.** A change merged on GitHub reaches every installed computer on its next restart. No reinstalling.

## Principles

- **The system is a recipe.** The whole OS is built from this repository, so it never needs backing up and every computer gets an identical system.
- **Every update can be undone.** The previous version stays in the boot menu.
- **Test before it ships.** Changes go through a pull request, the test build, and the test VM before being merged.
- **Windows stays untouched** on the test laptops until Chaulagain OS has proven itself.
- **Built in, not bolted on.** Core features (phone, backups, setup) ship inside the OS. The app store is only for optional extras.

## Decisions made

| Area | Decision | Why |
|---|---|---|
| Base | Fedora KDE Plasma, image-based (`ghcr.io/ublue-os/kinoite-main:45`) | Whole-system updates with rollback; codecs and Flathub included |
| Desktop | KDE Plasma | Most customisable; KDE Connect, the phone link, is part of KDE |
| Hosting | Public GitHub repo; image at `ghcr.io/c-bibek/chaulagain-os` | Free building and hosting; the recipe has no personal data |
| Project home | The personal GitHub account `c-bibek`, not an organization | Owner's choice. Installed computers follow this address, so the GitHub username must never be renamed. |
| Updates | Automatic background download, applied on restart | Like macOS Software Update |
| Signing | Every image signed in CI (`cosign.pub`); the owner keeps a backup of the private key in their password manager | Proves updates come from us. Installed systems checking signatures is still to do. |
| Disk encryption | Off by default, as in Fedora | Owner's choice. It can still be turned on for a single computer in the installer. |
| `main` branch | Protected: changes only through pull requests with a passing build | Nothing reaches installed computers by accident |
| Testing | Hyper-V VM on a second Windows laptop, then an external SSD on real hardware | Windows stays untouched |
| Phone features | Built into the OS, not shipped through the store | Native, like a Mac |
| Not chosen: Omarchy | A great keyboard-driven setup, but the opposite of Mac-like | We borrow its ideas instead (see the design phase) |

## Status key

| Mark | Meaning |
|---|---|
| ✅ | In Chaulagain OS now |
| 🧩 | Already exists in Linux; we pre-install and set it up |
| 🛠 | We build it |
| ⚠️ | Only partly possible |
| ❌ | Not possible |

## macOS compared with Chaulagain OS

### Backup and recovery

On a Mac, Time Machine backs up **your files, apps and settings**. macOS itself sits on a sealed system drive and is reinstalled during a restore. Chaulagain OS works the same way: the system half is already covered by the recipe and rollback. The "your stuff" half is the biggest gap.

| macOS | Chaulagain OS | Status |
|---|---|---|
| Time Machine: automatic hourly backups to a USB drive or NAS | Scheduled backups (hourly, daily or weekly) to a USB drive or NAS, encrypted, keeping older versions | 🛠 Start with Pika Backup, then our own settings page |
| Browse and restore older versions of a file | Restore from the backup app, plus "Restore previous version" in the file manager | 🛠 |
| Local snapshots, even with no backup drive connected | Hourly snapshots of your files on the computer's own drive | 🛠 Needs the Btrfs disk format, set in the installer |
| Migration Assistant | A "Restore from backup" step in the welcome setup | 🛠 Later |
| macOS Recovery, going back to an older version | The previous version is in the boot menu; the whole system rolls back | ✅ Better than a Mac |
| Read-only system protection | Read-only system image | ✅ |
| iCloud Drive | Google Drive in the file manager, or Nextcloud | ⚠️ Works, less seamless |
| Find My Mac | — | ❌ |

### Updates and apps

| macOS | Chaulagain OS | Status |
|---|---|---|
| Automatic Software Update | Over-the-air updates from GitHub, applied on restart | ✅ |
| App Store | Discover with Flathub, plus the Chaulagain Store later | ✅ / 🛠 |
| Apps update themselves | Automatic app updates | ✅ |
| Useful apps included from the start | A curated default app set installed automatically, including a browser | 🧩 |
| `.dmg` Mac apps | — | ❌ |
| iPhone apps on the Mac | Android apps through Waydroid | ⚠️ Optional, heavy, not in Hyper-V |

### Desktop, look and feel

| macOS | Chaulagain OS | Status |
|---|---|---|
| Menu bar with each app's menus | Global menu at the top | ✅ Basic (some apps keep their own menus) |
| Dock | Floating dock | ✅ Basic · 🛠 polish · ⚠️ zoom-on-hover isn't built into KDE |
| Colored window buttons on the left | Buttons on the left | ✅ Position · 🛠 colored circles |
| Spotlight | KRunner: apps, files, calculator, unit conversions | ✅ · 🛠 Cmd+Space-style shortcut, centered look |
| Mission Control and Spaces | Overview and virtual desktops | ✅ |
| Stage Manager | — | ⚠️ No direct equivalent |
| Launchpad | Full-screen app grid | 🧩 |
| Quick Look (space-bar preview) | Preview panel in the file manager | ⚠️ · 🛠 Space-bar preview |
| Control Center | Quick settings in the menu bar | ✅ Works · 🛠 Mac-style grouped panel |
| Notification Center and widgets | Notifications and desktop widgets | ✅ |
| Hot corners | Screen edges | ✅ |
| Trackpad gestures | 3- and 4-finger gestures | ✅ · ⚠️ Fewer than a Mac |
| Night Shift | Night Light | ✅ |
| Automatic dark mode | Switch light and dark by time of day | 🛠 Small |
| Mac keyboard shortcuts (Cmd+C, Cmd+Q, Cmd+Space) | The Windows key acts as Cmd | 🛠 Optional |
| Screenshots (Cmd+Shift+3/4/5) and screen recording | Spectacle | ✅ · 🛠 Mac shortcuts |
| Fonts, icons, wallpapers, startup logo | Our own design | 🛠 |
| Setup Assistant | Welcome setup with phone pairing by QR code | 🛠 |

### Built-in apps

| macOS | Chaulagain OS | Status |
|---|---|---|
| Finder | Dolphin (tabs, split view, tags) | ✅ |
| Safari | Firefox or Chrome | 🧩 |
| Mail, Calendar, Contacts | Thunderbird with Google sync | 🧩 |
| Messages | Google Messages (works with RCS), built in | 🛠 Phone phase |
| FaceTime | Google Meet or WhatsApp | ⚠️ |
| Photos | digiKam or a Google Photos app, plus automatic import from the Pixel | 🧩 + 🛠 |
| Notes, Reminders | Google Keep or Joplin | 🧩 |
| Preview (PDFs: sign, annotate) | Okular | 🧩 |
| Pages, Numbers, Keynote | LibreOffice or OnlyOffice | 🧩 |
| Terminal, TextEdit, Calculator | Konsole, KWrite, KCalc | ✅ / 🧩 |
| Activity Monitor, Disk Utility | System Monitor, Partition Manager | ✅ / 🧩 |
| QuickTime, Music | Haruna or VLC, Spotify | 🧩 |
| Siri, Apple Intelligence | An AI assistant built in | ⚠️ · 🛠 Later |
| Dictation | Offline speech-to-text | 🛠 Later |
| Shortcuts / Automator | Custom shortcuts and scripts | ⚠️ No visual automation app |

### iPhone + Mac → Pixel + Chaulagain OS

| Apple feature | Chaulagain OS | Status |
|---|---|---|
| AirDrop | Send to and from the phone | ✅ |
| Phone notifications on the computer | In the normal notification area, with reply | ✅ |
| Find My iPhone (ring it) | Ring the phone | ✅ |
| Messages on the Mac | Google Messages, built in | 🛠 |
| iPhone Mirroring | Phone-shaped mirroring window, opened from the menu bar | 🛠 |
| iCloud Photos | Automatic photo import into a "Pixel" folder | 🛠 |
| Pairing during setup | QR code in the welcome setup | 🛠 |
| Auto Unlock | Unlock with the phone nearby | 🛠 Later, needs care for security |
| Continuity Camera | Pixel webcam mode over USB, listed in the camera picker | 🧩 Real hardware only |
| Keychain passwords | Google Password Manager or Bitwarden | 🧩 |
| Universal Clipboard | Shared clipboard | ⚠️ Phone to computer needs one tap |
| Handoff | Send links and tabs between devices | ⚠️ |
| Sidecar (second screen) | Through remote desktop | ⚠️ Later |
| Phone calls on the Mac | Bluetooth calling | ⚠️ Experimental |
| Instant Hotspot | — | ❌ Android doesn't allow it |

### Security and privacy

| macOS | Chaulagain OS | Status |
|---|---|---|
| FileVault | Full-disk encryption | 🧩 Installer option, decided at install |
| App sandboxing | Flatpak app sandbox | ✅ |
| Signed updates | Signed now | ✅ · 🛠 Installed systems check the signatures |
| Firewall, Secure Boot | Both on | ✅ |
| Touch ID / Face ID | Face login with an infrared camera, or a fingerprint reader | ⚠️ Optional, less secure than Apple's |
| Camera and microphone permission prompts | Only for sandboxed apps | ⚠️ |
| Screen Time | Basic parental controls | ⚠️ |

### Hardware and accessories

| macOS | Chaulagain OS | Status |
|---|---|---|
| AirPrint | Driverless printing | ✅ |
| AirPlay to a TV | Chromecast from Chrome | ✅ (AirPlay ⚠️) |
| AirPods automatic switching | Normal Bluetooth headphones | ✅ (auto-switching ❌) |
| VoiceOver, Zoom | Orca screen reader, zoom | ⚠️ / ✅ |
| Multiple users | Multiple users | ✅ |

### Where Chaulagain OS beats macOS

- A whole system update can be undone with one restart
- The system never needs backing up, because the recipe rebuilds it exactly
- We control what ships, and when
- Runs on any PC, for free
- Deep Android integration, which Apple doesn't offer

### What we accept we can't match

`.dmg` apps, FaceTime and iMessage, AirPods auto-switching, Instant Hotspot, and Apple's Find My network.

## Phone integration design

Like a Mac, the phone is not one app. It appears everywhere it makes sense.

| Place in the OS | What the user sees |
|---|---|
| First startup | The welcome setup shows a QR code; scanning it with the phone pairs it for good |
| Menu bar | A phone icon with the battery level. Click it for: mirror, send file, Messages, ring, recent photos, latest text. |
| Notifications | Phone notifications in the normal notification area, with reply |
| File manager sidebar | The Pixel under Devices, browsable like a USB drive |
| Right-click and Share menus | "Send to Pixel" for files, photos and links |
| Clipboard | Copy on one device, paste on the other |
| Camera picker | The Pixel listed as a camera in Zoom, Meet and others (over USB) |
| Pictures folder | New phone photos appear automatically in a "Pixel" folder |
| System Settings | A "Phone" page: what syncs, features on or off, unpair |
| Phone mirroring | A clean phone-shaped window, from the menu bar or a keyboard shortcut |

**Underneath:**
- KDE Connect's background service handles the connection, files, notifications and clipboard.
- scrcpy is the mirroring engine. It isn't in Fedora's repositories, so it needs another source.
- We build the menu-bar panel, the welcome setup, the file manager and Share menu entries, the Settings page and the photo import.
- Everything ships inside the OS image and updates over the air.

**On the phone:** one app, installed once (KDE Connect at first, our own app later), plus a one-time "Allow" tap for mirroring. After that it runs in the background. Only Google can build features into Android itself.

## Backup design (the Time Machine equivalent)

| Layer | What it does | How |
|---|---|---|
| System | Never needs a backup; previous versions stay in the boot menu | Image-based updates (done) |
| Local snapshots | Hourly snapshots of your files on the computer's own drive, so you can undo mistakes even without a backup drive | Btrfs disk format plus snapper (needs the installer change) |
| Backups | Scheduled, encrypted backups to a USB drive or NAS, keeping hourly, daily and weekly versions | Pika Backup (BorgBackup) at first; our own settings page later |
| Restore | Restore single files, or everything onto a fresh install | The backup app, "Restore previous version" in the file manager, and a restore step in the welcome setup |

## Chaulagain Store design

An app store has three parts:

| Part | What it is | For Chaulagain OS |
|---|---|---|
| The shelf | Where app files and the catalog (names, icons, screenshots) live | Our own Flatpak repository, built and published by GitHub Actions |
| The storefront | Where people browse, install and update | Discover shows "Chaulagain Store" next to Flathub; maybe our own storefront later |
| The trust | Proof that apps come from us | A signing key that Chaulagain OS trusts out of the box |

- **Publishing:** write the app and its store listing → push to GitHub → it's built, signed and published → it appears in the Store on every Chaulagain OS computer and updates itself.
- **For optional apps only.** Core features ship inside the OS.
- **Cost:** free while small (hosted on GitHub); a few dollars a month at most if it grows.
- **Paid apps:** not built in (they need license keys plus a payment service). Free apps first.
- **Flathub:** good apps can also be submitted there to reach every Linux user.

## Build phases

### Phase 0: Foundation (in review)
- [x] Recipe: Fedora KDE base, "Chaulagain OS" name, KDE Connect, Android tools, Inter font
- [x] Basic Mac-style layout: menu bar on top, dock at the bottom, window buttons on the left
- [x] Automatic builds and signing on GitHub
- [x] Installer (ISO) built on demand
- [x] Hyper-V setup script and install guide
- [ ] Merge, publish, build the installer, install in the VM
- [ ] Prove OTA: push a small visible change and see it arrive after a restart

### Phase 1: Before the first real install
These are set when the disk is formatted, or are built into every installed computer, so they come first.
- [x] Full-disk encryption: off by default
- [x] The project stays on the personal account `c-bibek` (never rename it)
- [x] A new signing key, with a backup in the owner's password manager
- [x] `main` protected: pull requests with a passing build only
- [ ] The installer uses the Btrfs disk format (needed for snapshots)
- [ ] Update channels: `stable` for real computers, `testing` for the VM
- [ ] An "escape hatch": a setting shipped inside the OS that can move every computer to a new update address through an update
- [ ] Default apps, including a browser, installed automatically

**Safety checks before installing on real hardware**
- [ ] Two-factor sign-in is on for the GitHub account (it controls every installed computer)
- [ ] For dual boot: Windows BitLocker recovery key saved, files backed up, Windows Fast Startup turned off
- [ ] A drive with enough space for Chaulagain OS (an external SSD keeps Windows untouched)
- [ ] If a laptop belongs to an employer, their rules allow it

### Phase 2: Backups (the Time Machine equivalent)
- [ ] Hourly local snapshots of home folders
- [ ] Scheduled backups to a USB drive or NAS (Pika Backup first)
- [ ] Restore single files ("Restore previous version")
- [ ] Our own backup page in System Settings
- [ ] A "Restore from backup" step in the welcome setup (later)

### Phase 3: Phone integration (native)
- [ ] Background connection, plus pairing by QR code in the welcome setup
- [ ] Menu-bar phone panel
- [ ] File manager entry, "Send to Pixel" in Share menus, shared clipboard
- [ ] Notifications with reply, and Messages built in
- [ ] Phone mirroring window
- [ ] Automatic photo import, and the Pixel in the camera picker (real hardware)
- [ ] "Phone" page in System Settings
- [ ] Real-hardware test from an external SSD: Bluetooth, USB, gestures

### Phase 4: Mac-inspired design
- [ ] Theme: start from WhiteSur, then make it our own (colors, window buttons, Inter font)
- [ ] Dock polish, Spotlight-style search look and shortcut, Mac-style Control Center
- [ ] Icons, wallpapers, logo, startup screen
- [ ] Optional Mac keyboard shortcuts (the Windows key acts as Cmd)
- [ ] Automatic dark mode, space-bar Quick Look
- [ ] The full welcome setup
- [ ] Ideas borrowed from Omarchy: strong default apps, one-click themes (wallpaper, colors and accents together), web apps as real apps (Messages, Photos, YouTube), and update scripts that bring existing users' settings forward

### Phase 5: Chaulagain Store
- [ ] Our own Flatpak repository, built and signed by GitHub Actions
- [ ] Shown in Discover as "Chaulagain Store", trusted out of the box
- [ ] The first app published through it
- [ ] Later: a store website, and maybe our own storefront

### Phase 6: Extras
- [ ] Our own Pixel app (replacing KDE Connect on the phone)
- [ ] Auto Unlock with the phone nearby
- [ ] AI assistant and dictation
- [ ] Android apps (Waydroid), optional
- [ ] Phone or tablet as a second screen

### Phase 7: Production
- [ ] Installed systems check update signatures
- [ ] Everything works on real hardware
- [ ] Back up the computer's own files, then install for real (dual boot or replace Windows)

## Open questions

- [ ] **NAS:** is there one, and which brand? (Decides how backups connect.)
- [ ] **Pixel model:** decides webcam mode and a few features
- [x] **Encryption:** off by default (decided)
- [ ] **Default apps:** which browser, office suite, photos and notes apps
- [ ] **Mac keyboard shortcuts:** use the Windows key as Cmd, or keep Ctrl?
- [ ] **Store:** free apps only, or leave room for paid apps later?
- [ ] **Test laptop:** confirm Windows edition, memory and free disk space for Hyper-V
