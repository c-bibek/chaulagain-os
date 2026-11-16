# Sourced by Plasma before the desktop starts. Tells brand-new users apart
# from existing ones for Chaulagain OS settings updates (see
# /usr/libexec/chaulagain-user-migrations). Never stops the login.
/usr/libexec/chaulagain-user-migrations --prepare >/dev/null 2>&1 || true
