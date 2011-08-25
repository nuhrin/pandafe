NULL =

AM_CPPFLAGS = \
	$(CATAPULT_GUI_CFLAGS) \
	$(GTK_SOURCEVIEW_CFLAGS) \
	$(PANDORA_GLIB_CFLAGS) \
	$(SDL_CFLAGS) \
	$(NULL)

BUILT_SOURCES = pandafe.vala.stamp

bin_PROGRAMS = \
	pandafe \
	$(NULL)

pandafe_VALASOURCES = \
	main.vala \
	ConfigGui.vala \
	libpndtest.vala \
	GameBrowser.vala \
	GameFolderSelector.vala \
	PlatformSelector.vala \
	Selector.vala \
	Options.vala \
	Data/GameList/GameFolder.vala \
	Data/GameList/GameItem.vala \
	Data/GameList/GameListNode.vala \
	Data/GameList/GameListProvider.vala \
	Data/GameList/RomList.vala \
	Data/GameBrowserState.vala \
	Data/Interface.vala \
	Data/Platform.vala \
	Data/Pnd/AppItem.vala \
	Data/Pnd/MountSet.vala \
	Data/Pnd/PndCache.vala \
	Data/Pnd/PndData.vala \
	Data/Pnd/PndItem.vala \
	Data/Preferences.vala \
	Data/Program.vala \
	Fields/ColorField.vala \
	Fields/ClockspeedField.vala \
	Fields/CustomCommandField.vala \
	Fields/DefaultProgramField.vala \
	Fields/PndAppSelectionField.vala \
	Fields/PndSelectionField.vala \
	Fields/PndScriptFileField.vala \
	Fields/PlatformListField.vala \
	Fields/ProgramListField.vala \
	Fields/SourceEditField.vala \
	$(NULL)

pandafe_SOURCES = \
	pandafe.vala.stamp \
	$(pandafe_VALASOURCES:.vala=.c) \
	$(NULL)

pandafe.vala.stamp: $(pandafe_VALASOURCES)
	$(VALA_V)$(VALAC) $(VALAFLAGS) -C --vapidir $(srcdir)/../vapi --pkg catapult-gui --pkg catapult --pkg gtksourceview-2.0 --pkg pandora-glib --pkg gee-1.0 --pkg gtk+-2.0 --pkg sdl --pkg sdl-ttf --pkg config --pkg GdkKeySyms --pkg sdl-keyboard $^
	@touch $@

pandafe_LDADD = \
	$(CATAPULT_GUI_LIBS) \
	$(GTK_SOURCEVIEW_LIBS) \
	$(PANDORA_GLIB_LIBS) \
	$(SDL_LIBS) \
	$(SDL_TTF_LIBS) \
	$(NULL)

EXTRA_DIST = $(pandafe_VALASOURCES) pandafe.vala.stamp

MAINTAINERCLEANFILES = \
  $(pandafe_VALASOURCES:.vala=.c) \
  $(NULL)
