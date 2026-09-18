#!/bin/sh
# Undo install.sh.
#
# Removing this takes the file type away from every Slipcase product on the
# machine at once, which is the other side of one package owning it.
#
# Author: David M. Anderson
# Built with AI assistance (Claude, Anthropic)
set -eu

prefix="${HOME}/.local"

while [ $# -gt 0 ]; do
    case "$1" in
        --prefix) prefix="${2:?--prefix needs a directory}"; shift 2 ;;
        -h|--help) echo "usage: uninstall.sh [--prefix DIR]"; exit 0 ;;
        *) echo "uninstall.sh: unknown argument $1" >&2; exit 2 ;;
    esac
done

# Two names, because a prefix can hold either. The declaration installs as
# `slipcase.xml`, and hand installs on some machines hold it as
# `application-x.slipcase+zip.xml`. Leaving one behind is not inert: a prefix
# XDG searches earlier shadows a later one, and the shadowing is whole rather
# than per-glob, so a stale `*.slpc` in ~/.local is taken and the payload family
# globs in /usr are never reached. Every container draws with the plain icon.
rm -f "${prefix}/share/mime/packages/slipcase.xml" \
      "${prefix}/share/mime/packages/application-x.slipcase+zip.xml"

# A pattern rather than the contents of this checkout's `icons/`, because the
# checkout doing the removing is not necessarily the one that did the
# installing. It matches on `slipcase` rather than on the prefix, so it covers
# the container drawing and the five payload families whatever tree their types
# sit in, and a prefix written to under an older name as well.
rm -f "${prefix}"/share/icons/hicolor/scalable/mimetypes/application-*slipcase*.svg

[ -x "$(command -v update-mime-database || true)" ] &&
    update-mime-database "${prefix}/share/mime" || true
[ -x "$(command -v gtk-update-icon-cache || true)" ] &&
    gtk-update-icon-cache -q -t -f "${prefix}/share/icons/hicolor" || true

echo "removed the Slipcase media type and its icons from ${prefix}"
