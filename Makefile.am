NULL =

SUBDIRS = \
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

CLEANFILES = \
	$(NULL)

EXTRA_DIST = \
	.version \
	build-aux/git-version-gen \
	build-aux/gitlog-to-changelog \
	$(NULL)

DISTCLEANFILES = version.h

