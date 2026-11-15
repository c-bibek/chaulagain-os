#!/bin/bash
# Chaulagain OS image build script.
# Runs once inside the image during every build on GitHub.

set -ouex pipefail

FEDORA_VERSION="$(rpm -E %fedora)"

### 1. Our files: desktop layout, settings, signing key
cp -avf /ctx/system_files/. /

### 2. Packages
# kde-connect      phone link: files, photos, notifications, clipboard, texts
# android-tools    adb, used for phone screen mirroring
# rsms-inter-fonts clean Mac-like interface font, used by the design phase
dnf5 install -y \
    kde-connect \
    android-tools \
    rsms-inter-fonts

### 3. Name the system "Chaulagain OS"
# ID stays "fedora" so Fedora's tools and repositories keep working.
set_os_release() {
    local key="$1" value="$2" file=/usr/lib/os-release
    if grep -q "^${key}=" "$file"; then
        sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$file"
    else
        echo "${key}=\"${value}\"" >> "$file"
    fi
}
set_os_release NAME "Chaulagain OS"
set_os_release PRETTY_NAME "Chaulagain OS ${FEDORA_VERSION}"
set_os_release VARIANT "Chaulagain OS"
set_os_release VARIANT_ID "chaulagain-os"
set_os_release DEFAULT_HOSTNAME "chaulagain-os"
set_os_release HOME_URL "https://github.com/c-bibek/chaulagain-os"
set_os_release DOCUMENTATION_URL "https://github.com/c-bibek/chaulagain-os#readme"
set_os_release SUPPORT_URL "https://github.com/c-bibek/chaulagain-os/issues"
set_os_release BUG_REPORT_URL "https://github.com/c-bibek/chaulagain-os/issues"

### 4. Mac-style desktop defaults
# KDE reads system-wide defaults from /etc/xdg. Fedora also keeps defaults in
# its kde-settings profile, so we write to both to make sure ours win.
command -v kwriteconfig6 >/dev/null || dnf5 install -y /usr/bin/kwriteconfig6
KDE_DEFAULT_DIRS=(/etc/xdg)
if [[ -d /usr/share/kde-settings/kde-profile/default/xdg ]]; then
    KDE_DEFAULT_DIRS+=(/usr/share/kde-settings/kde-profile/default/xdg)
fi
kde_default() { # file group key value
    local dir
    for dir in "${KDE_DEFAULT_DIRS[@]}"; do
        kwriteconfig6 --file "${dir}/$1" --group "$2" --key "$3" "$4"
    done
}

# Our desktop layout (menu bar on top, dock at the bottom) for new users.
# It lives in /usr/share/plasma/look-and-feel/org.chaulagain.desktop
kde_default kdeglobals KDE LookAndFeelPackage org.chaulagain.desktop

# Window buttons on the left like a Mac: close, minimize, zoom
kde_default kwinrc org.kde.kdecoration2 ButtonsOnLeft XIA
kde_default kwinrc org.kde.kdecoration2 ButtonsOnRight ""

### 5. Updates
# Automatic background updates (system + apps) and Flathub come from the
# base image: rpm-ostreed-automatic.timer stages each new Chaulagain OS
# version, and it is applied on the next restart.
