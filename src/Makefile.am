NULL =

AUTOMAKE_OPTIONS = subdir-objects

AM_CPPFLAGS = \
	$(CATAPULT_CFLAGS) \
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
	GameBrowser.vala \
	GameBrowserUI.vala \
	InterfaceHelper.vala \
	Data/Color.vala \
	Data/GameBrowserState.vala \
	Data/GameSettings.vala \
	Data/Options/FlagOption.vala \
	Data/Options/IntegerOption.vala \
	Data/Options/MultipleChoiceOption.vala \
	Data/Options/Option.vala \
	Data/Options/OptionGrouping.vala \
	Data/Options/OptionSet.vala \
	Data/Options/OptionType.vala \
	Data/Platforms/NativePlatform.vala \
	Data/Platforms/NativePlatformCategory.vala \
	Data/Platforms/Platform.vala \
	Data/Pnd/AppIdType.vala \
	Data/Pnd/AppItem.vala \
	Data/Pnd/Category.vala \
	Data/Pnd/MountSet.vala \
	Data/Pnd/PndCache.vala \
	Data/Pnd/PndData.vala \
	Data/Pnd/PndItem.vala \
	Data/Preferences.vala \
	Data/Programs/Program.vala \
	Data/Programs/ProgramProvider.vala \
	Data/Programs/ProgramSettings.vala \
	Data/Provider.vala \
	GameList/GameFolder.vala \
	GameList/GameFolderCache.vala \
	GameList/GameItem.vala \
	GameList/GameListProvider.vala \
	GameList/IGameListNode.vala \
	GameList/RomList.vala \
	GameList/PndList.vala \
	Fields/ColorField.vala \
	Fields/ClockSpeedField.vala \
	Fields/CustomCommandField.vala \
	Fields/NativePlatformCategoryAppListField.vala \
	Fields/NativePlatformCategoryListField.vala \
	Fields/NativePlatformSubCategoryListField.vala \
	Fields/OptionGroupingField.vala \
	Fields/PlatformListField.vala \
	Fields/PndAppField.vala \
	Fields/PndCategoryField.vala \
	Fields/PndSelectionField.vala \
	Fields/ProgramAppIdField.vala \
	Fields/ProgramDefaultSettingsField.vala \
	Fields/ProgramListField.vala \
	Fields/ProgramOptionsListField.vala \
	Fields/ProgramSelectionField.vala \
	Layers/Controls/Chooser/ChooserHeader.vala \
	Layers/Controls/Chooser/ChooserBase.vala \
	Layers/Controls/Chooser/ChooserSelector.vala \
	Layers/Controls/Chooser/FileSelector.vala \
	Layers/Controls/Chooser/FolderSelector.vala \
	Layers/Controls/Chooser/PndAppSelector.vala \
	Layers/Controls/Chooser/PndCategorySelector.vala \
	Layers/Controls/List/GenericListItem.vala \
	Layers/Controls/List/ListEditorBase.vala \
	Layers/Controls/List/ListItem.vala \
	Layers/Controls/List/ListItemActionSelector.vala \
	Layers/Controls/List/ListItemActionType.vala \
	Layers/Controls/List/ListItemSelector.vala \
	Layers/Controls/List/StringListItem.vala \
	Layers/Controls/FileChooser.vala \
	Layers/Controls/FolderChooser.vala \
	Layers/Controls/IntegerEntry.vala \
	Layers/Controls/ListEditor.vala \
	Layers/Controls/PndAppChooser.vala \
	Layers/Controls/PndCategoryChooser.vala \
	Layers/Controls/StringListEditor.vala \
	Layers/Controls/StringSelector.vala \
	Layers/Controls/TextEntry.vala \
	Layers/Controls/UIntEntry.vala \
	Layers/Controls/ValueSelector.vala \
	Layers/Controls/ValueSelectorBase.vala \
	Layers/GameBrowser/HeaderLayer.vala \
	Layers/GameBrowser/MenuOverlay.vala \
	Layers/GameBrowser/StatusMessageLayer.vala \
	Layers/MenuBrowser/ColorDisplayLayer.vala \
	Layers/MenuBrowser/MenuHeaderLayer.vala \
	Layers/MenuBrowser/MenuMessageLayer.vala \
	Layers/Preview/BrowserPreview.vala \
	Layers/Preview/PreviewSelector.vala \
	Layers/Layer.vala \
	Layers/LayerBase.vala \
	Layers/ScreenAlphaLayer.vala \
	Layers/ScreenLayer.vala \
	Layers/SurfaceLayer.vala \
	Menus/Concrete/GameBrowserAppearanceMenu.vala \
	Menus/Concrete/GameFolderMenu.vala \
	Menus/Concrete/GameMenu.vala \
	Menus/Concrete/GameSettingsMenu.vala \
	Menus/Concrete/MainConfiguration.vala \
	Menus/Concrete/OptionGroupingMenu.vala \
	Menus/Concrete/PlatformMenu.vala \
	Menus/Concrete/ProgramDefaultSettingsMenu.vala \
	Menus/Fields/BooleanField.vala \
	Menus/Fields/EnumField.vala \
	Menus/Fields/FileField.vala \
	Menus/Fields/FolderField.vala \
	Menus/Fields/IntegerField.vala \
	Menus/Fields/ListField.vala \
	Menus/Fields/ObjectField.vala \
	Menus/Fields/MenuItemField.vala \
	Menus/Fields/StringField.vala \
	Menus/Fields/StringListField.vala \
	Menus/Fields/StringSelectionField.vala \
	Menus/Fields/UIntField.vala \
	Menus/Menu.vala \
	Menus/MenuBrowser.vala \
	Menus/MenuBrowserItem.vala \
	Menus/MenuBuilder.vala \
	Menus/MenuItem.vala \
	Menus/MenuItemActionType.vala \
	Menus/MenuObject.vala \
	Menus/MenuSelector.vala \
	Menus/ObjectBrowserItem.vala \
	Menus/ObjectMenu.vala \
	Menus/SubMenuItem.vala \
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
	$(VALA_V)$(VALAC) $(VALAFLAGS) -C --vapidir $(srcdir)/../vapi --pkg catapult --pkg gtksourceview-2.0 --pkg pandora-glib --pkg gee-0.8 --pkg gtk+-2.0 --pkg sdl --pkg sdl-ttf --pkg sdl-gfx --pkg config --pkg GdkKeySyms --pkg sdl-keyboard $^
	@touch $@

pandafe_LDADD = \
	$(CATAPULT_LIBS) \
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
