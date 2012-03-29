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

CLEANFILES = preferences
EXTRA_DIST = \
	preferences.in \      
	$(NULL)
 
do_subst = sed \        
	-e 's|[@]pkgdatadir[@]|$(pkgdatadir)|g' \        
	$(NULL)
 
preferences: preferences.in Makefile      
	$(do_subst) < preferences.in > preferences
