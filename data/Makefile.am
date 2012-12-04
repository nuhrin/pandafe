NULL =

SUBDIRS = \
	fonts \
	Platform \
	Program \
  $(NULL)

topdatadir=$(pkgdatadir)
topdata_DATA = \
	preferences \
	$(NULL)

dist_topdata_DATA = \
	native_platform \
	platform_folders \
	$(NULL)

do_subst = sed \
	-e 's|[@]pkgdatadir[@]|$(pkgdatadir)|g' \
	$(NULL)
 
