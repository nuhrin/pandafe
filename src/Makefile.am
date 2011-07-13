NULL =

AM_CPPFLAGS = \
	$(CATAPULT_GUI_CFLAGS) \
	$(PANDORA_GLIB_CFLAGS) \
	$(NULL)

BUILT_SOURCES = yayafe.vala.stamp

bin_PROGRAMS = \
	yayafe \
	$(NULL)

yayafe_VALASOURCES = \
	main.vala \
	libpndtest.vala \
	Options.vala \
	Data/Platform.vala \
	Data/Program.vala \
	Data/ProgramDefinition/OptionType/IOptionType.vala \
	Data/ProgramDefinition/Option.vala \
	Data/ProgramDefinition/OptionData.vala \
	Data/ProgramDefinition/OptionPath.vala \
	Data/ProgramDefinition/OptionSet.vala \
	Data/ProgramDefinition/OptionSetState.vala \
	Data/ProgramDefinition/ProgramArgument.vala \
	Data/ProgramDefinition/ProgramDefinition.vala \
	$(NULL)

yayafe_SOURCES = \
	yayafe.vala.stamp \
	$(yayafe_VALASOURCES:.vala=.c) \
	$(NULL)

yayafe.vala.stamp: $(yayafe_VALASOURCES)
	$(VALA_V)$(VALAC) $(VALAFLAGS) -C --vapidir $(srcdir)/../vapi --pkg catapult-gui --pkg catapult --pkg pandora-glib --pkg gee-1.0 --pkg gtk+-2.0 --pkg config --pkg GdkKeySyms --pkg pnd $^
	@touch $@

yayafe_LDADD = \
	$(CATAPULT_GUI_LIBS) \
	$(PANDORA_GLIB_LIBS) \
	$(NULL)

EXTRA_DIST = $(yayafe_VALASOURCES) yayafe.vala.stamp

MAINTAINERCLEANFILES = \
  $(yayafe_VALASOURCES:.vala=.c) \
  $(NULL)
