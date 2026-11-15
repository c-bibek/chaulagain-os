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

1. Open <https://github.com/c-bibek/chaulagain-os/actions/workflows/build-disk.yml>.
2. Click the newest run with a green check mark that was built for the **testing** channel (the test VM follows testing). Scroll to **Artifacts** and download `chaulagain-os-testing-installer`. It's a large zip of several GB.
3. Unzip it. The installer is the `install.iso` file inside the `bootiso` folder.
4. Download the setup script from <https://github.com/c-bibek/chaulagain-os/blob/main/tools/New-ChaulagainVM.ps1> with the **Download raw file** button (the down-arrow icon). Save it in **Downloads**.

## Step 3: Create the virtual machine

1. Press **Start**, type **PowerShell**, right-click **Windows PowerShell**, and choose **Run as administrator**.
2. Paste this and press Enter. Change the path if your `install.iso` is somewhere else:

   ```powershell
   cd $env:USERPROFILE\Downloads
   powershell -ExecutionPolicy Bypass -File .\New-ChaulagainVM.ps1 -IsoPath "$env:USERPROFILE\Downloads\bootiso\install.iso"
   ```

The script:

- creates an **External** network switch, so your phone can find the VM on your home network. Your internet drops for a few seconds while this is set up.
- creates a VM named **Chaulagain OS** with 4 CPUs, 8 GB of memory and a 64 GB disk
- sets up Secure Boot so Linux can start
- starts the VM and opens its window

`-ExecutionPolicy Bypass` lets this one script run without changing any Windows setting.

## Step 4: Install

In the VM window:

1. Choose **Install Chaulagain OS** (it may say Fedora) and press Enter, or just wait.
2. Pick your **language**.
3. **Installation Destination:** select the VM's disk (there's only one) and keep **Automatic**. Automatic formats the disk as Btrfs, which Chaulagain OS needs for Time Machine-style snapshots.
4. **User Creation:** enter your name and a password, and tick **Make this user administrator**.
5. Click **Begin Installation** and wait about 10–20 minutes.
6. Click **Reboot System**. The VM starts Chaulagain OS on its own. You don't need to remove the installer.

## Step 5: First login: check it worked

After logging in you should see a **menu bar across the top** and a **dock at the bottom**, with window buttons on the **left**.

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
