<#
.SYNOPSIS
    Creates a Hyper-V virtual machine for testing Chaulagain OS.

.DESCRIPTION
    Run this on the Windows laptop that has Hyper-V, in a PowerShell window
    opened with "Run as administrator". It:

      1. Checks that Hyper-V is turned on and the installer ISO exists.
      2. Creates (or reuses) an "External" virtual switch, so the VM joins your
         home network directly. Your phone needs this to find Chaulagain OS.
      3. Creates a Generation 2 VM with Secure Boot set for Linux, 4 CPUs,
         8 GB of memory and a 64 GB disk that only grows as it's used.
      4. Attaches the installer and starts the VM.

    It changes nothing else on your computer.

.PARAMETER IsoPath
    Full path to the Chaulagain OS installer (.iso) you downloaded.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\New-ChaulagainVM.ps1 -IsoPath "$env:USERPROFILE\Downloads\bootiso\install.iso"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$IsoPath,

    [string]$VMName = "Chaulagain OS",
    [string]$SwitchName = "Chaulagain External",
    [int64]$MemoryBytes = 8GB,
    [int]$ProcessorCount = 4,
    [int64]$DiskBytes = 64GB
)

$ErrorActionPreference = 'Stop'

function Write-Step([string]$Text) {
    Write-Host ""
    Write-Host "==> $Text" -ForegroundColor Cyan
}

# ---------------------------------------------------------------- checks
Write-Step "Checking this computer"

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Please open PowerShell with 'Run as administrator' and run this script again."
}

if (-not (Get-Command New-VM -ErrorAction SilentlyContinue)) {
    throw "Hyper-V is not turned on. Open 'Turn Windows features on or off', tick 'Hyper-V', restart, then run this again."
}

if (-not (Test-Path -LiteralPath $IsoPath)) {
    throw "Can't find the installer at: $IsoPath"
}
$IsoPath = (Resolve-Path -LiteralPath $IsoPath).Path

if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    throw "A VM named '$VMName' already exists. Delete it in Hyper-V Manager first, or add -VMName 'Another name'."
}

# Don't ask for more CPUs or memory than this laptop can spare.
$computer = Get-CimInstance Win32_ComputerSystem
$ProcessorCount = [Math]::Min($ProcessorCount, [int]$computer.NumberOfLogicalProcessors)
$halfOfRam = [int64]([Math]::Floor($computer.TotalPhysicalMemory / 2 / 1GB)) * 1GB
if ($MemoryBytes -gt $halfOfRam) { $MemoryBytes = [Math]::Max($halfOfRam, 4GB) }

$vhdFolder = (Get-VMHost).VirtualHardDiskPath
$vhdPath = Join-Path $vhdFolder "$VMName.vhdx"
$driveLetter = (Split-Path -Qualifier $vhdFolder).TrimEnd(':')
$freeGB = [Math]::Round((Get-PSDrive -Name $driveLetter).Free / 1GB)
Write-Host "CPUs: $ProcessorCount   Memory: $($MemoryBytes / 1GB) GB   Free space on ${driveLetter}: $freeGB GB"

if ($freeGB -lt 70) {
    Write-Warning "Only $freeGB GB free on drive ${driveLetter}:. The VM disk can grow up to $($DiskBytes / 1GB) GB."
    $answer = Read-Host "Continue anyway? (y/n)"
    if ($answer -ne 'y') { return }
}

# ---------------------------------------------------------------- network
Write-Step "Setting up the network"

if (Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue) {
    Write-Host "Using the existing switch '$SwitchName'."
}
else {
    $existing = Get-VMSwitch -SwitchType External -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($existing) {
        $SwitchName = $existing.Name
        Write-Host "Using your existing External switch '$SwitchName'."
    }
    else {
        $adapters = @(Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' })
        if ($adapters.Count -eq 0) {
            throw "No connected network adapter found. Connect to Wi-Fi or Ethernet and run this again."
        }
        # Prefer a cable connection (Ethernet) over Wi-Fi when both are connected.
        $adapter = $adapters | Sort-Object { if ($_.MediaType -eq '802.3') { 0 } else { 1 } } | Select-Object -First 1
        Write-Host "Creating an External switch on '$($adapter.Name)' ($($adapter.InterfaceDescription))."
        Write-Host "Your internet connection will drop for a few seconds while Windows sets it up." -ForegroundColor Yellow
        New-VMSwitch -Name $SwitchName -NetAdapterName $adapter.Name -AllowManagementOS $true | Out-Null
    }
}

# ---------------------------------------------------------------- VM
Write-Step "Creating the virtual machine '$VMName'"

New-VM -Name $VMName -Generation 2 -MemoryStartupBytes $MemoryBytes `
    -NewVHDPath $vhdPath -NewVHDSizeBytes $DiskBytes -SwitchName $SwitchName | Out-Null

Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $false
Set-VMProcessor -VMName $VMName -Count $ProcessorCount
Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false

# Fedora's bootloader is signed with Microsoft's third-party (UEFI CA) key.
Set-VMFirmware -VMName $VMName -EnableSecureBoot On -SecureBootTemplate MicrosoftUEFICertificateAuthority

# ---------------------------------------------------------------- installer
Write-Step "Attaching the installer"

Add-VMDvdDrive -VMName $VMName -Path $IsoPath
# Boot order: hard disk first. It's empty until Chaulagain OS is installed, so
# the first start falls through to the installer; after installing, the VM
# boots straight into Chaulagain OS without removing the ISO.
$hdd = Get-VMHardDiskDrive -VMName $VMName
$dvd = Get-VMDvdDrive -VMName $VMName
$nic = Get-VMNetworkAdapter -VMName $VMName
Set-VMFirmware -VMName $VMName -BootOrder $hdd, $dvd, $nic

# ---------------------------------------------------------------- start
Write-Step "Starting '$VMName'"
Start-VM -Name $VMName
Start-Process vmconnect.exe -ArgumentList 'localhost', "`"$VMName`""

Write-Host ""
Write-Host "Done. The installer is opening in a new window." -ForegroundColor Green
Write-Host "Follow 'Step 4: Install' in docs/install-hyperv.md."
