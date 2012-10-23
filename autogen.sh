test -n "$srcdir" || srcdir=$(dirname "$0")
test -n "$srcdir" || srcdir=.
(
  # initialize submodules and tweak libgee to allow autoreconf to complete
  test -d .git && git submodule update --init &&
    mkdir -p submodules/libgee/m4 && touch submodules/libgee/ChangeLog

  # autoreconf
  cd "$srcdir" &&
  AUTOPOINT='intltoolize --automake --copy' autoreconf -iv -Wall
) || exit
test -n "$NOCONFIGURE" || "$srcdir/configure" --enable-maintainer-mode "$@"
