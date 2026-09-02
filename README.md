# slipcase-common

The slipcase media type and the icon a container is drawn with, as one package
that every slipcase product on a Linux machine depends on. No executable. The
format is specified at <https://slipcaseformat.org>.

## Why it exists

Two packages cannot ship the same path. dpkg refuses the second install
outright, so two products that both open containers could not each carry the
media type declaration and the icon — and an icon named for a media type *is*
one file at one path, because the name is derived from the type.

They worked around it by having one product ship the icon and the other go
without. That is not a cosmetic loss. A container on a machine with only the
product that went without draws as a blank generic document, which is the first
thing somebody sees of a file format they were sent and did not ask for.

So the type and its icon belong to neither product. They are the specification's,
expressed once, and depended on.

## What is in it

`mime/slipcase.xml` declares `application/x.slipcase+zip` against `*.slpc`, as a
subclass of `application/zip`.
[SPEC §4](https://slipcaseformat.org/spec/#4-file-extension-and-media-type) names
the type and the extension and reserves no magic bytes, so the glob is the only
identification available.

`icons/application-x.slipcase+zip.svg` is the drawing: a card sliding into an
open-topped case, on a 64-unit grid. It came from `slipcase-desktop`, which
keeps a copy under its own name as its *application* icon — a different role,
and one that may diverge from this one.

## Two things measured rather than assumed

**`sub-class-of application/zip` carries no icon.** It makes
`content_type_is_a` answer true, which is useful and is all it does. A container
whose type declares no icon draws as `application-x-generic`, the blank page,
not as an archive.

**The icon has to be named twice.** GIO hands the file manager the whole icon
name list at once, and GTK4 searches theme-major: every name is tried in Adwaita
before any name is tried in hicolor. The default generic icon for `application/*`
is `application-x-generic`, which Adwaita has, so it won every lookup and the
hicolor drawing was never reached. Naming the specific icon as the generic one
leaves Adwaita nothing to answer. `slipcase-desktop` found this first; it was
measured again here from the other direction, by watching
`package-x-generic` beat a name that was first in the list and present in the
theme.

## Installing

From the Excelano apt repository, or by hand:

    ./install.sh                        # into ~/.local
    ./install.sh --prefix /usr/local    # for everyone
    ./uninstall.sh

Check it took:

    xdg-mime query filetype some.slpc   # application/x.slipcase+zip

An empty file answers `application/x-zerosize` whatever the glob says, so check
against a real container.

## Building the package

    ./debian/build-deb.sh

`Architecture: all` — there is nothing here to compile. The version lives in
`debian/changelog` and nowhere else.

## Licence

MIT. See `LICENSE`.
