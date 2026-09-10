#!/bin/sh
# Build the package the Excelano apt repository ships: two data files and a
# control file.
#
# A binary package rather than a source package, and `Architecture: all`. There
# is nothing here to compile — the same reasoning `slipcase-desktop` records for
# assembling its archive from a staging tree rather than from `debian/rules`,
# with less to assemble.
#
# Author: David M. Anderson
# Built with AI assistance (Claude, Anthropic)
set -eu

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "${here}/.." && pwd)
outdir="${root}/dist"

while [ $# -gt 0 ]; do
    case "$1" in
        --outdir) outdir="${2:?--outdir needs a directory}"; shift 2 ;;
        -h|--help) echo "usage: build-deb.sh [--outdir DIR]"; exit 0 ;;
        *) echo "build-deb.sh: unknown argument $1" >&2; exit 2 ;;
    esac
done

version=$(sed -n '1s/.*(\(.*\)).*/\1/p' "${here}/changelog")
[ -n "$version" ] || { echo "build-deb.sh: no version in debian/changelog" >&2; exit 1; }

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
# `mktemp -d` makes it 0700 and that becomes the archive's entry for `/`.
# Harmless where dpkg declines to apply it and not worth relying on.
chmod 0755 "$stage"

install -D -m 0644 "${root}/mime/slipcase.xml" \
    "${stage}/usr/share/mime/packages/slipcase.xml"
for icon in "${root}"/icons/*.svg; do
    install -D -m 0644 "$icon" \
        "${stage}/usr/share/icons/hicolor/scalable/mimetypes/$(basename "$icon")"
done
install -D -m 0644 "${root}/README.md" \
    "${stage}/usr/share/doc/slipcase-common/README.md"
install -D -m 0644 "${root}/LICENSE" \
    "${stage}/usr/share/doc/slipcase-common/copyright"

# Policy 12.7 wants the changelog under `usr/share/doc`, compressed, and
# lintian reports its absence as an error rather than a warning. `changelog.gz`
# and not `changelog.Debian.gz` because this is a native package: the version in
# `debian/changelog` carries no Debian revision, so there is no upstream
# changelog for a Debian one to sit beside.
#
# `-9n` rather than plain `gzip`: the highest compression because lintian asks
# for it, and no stored name or timestamp so that building the same source twice
# gives the same bytes.
gzip -9nc "${here}/changelog" > "${stage}/usr/share/doc/slipcase-common/changelog.gz"
chmod 0644 "${stage}/usr/share/doc/slipcase-common/changelog.gz"

size=$(du -ks "$stage" | cut -f1)
mkdir -p "${stage}/DEBIAN"
sed -e "s/@VERSION@/${version}/" -e "s/@SIZE@/${size}/" \
    "${here}/control.in" > "${stage}/DEBIAN/control"

mkdir -p "$outdir"
deb="${outdir}/slipcase-common_${version}_all.deb"
dpkg-deb --build --root-owner-group "$stage" "$deb" >/dev/null
echo "$deb"

# Read every time rather than trusted. The whole package is the media type and
# the drawings it names, and a package that installs neither is one that does
# nothing.
echo
dpkg-deb -c "$deb"
