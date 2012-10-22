#
#
#
AC_DEFUN([SUBMODULE_CONFIG],
[dnl
# Ensure submodules are initialized
if ! test -f "$srcdir/submodules/libgee/configure.ac"; then
	AC_MSG_ERROR([submodules libgee is not initialized.])
fi
if ! test -f "$srcdir/submodules/catapult/configure.ac"; then
	AC_MSG_ERROR([submodules catapult is not initialized.])
fi
if ! test -f "$srcdir/submodules/pandora-glib/configure.ac"; then
	AC_MSG_ERROR([submodules pandora-glib is not initialized.])
fi

MODULE_SRCDIR='$(top_srcdir)/submodules'
MODULE_BUILDDIR='$(top_builddir)/submodules'
AC_CONFIG_COMMANDS_POST([ac_configure_args="$ac_configure_args --enable-static --disable-shared"])

# Configure libgee
GEE_CFLAGS="-I$MODULE_SRCDIR/libgee/gee"
GEE_LTLIB="$MODULE_BUILDDIR/libgee/gee/libgee-0.8.la"
GEE_VAPI="$MODULE_BUILDDIR/libgee/gee/gee-0.8.vapi"
SUBMODULE_VALAFLAGS="--vapidir $MODULE_BUILDDIR/libgee/gee"
AC_SUBST(GEE_CFLAGS)
AC_SUBST(GEE_LTLIB)
AC_SUBST(GEE_VAPI)
AC_SUBST([GEE_DIR], ["libgee"])
AC_CONFIG_SUBDIRS([submodules/libgee])

# Configure catapult
CATAPULT_CFLAGS="-I$MODULE_SRCDIR/catapult/src -I$MODULE_SRCDIR/catapult/libyaml"
CATAPULT_LTLIB="$MODULE_BUILDDIR/catapult/src/libcatapult.la"
CATAPULT_VAPI="$MODULE_BUILDDIR/catapult/src/catapult.vapi"
SUBMODULE_VALAFLAGS="$SUBMODULE_VALAFLAGS --vapidir $MODULE_BUILDDIR/catapult/src"
AC_SUBST(CATAPULT_CFLAGS)
AC_SUBST(CATAPULT_LTLIB)
AC_SUBST(CATAPULT_VAPI)
AC_SUBST([CATAPULT_DIR], ["catapult"])
AC_CONFIG_SUBDIRS([submodules/catapult])

# Configure pandora-glib
PANDORA_GLIB_CFLAGS="-I$MODULE_SRCDIR/pandora-glib/src"
PANDORA_GLIB_LTLIB="$MODULE_BUILDDIR/pandora-glib/src/libpandora-glib.la"
PANDORA_GLIB_VAPI="$MODULE_BUILDDIR/pandora-glib/src/pandora-glib.vapi"
SUBMODULE_VALAFLAGS="$SUBMODULE_VALAFLAGS --vapidir $MODULE_BUILDDIR/pandora-glib/src"
AC_SUBST(PANDORA_GLIB_CFLAGS)
AC_SUBST(PANDORA_GLIB_LTLIB)
AC_SUBST(PANDORA_GLIB_VAPI)
AC_SUBST([PANDORA_GLIB_DIR], ["pandora-glib"])
AC_CONFIG_SUBDIRS([submodules/pandora-glib])

AC_SUBST(SUBMODULE_VALAFLAGS)[]dnl
]) # SUBMODULE_CONFIG
