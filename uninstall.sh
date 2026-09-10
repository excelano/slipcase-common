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

rm -f "${prefix}/share/mime/packages/slipcase.xml"

# A pattern rather than the contents of this checkout's `icons/`, because the
# checkout doing the removing is not necessarily the one that did the
# installing. Every name this package has ever written begins the same way.
rm -f "${prefix}"/share/icons/hicolor/scalable/mimetypes/application-x.slipcase*.svg

[ -x "$(command -v update-mime-database || true)" ] &&
    update-mime-database "${prefix}/share/mime" || true
[ -x "$(command -v gtk-update-icon-cache || true)" ] &&
    gtk-update-icon-cache -q -t -f "${prefix}/share/icons/hicolor" || true

echo "removed the Slipcase media type and its icons from ${prefix}"
