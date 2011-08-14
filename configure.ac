AC_INIT([pandafe], m4_esyscmd([build-aux/git-version-gen .tarball-version]), [nuhrin@oceanic.to], [pandafe])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])

m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AM_MAINTAINER_MODE

# Checks for programs.
AC_PROG_CC
AM_PROG_CC_C_O

AM_PROG_VALAC([0.11.0])
AC_SUBST(VALAC)
AC_SUBST(VALAFLAGS)

PKG_CHECK_MODULES(CATAPULT_GUI, catapult-gui);
AC_SUBST(CATAPULT_GUI_CFLAGS)
AC_SUBST(CATAPULT_GUI_LIBS)

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

AC_CONFIG_FILES([
	Makefile
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT
