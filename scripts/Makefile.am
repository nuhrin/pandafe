NULL =

scriptsdir=$(pkgdatadir)/scripts

scripts_SCRIPTS = \
	pnd_run.sh \
	$(NULL)

CLEANFILES = $(scripts_SCRIPTS)
EXTRA_DIST = \
	pnd_run.sh.in
	$(NULL)

do_subst = sed \
	-e 's|[@]scriptsdir[@]|$(scriptsdir)|g' \
	$(NULL)

pnd_run.sh: pnd_run.sh.in Makefile
	$(do_subst) < pnd_run.sh.in > pnd_run.sh
	chmod +x pnd_run.sh
	
dist_scripts_DATA = \
  pnd_logging \
  $(NULL)

pnd_logging: \
	$(NULL)
