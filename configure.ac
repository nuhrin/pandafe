AC_INIT([pandafe], m4_esyscmd([build-aux/git-version-gen .tarball-version]), [nuhrin@oceanic.to], [pandafe])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])

m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AM_MAINTAINER_MODE


PND_APP_ID=pandafe
AC_SUBST(PND_APP_ID)
AC_DEFINE_UNQUOTED([PND_APP_ID], "$PND_APP_ID", [The app id to be used in the pnd])

LOCAL_CONFIG_DIR=./PandafeData
AC_SUBST(LOCAL_CONFIG_DIR)
AC_DEFINE_UNQUOTED(LOCAL_CONFIG_DIR, "$LOCAL_CONFIG_DIR", [Local configuration directory])

# Checks for programs.
AC_PROG_CC
AM_PROG_CC_C_O

AM_PROG_VALAC([0.11.0])
AC_SUBST(VALAC)
AC_SUBST(VALAFLAGS)

PKG_CHECK_MODULES(CATAPULT, catapult);
AC_SUBST(CATAPULT_CFLAGS)
AC_SUBST(CATAPULT_LIBS)

PKG_CHECK_MODULES(GTK_SOURCEVIEW, gtksourceview-2.0);
AC_SUBST(GTK_SOURCEVIEW_CFLAGS)
AC_SUBST(GTK_SOURCEVIEW_LIBS)

PKG_CHECK_MODULES(VTE, vte);
AC_SUBST(VTE_CFLAGS)
AC_SUBST(VTE_LIBS)

PKG_CHECK_MODULES(PANDORA_GLIB, pandora-glib);
AC_SUBST(PANDORA_GLIB_CFLAGS)
AC_SUBST(PANDORA_GLIB_LIBS)

PKG_CHECK_MODULES(SDL, sdl);
AC_SUBST(SDL_CFLAGS)
AC_SUBST(SDL_LIBS)

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
	scripts/Makefile
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT
