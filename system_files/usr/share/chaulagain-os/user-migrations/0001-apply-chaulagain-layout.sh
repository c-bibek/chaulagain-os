#!/usr/bin/bash
# 0001: give users who existed before Chaulagain OS (for example, after
# switching from Fedora Kinoite) the Chaulagain OS layout: menu bar on top,
# dock at the bottom. Brand-new users already get it at their first login.
set -euo pipefail
plasma-apply-lookandfeel --apply org.chaulagain.desktop --resetLayout
