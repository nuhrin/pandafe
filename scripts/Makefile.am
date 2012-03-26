NULL =

scriptsdir=$(pkgdatadir)/scripts

scripts_SCRIPTS = \
	cpuspeed_change_exec_wrapper.sh \
	$(NULL)

CLEANFILES = $(scripts_SCRIPTS)
EXTRA_DIST = \
	$(NULL)

do_subst = sed \
	-e 's|[@]scriptsdir[@]|$(scriptsdir)|g' \
	$(NULL)

dist_scripts_DATA = \
	cpuspeed_change_exec_wrapper.sh
	$(NULL)

cpuspeed_change_exec_wrapper.sh: \
	$(NULL)
