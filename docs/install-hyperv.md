# Install Chaulagain OS in a Hyper-V virtual machine

This guide is for testing Chaulagain OS on a Windows laptop without touching Windows. You install it **once**. After that, new versions arrive on their own and apply on the next restart.

**Time needed:** about 30–45 minutes, mostly waiting.

## What you need

- A Windows laptop running **Windows 10 or 11 Pro, Enterprise or Education** (Hyper-V isn't included in Windows Home)
- **8 GB of memory** or more (16 GB is better)
- **About 70 GB of free disk space** (the VM's disk grows only as it's used, up to 64 GB)
- A GitHub account, signed in on that laptop's browser, to download the installer

## Step 1: Turn on Hyper-V (one time)

1. Press **Start**, type **Turn Windows features on or off**, and open it.
2. Tick **Hyper-V** (both parts inside it), then click **OK**.
3. Restart when Windows asks.

If Hyper-V is already ticked, skip this step.

## Step 2: Download the installer and the setup script

Our own Chaulagain OS installer doesn't build yet (see the roadmap). For now, you install **Fedora Kinoite**, the official Fedora system that Chaulagain OS is built on, and switch it to Chaulagain OS with one command in Step 5. The result is the same system.

1. Download the **Fedora Kinoite 45** installer from Fedora's official site: <https://fedoraproject.org/atomic-desktops/kinoite/download>. Pick the x86_64 ISO, a file named like `Fedora-Kinoite-Installer-45-….x86_64.iso` (a few GB), and save it in **Downloads**.
2. Download the setup script from <https://github.com/c-bibek/chaulagain-os/blob/main/tools/New-ChaulagainVM.ps1> with the **Download raw file** button (the down-arrow icon). Save it in **Downloads**.

Once our own installer works, you'll download `chaulagain-os-testing-installer` from **Actions → Build disk images** instead, and skip Step 5.

## Step 3: Create the virtual machine

1. Press **Start**, type **PowerShell**, right-click **Windows PowerShell**, and choose **Run as administrator**.
2. Paste this and press Enter. It finds the Fedora Kinoite ISO in your Downloads folder:

   ```powershell
   cd $env:USERPROFILE\Downloads
   $iso = (Get-ChildItem "$env:USERPROFILE\Downloads\Fedora-Kinoite-*.iso" | Select-Object -First 1).FullName
   powershell -ExecutionPolicy Bypass -File .\New-ChaulagainVM.ps1 -IsoPath $iso
   ```

The script:

- creates an **External** network switch, so your phone can find the VM on your home network. Your internet drops for a few seconds while this is set up.
- creates a VM named **Chaulagain OS** with 4 CPUs, 8 GB of memory and a 64 GB disk
- sets up Secure Boot so Linux can start
- starts the VM and opens its window

`-ExecutionPolicy Bypass` lets this one script run without changing any Windows setting.

## Step 4: Install

In the VM window:

1. Choose **Install Fedora Kinoite** and press Enter, or just wait.
2. Pick your **language**.
3. **Disk:** select the VM's disk (there's only one) and let the installer use the **whole disk automatically**. That formats it as Btrfs, which Chaulagain OS needs for Time Machine-style snapshots. Leave encryption **off**.
4. **Your account:** if the installer asks, enter your name and a password and make the user an **administrator**. If it doesn't ask, it will after the restart.
5. Start the installation and wait about 10–20 minutes.
6. Restart when it's done. The VM starts from its disk on its own; you don't need to remove the installer.

## Step 5: Switch to Chaulagain OS

1. Log in, open **Konsole** (search for it in the app menu), and run this. It asks for your password and downloads Chaulagain OS, which takes about 5–15 minutes:

   ```bash
   sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/c-bibek/chaulagain-os:testing
   ```

2. Restart:

   ```bash
   systemctl reboot
   ```

3. Log in again, open Konsole, and apply the Chaulagain OS layout. Chaulagain OS only applies it automatically to brand-new users, and your user was created on Fedora Kinoite:

   ```bash
   plasma-apply-lookandfeel --apply org.chaulagain.desktop --resetLayout
   ```

## Step 6: Check it worked

You should see a **menu bar across the top** and a **dock at the bottom**, with window buttons on the **left**.

Then open **Konsole** (the terminal icon in the dock) and run these two checks:

```bash
bootc status
```

It should mention `ghcr.io/c-bibek/chaulagain-os:testing`, which means the VM follows the testing channel.

```bash
findmnt -n -o FSTYPE -T /var/home
```

It should print `btrfs`. If it prints anything else, tell Claude before going further: snapshots need Btrfs.

## How updates work

- There are two channels. **Testing** (this VM) gets every change soon after it's merged, plus a daily rebuild with Fedora's fixes. **Stable** (real computers) gets the testing build once a week, or sooner when it's promoted by hand.
- Chaulagain OS checks for updates in the background and downloads them.
- Each update applies the **next time you restart**. Your files and apps stay.
- To get an update right away (for example, when testing a change), run this in Konsole, then restart:

  ```bash
  sudo bootc upgrade
  ```

- **If an update breaks something:** restart, and in the boot menu pick the **second** entry (the previous version). To stay on it, run `sudo bootc rollback`.

## Troubleshooting

| Problem | Fix |
|---|---|
| "Hyper-V is not turned on" | Do Step 1, restart, and run the script again. |
| The VM won't start and mentions Secure Boot | In Hyper-V Manager: VM **Settings → Security**, set the template to **Microsoft UEFI Certificate Authority**. |
| No internet inside the VM | In Hyper-V Manager: **Virtual Switch Manager**, check that **Chaulagain External** is linked to the adapter you're using (Wi-Fi or Ethernet). |
| The screen is small or blurry | Try **System Settings → Display**. Hyper-V's display is limited; it'll look much better on real hardware. |
| Animations feel slow | Expected in Hyper-V, which has no graphics acceleration. Real hardware will be smooth. |

## What a VM can't test

USB phone mirroring, Bluetooth, touchpad gestures and smooth animations need real hardware. We test those later by starting Chaulagain OS from an external SSD, which leaves Windows untouched.
