# Security Policy

## Reporting a vulnerability

Please report suspected vulnerabilities privately, using the **Report a vulnerability** button on the Security tab of the repository concerned. If that button is not there, or you would rather not go through GitHub, email david.anderson@excelano.com instead. I aim to respond within seven days.

Please do not open public issues for security problems.

## Supported versions

The latest release receives security fixes. Older versions are not supported.
A fix ships in a new release; update the way you installed.

## What slipcase-common can access

Nothing. slipcase-common is data: a shared-mime-info declaration and the SVG
icons it names. It carries no executable, and the package carries no
maintainer scripts. It makes no network call, reads nothing, and never runs.

What it does is change how a file manager classifies and draws files.
`mime/slipcase.xml` types any file named `*.slpc` as a Slipcase container, and
a file named `*.pdf.slpc` or with another listed content extension as one of
the content families, purely from its name. That classification is a hint and
never a verdict: a container named `invoice.pdf.slpc` that holds something
other than a PDF still draws with the PDF mark, and the application that opens
it is what says what is inside. The package ships no thumbnailer, so browsing a
directory of containers runs nothing against them.

## What slipcase-common stores

The package installs `/usr/share/mime/packages/slipcase.xml` and the icons
under `/usr/share/icons/hicolor/scalable/mimetypes/`, plus its README, license
and changelog under `/usr/share/doc/slipcase-common/`. The mime and icon caches
are rebuilt by the triggers of the packages that own them.

`install.sh` writes the same declaration and icons under a prefix, `~/.local`
by default, and runs `update-mime-database` and `gtk-update-icon-cache` on that
prefix where they are present. `uninstall.sh` removes them from the prefix it is
given. Neither writes anywhere else.

## Verifying releases

Every GitHub release carries the `.deb`, built by `build-release`, the release
program in excelano/shipping, from the tagged commit with
`debian/build-deb.sh` in this repository, which is public and auditable. The
release attaches no checksum file, so a download from it is vouched for only by
where it came from. Packages served from the Excelano apt repository are
signed; https://excelano.com/apt/ has the key and the one-line setup.
