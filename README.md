# slipcase-common

The Slipcase media type and the icon a container is drawn with, as one package
that every Slipcase product on a Linux machine depends on. No executable. The
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

`mime/slipcase.xml` declares `application/vnd.excelano.slipcase+zip` against
`*.slpc`, as a subclass of `application/zip`, and carries
`application/x.slipcase+zip` as an alias.
[SPEC §4](https://slipcaseformat.org/spec/#4-file-extension-and-media-type)
names the registered type and the extension and reserves no magic bytes, so the
glob is the only identification available.

`icons/application-vnd.excelano.slipcase+zip.svg` is the drawing: a card
sliding into an open-topped case, on a 64-unit grid. It came from
`slipcase-desktop`, which keeps a copy under its own name as its *application*
icon — a different role, and one that may diverge from this one.

The same file also declares five payload families, and `icons/` carries a
drawing for each. See below.

## The payload families

A container named `report.pdf.slpc` draws with a PDF mark on the card rather
than with the plain one, because `mime/slipcase.xml` declares
`application/x.slipcase-pdf+zip` against `*.pdf.slpc` and gives it its own icon.
There are five: PDF, document, image, audio and video, each a subclass of
`application/vnd.excelano.slipcase+zip` and each covering a list of payload
extensions. Anything not on a list keeps the plain icon and needs no
declaration, so the families are an addition to the type rather than a
replacement for it.

Five and not fifty, because an icon has to survive the 16 pixels a file manager
uses in a list. Text and word processor payloads share one mark for the same
reason: two drawings made of horizontal rules differ by nothing a person can see
at that size. Spreadsheets and presentations are the obvious next two if the
mark for each can be told apart from a document's.

**The icon is a guess, and the guess comes from the container's name.** That
`foo.pdf.slpc` holds `foo.pdf` is [Appendix B][b], which is non-normative, and
[§3][3] requires a reader to find the payload by `payload.file` alone and never
by that convention. An icon is not a reader and a hint is not a verdict, but the
hint can be wrong: a container named `invoice.pdf.slpc` around a PNG payload
draws a PDF mark. Whatever opens it says what is actually inside, which is the
answer anybody acts on. A thumbnailer would read the metadata and know, and
would also be an executable run against untrusted archives on whatever happens
to be in the directory somebody is browsing, which [§6][6] names as a hazard in
those words. That is the trade this package declines for now.

[b]: https://slipcaseformat.org/spec/#appendix-b-naming-convention-non-normative
[3]: https://slipcaseformat.org/spec/#3-implementation-requirements
[6]: https://slipcaseformat.org/spec/#6-security-considerations

**Adding a family means editing two other repositories.** A family type is
opened by whatever opens a container, because `sub-class-of` carries the default
application. What it does not carry is the *recommended* list, which is
exact-type only, so a family missing from a product's `MimeType=` line still
opens but drops out of the top of Open With. `slipcase-desktop` and
`slipcase-open` therefore name all six types in their desktop entries, and both
carry a comment saying why. It is the one part of this that could not stay here.

**These types stay in the unregistered `x.` tree, permanently.** The type
registered with IANA is the format; these name a drawing. Minting siblings of a
registered type to choose an icon would be a misuse of the name space, so the
registration reaches the container type and not these five.

## Things measured rather than assumed

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

**The longer glob wins**, which is what the payload families rest on.
`report.pdf.slpc` matches both `*.slpc` and `*.pdf.slpc`, and shared-mime-info
takes the pattern with more literal characters. Measured in a
scratch `XDG_DATA_HOME` against real containers, along with two things that came
free: `report.PDF.slpc` matches as well, since a glob is case-insensitive unless
it says otherwise, and `deck.xyz.slpc` falls through to the plain type with no
declaration needed.

**That arbitration is inside one database, and across data directories an
earlier one wins whole.** `XDG_DATA_HOME` is read before `XDG_DATA_DIRS`, and
the winner is not recomputed over the pair: a `*.slpc` declared in `~/.local` is
taken and the `*.pdf.slpc` in `/usr` is never reached, so every container draws
with the plain icon on a machine carrying this package correctly installed.
Content sniffing is the one override. Where the earlier candidate is unrelated
to `application/zip`, a real container sniffs as a ZIP and the later
zip-descended type wins on lineage instead; a declaration carrying
`sub-class-of application/zip` does not lose that way. Measured with two
prefixes against real containers, and pinned down by a text file named
`.pdf.slpc`, which sniffs as neither and flips the result. `uninstall.sh`
therefore clears both names this package can have been installed under, and a
hand install left in `~/.local` is the first thing to look for when a container
draws plain on a machine that has the package.

**The alias reaches GIO and not `mimeinfo.cache`.** `update-mime-database`
compiles `<alias>` into `mime/aliases`, a container types as the registered
name, and `Gio.AppInfo.get_default_for_type` on that name finds an application
whose desktop entry names only `application/x.slipcase+zip`: an installation
predating the registration keeps opening containers from a file manager.
`mimeinfo.cache` is keyed on the literal `MimeType=` string and does not
unalias, and `xdg-mime query default` reads it directly, so that command asked
for the registered name answers nothing until the entry names it too. The
compiled `mime/types` carries the registered name alone, which is why the guard
in each product's `install.sh` greps for that string and not the old one.

**`sub-class-of` carries the default application and not the recommended list.**
`gio mime application/x.slipcase-pdf+zip` answers with the parent's default
application, so a double-click opens the same product it always did; the
recommended list comes back empty, because that one is matched on the exact
type. The consequence is a line in each product's desktop entry rather than a
change here.

**A family with no drawing degrades to the case, not to a blank page.** Each
family names the plain container icon as its `generic-icon` rather than its own,
which puts a real fallback on the end of the name list GIO hands the file
manager and keeps `application-x-generic` off it entirely. The list for a PDF
container reads `application-x.slipcase-pdf+zip,
application-vnd.excelano.slipcase+zip`, and Adwaita can answer neither.

## Installing

From the Excelano apt repository, or by hand:

    ./install.sh                        # into ~/.local
    ./install.sh --prefix /usr/local    # for everyone
    ./uninstall.sh

Check it took:

    xdg-mime query filetype some.slpc     # application/vnd.excelano.slipcase+zip
    xdg-mime query filetype some.pdf.slpc # application/x.slipcase-pdf+zip

An empty file answers `application/x-zerosize` whatever the glob says, so check
against a real container.

## Building the package

    ./debian/build-deb.sh

`Architecture: all` — there is nothing here to compile. The version lives in
`debian/changelog` and nowhere else.

## Licence

MIT. See `LICENSE`.
