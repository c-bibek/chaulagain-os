# Chaulagain OS
#
# The build script and our system files sit in a throwaway stage, so they are
# available during the build without being copied into the finished image.
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# Base: Fedora KDE Plasma (Kinoite) with Universal Blue's extras
# (media codecs, automatic staged updates, Flathub).
# Moving to a new Fedora release = change this tag, then test in the VM first.
FROM ghcr.io/ublue-os/kinoite-main:45

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

# Check that the finished image is a valid bootable image
RUN bootc container lint
