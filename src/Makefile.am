NULL =

AM_CPPFLAGS = \
	$(CATAPULT_GUI_CFLAGS) \
	$(GTK_SOURCEVIEW_CFLAGS) \
	$(PANDORA_GLIB_CFLAGS) \
	$(SDL_CFLAGS) \
	-DPACKAGE_DATADIR=\"$(pkgdatadir)\" \
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
	InterfaceHelper.vala \
	Options.vala \
	Data/GameBrowserState.vala \
	Data/NativePlatform.vala \
	Data/NativePlatformCategory.vala \
	Data/Platform.vala \
	Data/Pnd/AppItem.vala \
	Data/Pnd/Category.vala \
	Data/Pnd/MountSet.vala \
	Data/Pnd/PndCache.vala \
	Data/Pnd/PndData.vala \
	Data/Pnd/PndItem.vala \
	Data/Preferences.vala \
	Data/Program.vala \
	Data/Provider.vala \
	GameList/GameFolder.vala \
	GameList/GameFolderCache.vala \
	GameList/GameItem.vala \
	GameList/GameListProvider.vala \
	GameList/IGameListNode.vala \
	GameList/RomList.vala \
	GameList/PndList.vala \
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
	Selectors/EverythingSelector.vala \
	Selectors/GameFolderSelector.vala \
	Selectors/PlatformSelector.vala \
	Selectors/Selector.vala \
	Selectors/SelectorItemSet.vala \
	TextEntry.vala \
	$(NULL)

pandafe_SOURCES = \
	pandafe.vala.stamp \
	$(pandafe_VALASOURCES:.vala=.c) \
	$(NULL)

pandafe.vala.stamp: $(pandafe_VALASOURCES)
	$(VALA_V)$(VALAC) $(VALAFLAGS) -C --vapidir $(srcdir)/../vapi --pkg catapult-gui --pkg catapult --pkg gtksourceview-2.0 --pkg pandora-glib --pkg gee-1.0 --pkg gtk+-2.0 --pkg sdl --pkg sdl-ttf --pkg sdl-gfx --pkg config --pkg GdkKeySyms --pkg sdl-keyboard $^
	@touch $@

pandafe_LDADD = \
	$(CATAPULT_GUI_LIBS) \
	$(GTK_SOURCEVIEW_LIBS) \
	$(PANDORA_GLIB_LIBS) \
	$(SDL_LIBS) \
	$(SDL_TTF_LIBS) \
	$(SDL_GFX_LIBS) \
	$(NULL)

EXTRA_DIST = $(pandafe_VALASOURCES) pandafe.vala.stamp

MAINTAINERCLEANFILES = \
  $(pandafe_VALASOURCES:.vala=.c) \
  $(NULL)
