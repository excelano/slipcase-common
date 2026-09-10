#!/bin/sh
# Install the Slipcase media type and its icon into a prefix, which defaults to
# ~/.local.
#
# For a person installing by hand and for testing an association without
# building packages. The Excelano apt repository ships the same two files as
# `slipcase-common`, and the two must agree about where things go.
#
# Author: David M. Anderson
# Built with AI assistance (Claude, Anthropic)
set -eu

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
prefix="${HOME}/.local"

while [ $# -gt 0 ]; do
    case "$1" in
        --prefix) prefix="${2:?--prefix needs a directory}"; shift 2 ;;
        -h|--help)
            echo "usage: install.sh [--prefix DIR]   (default: ~/.local)"; exit 0 ;;
        *) echo "install.sh: unknown argument $1" >&2; exit 2 ;;
    esac
done

mkdir -p "${prefix}/share/mime/packages" \
         "${prefix}/share/icons/hicolor/scalable/mimetypes"

install -m 0644 "${here}/mime/slipcase.xml" \
    "${prefix}/share/mime/packages/slipcase.xml"
# Every drawing in `icons/` rather than a list of them, so that a payload
# family added to `mime/slipcase.xml` brings its icon along without this script
# being told about it.
for icon in "${here}"/icons/*.svg; do
    install -m 0644 "$icon" \
        "${prefix}/share/icons/hicolor/scalable/mimetypes/$(basename "$icon")"
done

# Each is absent on a minimal system and each failure is survivable: the files
# are in place either way, and the next login or the next package installation
# rebuilds these caches.
[ -x "$(command -v update-mime-database || true)" ] &&
    update-mime-database "${prefix}/share/mime" || true
[ -x "$(command -v gtk-update-icon-cache || true)" ] &&
    gtk-update-icon-cache -q -t -f "${prefix}/share/icons/hicolor" || true

echo "installed the Slipcase media type and its icons under ${prefix}"
echo
echo "check it with:"
echo "  xdg-mime query filetype SOME.slpc     # application/x.slipcase+zip"
echo
echo "An empty file answers application/x-zerosize whatever the glob says, so"
echo "check against a real container."
