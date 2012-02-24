NULL =

scriptsdir=$(pkgdatadir)/scripts

scripts_SCRIPTS = \
	pnd_run_nomount.sh \
	cpuspeed_change_exec_wrapper.sh \
	$(NULL)

CLEANFILES = $(scripts_SCRIPTS)
EXTRA_DIST = \
	pnd_run_nomount.sh.in \
	$(NULL)

do_subst = sed \
	-e 's|[@]scriptsdir[@]|$(scriptsdir)|g' \
	$(NULL)

pnd_run_nomount.sh: pnd_run_nomount.sh.in Makefile
	$(do_subst) < pnd_run_nomount.sh.in > pnd_run_nomount.sh
	chmod +x pnd_run_nomount.sh

dist_scripts_DATA = \
	pnd_logging \
	cpuspeed_change_exec_wrapper.sh
	$(NULL)

pnd_logging: \
	$(NULL)
cpuspeed_change_exec_wrapper.sh: \
	$(NULL)
