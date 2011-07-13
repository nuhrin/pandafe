AC_INIT([yayafe], m4_esyscmd([build-aux/git-version-gen .tarball-version]), [nuhrin@oceanic.to], [yayafe])
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

PKG_CHECK_MODULES(YAMLDB_GUI, yamldb-gui);
AC_SUBST(YAMLDB_GUI_CFLAGS)
AC_SUBST(YAMLDB_GUI_LIBS)

PKG_CHECK_MODULES(PANDORA_GLIB, pandora-glib);
AC_SUBST(PANDORA_GLIB_CFLAGS)
AC_SUBST(PANDORA_GLIB_LIBS)

AC_CONFIG_FILES([
	Makefile
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT
