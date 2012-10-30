NULL =

ACLOCAL_AMFLAGS = -I m4

SUBDIRS = \
	data \
	pnd \
	scripts \
	submodules \
	src/gtksourceview \
	src \
	vapi \
	$(NULL)

all: version.h

version.h: $(top_srcdir)/.version
	echo '#define BUILD_VERSION "'`cat $(top_srcdir)/.version`'"' > $@-t && mv $@-t $@

BUILT_SOURCES = $(top_srcdir)/.version
$(top_srcdir)/.version: gen-version
	@true
.PHONY: gen-version
gen-version:
	@V=`$(top_srcdir)/build-aux/git-version-gen $(top_srcdir)/.tarball-version` &&      \
	if [ -e $(top_srcdir)/.version ] && [ "x`cat $(top_srcdir)/.version`" = "x$$V" ]; then    \
	  true;                       \
	else                        \
	  echo "$$V" > $(top_srcdir)/.version;                \
	fi
dist-hook: gen-ChangeLog
	echo $(VERSION) > $(distdir)/.tarball-version

gen_start_date = 2009-02-25
.PHONY: gen-ChangeLog
gen-ChangeLog:
	if test -d .git; then           \
	  $(top_srcdir)/build-aux/gitlog-to-changelog     \
	    --since=$(gen_start_date) > $(distdir)/cl-t;    \
	  rm -f $(distdir)/ChangeLog;         \
	  mv $(distdir)/cl-t $(distdir)/ChangeLog;      \
	fi

pnd: all
	if test "xNone" = "x$(MAKE_PND_COMMAND)"; then \
		echo "make pnd: need one of the following to continue: mksquashfs, mkisofs, genisoimage"; \
		exit 1; \
	fi; \
	rm -rf $(PND_BUILD_DIR)/pnd_build; \
	rm -f $(top_srcdir)/src/build-info.h; \
	$(MAKE) -e MAKEFLAGS=-e DESTDIR=`readlink -f $(PND_BUILD_DIR)/pnd_build` prefix=$(PND_MOUNT_DIR) install \
		|| exit 1; \
	$(install_sh_DATA) $(top_srcdir)/COPYING $(PND_BUILD_DIR)/pnd_build/$(PND_MOUNT_DIR);
	rm -f $(top_srcdir)/src/build-info.h; \
	if test "xmksquashfs" = "x$(MAKE_PND_COMMAND)"; then \
		mksquashfs $(PND_BUILD_DIR)/pnd_build/$(PND_MOUNT_DIR) $(PND_BUILD_DIR)/$(PND_APP_ID).iso -nopad -no-recovery || exit 1; \
	else \
		$(MAKE_PND_COMMAND) -o $(PND_BUILD_DIR)/$(PND_APP_ID).iso -R $(PND_BUILD_DIR)/pnd_build/$(PND_MOUNT_DIR) || exit 1; \
	fi; \
	cat $(PND_BUILD_DIR)/$(PND_APP_ID).iso $(top_srcdir)/pnd/PXML.xml $(top_srcdir)/pnd/icon.png > $(PND_BUILD_DIR)/$(PND_APP_ID)-$(PACKAGE_VERSION).pnd; \
	rm -r $(PND_BUILD_DIR)/$(PND_APP_ID).iso; \
	rm -rf $(PND_BUILD_DIR)/pnd_build; \
	echo "Finished building pnd: `readlink -f $(PND_BUILD_DIR)/$(PND_APP_ID)-$(PACKAGE_VERSION).pnd`"
.PHONY: pnd

CLEANFILES = \
	$(NULL)

EXTRA_DIST = \
	.version \
	build-aux/git-version-gen \
	build-aux/gitlog-to-changelog \
	$(NULL)

DISTCLEANFILES = version.h

