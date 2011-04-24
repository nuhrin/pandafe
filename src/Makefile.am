NULL =

AM_CPPFLAGS = \
	$(YAMLDB_GUI_CFLAGS) \
	$(NULL)

BUILT_SOURCES = yayafe.vala.stamp	

bin_PROGRAMS = \
	yayafe \
	$(NULL)

yayafe_VALASOURCES = \
	main.vala \
	Options.vala \
	$(NULL)

yayafe_SOURCES = \
	yayafe.vala.stamp \
	$(yayafe_VALASOURCES:.vala=.c) \
	$(NULL)

yayafe.vala.stamp: $(yayafe_VALASOURCES)
	$(VALA_V)$(VALAC) $(VALAFLAGS) -C --vapidir $(srcdir)/../vapi --pkg yamldb-gui --pkg yamldb --pkg gee-1.0 --pkg gtk+-2.0 --pkg config --pkg GdkKeySyms $^
	@touch $@

yayafe_LDADD = \
	$(YAMLDB_GUI_LIBS) \
	$(NULL)

EXTRA_DIST = $(yayafe_VALASOURCES) yayafe.vala.stamp

MAINTAINERCLEANFILES = \
  $(yayafe_VALASOURCES:.vala=.c) \
  $(NULL)
