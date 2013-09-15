AC_INIT([pandafe], m4_esyscmd([build-aux/git-version-gen .tarball-version]), [nuhrin@oceanic.to], [pandafe])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2 tar-ustar])

m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AM_MAINTAINER_MODE

# PND config and build variables
PND_APP_ID=pandafe
AC_SUBST(PND_APP_ID)
AC_DEFINE_UNQUOTED([PND_APP_ID], "$PND_APP_ID", [The app id to be used in the pnd])

AC_ARG_VAR(PND_MOUNT_DIR, [The PATH the build pnd expects to be mounted under.])
if test -z "$PND_MOUNT_DIR"; then
	PND_MOUNT_DIR=/mnt/utmp/$PND_APP_ID
	AC_SUBST(PND_MOUNT_DIR)	
fi
AC_ARG_VAR(PND_BUILD_DIR, [The PATH of the directory the pnd will be built within.])
if test -z "$PND_BUILD_DIR"; then
	PND_BUILD_DIR=.
	AC_SUBST(PND_BUILD_DIR)	
fi
PND_BUILD_SUBDIR="$PND_BUILD_DIR/${PND_APP_ID}_pnd_build"
AC_SUBST(PND_BUILD_SUBDIR)

# gtksourceview style to use: classic, cobalt, kate, oblivion, tango
GTKSOURCEVIEW_STYLE=oblivion 
AC_SUBST(GTKSOURCEVIEW_STYLE)

# Checks for programs.
AC_PROG_CC
AM_PROG_CC_C_O
LT_INIT

AC_PROG_SED

AC_CHECK_PROGS(MAKE_PND_COMMAND, [mksquashfs mkisofs genisoimage], [None])
AC_SUBST(MAKE_PND_COMMAND)

AM_PROG_VALAC([0.18.0])
AC_SUBST(VALAC)
AC_SUBST(VALAFLAGS)

# Pull glib-genmarshal & co. (for gtksourceview)
AC_PATH_PROG(GLIB_GENMARSHAL, glib-genmarshal)
AC_PATH_PROG(GLIB_MKENUMS, glib-mkenums)

# Split up PACKAGE_VERSION into components, for sake of PXML.xml
PACKAGE_VERSION_SPLIT

# Configure local submodules
SUBMODULE_CONFIG

# Checks for packages.
GLIB_REQUIRED=2.18.0
PKG_CHECK_MODULES(GLIB, glib-2.0 >= $GLIB_REQUIRED gobject-2.0 >= $GLIB_REQUIRED)
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)
PKG_CHECK_MODULES(GIO, gio-2.0 >= $GLIB_REQUIRED)
AC_SUBST(GIO_CFLAGS)
AC_SUBST(GIO_LIBS)

GTK_REQUIRED=2.12.0
PKG_CHECK_MODULES(GTK, gtk+-2.0 >= $GTK_REQUIRED);
AC_SUBST(GTK_CFLAGS)
AC_SUBST(GTK_LIBS)

LIBXML_REQUIRED=2.5.0
PKG_CHECK_MODULES(LIBXML, libxml-2.0 >= $LIBXML_REQUIRED);
AC_SUBST(LIBXML_CFLAGS)
AC_SUBST(LIBXML_LIBS)

PKG_CHECK_MODULES(VTE, vte);
AC_SUBST(VTE_CFLAGS)
AC_SUBST(VTE_LIBS)

PKG_CHECK_MODULES(SDL, sdl);
AC_SUBST(SDL_CFLAGS)
AC_SUBST(SDL_LIBS)

PKG_CHECK_MODULES(SDL_IMAGE, SDL_image);
AC_SUBST(SDL_IMAGE_CFLAGS)
AC_SUBST(SDL_IMAGE_LIBS)

have_sdl_ttf=no
AC_SEARCH_LIBS([TTF_Init], [SDL_ttf], [have_sdl_ttf=yes])
if test "x${have_sdl_ttf}" = xyes; then
  AC_CHECK_HEADERS([SDL/SDL_ttf.h], [], [have_sdl_ttf=no])
fi
if test "x${have_sdl_ttf}" = xno; then
  AC_MSG_ERROR([libSDL_ttf not found.])
fi
SDL_TTF_LIBS="$LIBS"
AC_SUBST(SDL_TTF_LIBS)

have_sdl_gfx=no
AC_SEARCH_LIBS([rectangleColor], [SDL_gfx], [have_sdl_gfx=yes])
if test "x${have_sdl_gfx}" = xyes; then
  AC_CHECK_HEADERS([SDL/SDL_gfxPrimitives.h], [], [have_sdl_gfx=no])
fi
if test "x${have_sdl_gfx}" = xno; then
  AC_MSG_ERROR([libSDL_gfx not found.])
fi
SDL_GFX_LIBS="$LIBS"
AC_SUBST(SDL_GFX_LIBS)

AC_CONFIG_FILES([
	Makefile
	data/Makefile
	data/fonts/Makefile
	data/Platform/Makefile
	data/Program/Makefile
	pnd/Makefile
	pnd/PXML.xml
	pnd/previews/Makefile
	scripts/Makefile
	submodules/Makefile
	gtksourceview/Makefile
	gtksourceview/language-specs/Makefile
	gtksourceview/embedded_languages.c
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT
