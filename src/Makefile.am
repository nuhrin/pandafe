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
	GameBrowserUI.vala \
	InterfaceHelper.vala \
	Options.vala \
	Data/Color.vala \
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
	Fields/GColorField.vala \
	Fields/ClockspeedField.vala \
	Fields/CustomCommandField.vala \
	Fields/DefaultProgramField.vala \
	Fields/PndAppSelectionField.vala \
	Fields/PndSelectionField.vala \
	Fields/PndScriptFileField.vala \
	Fields/PlatformListField.vala \
	Fields/ProgramListField.vala \
	Fields/SourceEditField.vala \
	Layers/Controls/Chooser/FileSelector.vala \
	Layers/Controls/Chooser/FolderSelector.vala \
	Layers/Controls/Chooser/ChooserHeader.vala \
	Layers/Controls/FileChooser.vala \
	Layers/Controls/FolderChooser.vala \
	Layers/Controls/IntegerEntry.vala \
	Layers/Controls/StringSelector.vala \
	Layers/Controls/TextEntry.vala \
	Layers/Controls/UIntEntry.vala \
	Layers/Controls/ValueSelector.vala \
	Layers/Controls/ValueSelectorBase.vala \
	Layers/GameBrowser/HeaderLayer.vala \
	Layers/GameBrowser/StatusMessageLayer.vala \
	Layers/MenuBrowser/ColorDisplayLayer.vala \
	Layers/MenuBrowser/MenuHeaderLayer.vala \
	Layers/Preview/BrowserPreview.vala \
	Layers/Preview/PreviewSelector.vala \
	Layers/Layer.vala \
	Layers/LayerBase.vala \
	Layers/ScreenAlphaLayer.vala \
	Layers/ScreenLayer.vala \
	Layers/SurfaceLayer.vala \
	Menus/Concrete/GameBrowserAppearanceMenu.vala \
	Menus/Concrete/MainConfiguration.vala \
	Menus/Fields/BooleanField.vala \
	Menus/Fields/ColorField.vala \
	Menus/Fields/EnumField.vala \
	Menus/Fields/FileField.vala \
	Menus/Fields/FolderField.vala \
	Menus/Fields/IntegerField.vala \
	Menus/Fields/MenuItemField.vala \
	Menus/Fields/StringField.vala \
	Menus/Fields/StringSelectionField.vala \
	Menus/Fields/UIntField.vala \
	Menus/Menu.vala \
	Menus/MenuItem.vala \
	Menus/MenuItemActionType.vala \
	Menus/MenuSelector.vala \
	Menus/MenuBrowser.vala \
	Selectors/EverythingSelector.vala \
	Selectors/GameFolderSelector.vala \
	Selectors/PlatformSelector.vala \
	Selectors/Selector.vala \
	Selectors/SelectorItemSet.vala \
	$(NULL)

pandafe_SOURCES = \
	pandafe.vala.stamp \
	$(pandafe_VALASOURCES:.vala=.c) \
	$(NULL)

pandafe.vala.stamp: $(pandafe_VALASOURCES)
	$(VALA_V)$(VALAC) $(VALAFLAGS) -C --vapidir $(srcdir)/../vapi --pkg catapult-gui --pkg catapult --pkg gtksourceview-2.0 --pkg pandora-glib --pkg gee-0.8 --pkg gtk+-2.0 --pkg sdl --pkg sdl-ttf --pkg sdl-gfx --pkg config --pkg GdkKeySyms --pkg sdl-keyboard $^
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
