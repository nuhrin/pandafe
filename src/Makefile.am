NULL =

AM_CPPFLAGS = \
	$(CATAPULT_GUI_CFLAGS) \
	$(PANDORA_GLIB_CFLAGS) \
	$(NULL)

BUILT_SOURCES = pandafe.vala.stamp

bin_PROGRAMS = \
	pandafe \
	$(NULL)

pandafe_VALASOURCES = \
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

pandafe_SOURCES = \
	pandafe.vala.stamp \
	$(pandafe_VALASOURCES:.vala=.c) \
	$(NULL)

pandafe.vala.stamp: $(pandafe_VALASOURCES)
	$(VALA_V)$(VALAC) $(VALAFLAGS) -C --vapidir $(srcdir)/../vapi --pkg catapult-gui --pkg catapult --pkg pandora-glib --pkg gee-1.0 --pkg gtk+-2.0 --pkg config --pkg GdkKeySyms $^
	@touch $@

pandafe_LDADD = \
	$(CATAPULT_GUI_LIBS) \
	$(PANDORA_GLIB_LIBS) \
	$(NULL)

EXTRA_DIST = $(pandafe_VALASOURCES) pandafe.vala.stamp

MAINTAINERCLEANFILES = \
  $(pandafe_VALASOURCES:.vala=.c) \
  $(NULL)
