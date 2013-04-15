NULL =

AUTOMAKE_OPTIONS = subdir-objects

AM_CPPFLAGS = \
	$(GEE_CFLAGS) \
	$(CATAPULT_CFLAGS) \
	$(PANDORA_GLIB_CFLAGS) \
	$(SDL_CFLAGS) \
	$(SDL_IMAGE_CFLAGS) \
	$(GTK_CFLAGS) \
	$(LIBXML_CFLAGS) \
	$(VTE_CFLAGS) \
	-I./gtksourceview \
	$(NULL)

BUILT_SOURCES = \
	pandafe.submodule-vapi.check \
	pandafe.vala.stamp \
	pandafe.submodule-libs.check \
	build-info.h \
	$(NULL)

bin_PROGRAMS = \
	pandafe \
	$(NULL)

pandafe_VALASOURCES = \
	main.vala \
	EventHandler.vala \
	GameBrowser.vala \
	GameBrowserUI.vala \
	GuiInstaller.vala \
	InterfaceHelper.vala \
	Spawning.vala \
	SpawningResult.vala \
	Utility.vala \
	Data/Color.vala \
	Data/Favorites.vala \
	Data/GameBrowserAppearance.vala \
	Data/GameBrowserState.vala \
	Data/GameBrowserViewData.vala \
	Data/GameSettings.vala \
	Data/GamesRunList.vala \
	Data/GameList/AllGames.vala \
	Data/GameList/AllGamesCache.vala \
	Data/GameList/GameFolder.vala \
	Data/GameList/GameFolderCache.vala \
	Data/GameList/GameItem.vala \
	Data/GameList/IGameListNode.vala \
	Data/Options/DoubleOption.vala \
	Data/Options/FlagOption.vala \
	Data/Options/IntegerOption.vala \
	Data/Options/MultipleChoiceOption.vala \
	Data/Options/Option.vala \
	Data/Options/OptionGrouping.vala \
	Data/Options/OptionSet.vala \
	Data/Options/OptionType.vala \
	Data/Options/StringOption.vala \
	Data/Platforms/NativePlatform.vala \
	Data/Platforms/NativePlatformCategory.vala \
	Data/Platforms/Platform.vala \
	Data/Platforms/PlatformFolder.vala \
	Data/Platforms/PlatformFolderData.vala \
	Data/Platforms/PlatformListNode.vala \
	Data/Platforms/PlatformNode.vala \
	Data/Platforms/PlatformProgramSettingsMap.vala \
	Data/Platforms/PlatformProvider.vala \
	Data/Platforms/ProgramPlatform.vala \
	Data/Platforms/RomPlatform.vala \
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
	Fields/ColorField.vala \
	Fields/ClockSpeedField.vala \
	Fields/CustomCommandField.vala \
	Fields/GameBrowserAppearanceField.vala \
	Fields/GameSettingsListField.vala \
	Fields/NativePlatformCategoryAppListField.vala \
	Fields/NativePlatformCategoryListField.vala \
	Fields/NativePlatformSubCategoryListField.vala \
	Fields/OptionGroupingField.vala \
	Fields/PlatformFolderListField.vala \
	Fields/PlatformListField.vala \
	Fields/PlatformNodeListField.vala \
	Fields/PndAppField.vala \
	Fields/PndCategoryField.vala \
	Fields/PndSelectionField.vala \
	Fields/ProgramAppIdField.vala \
	Fields/ProgramDefaultSettingsField.vala \
	Fields/ProgramField.vala \
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
	Layers/Controls/DoubleEntry.vala \
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
	Layers/GameBrowser/PlatformSelectorOverlay.vala \
	Layers/GameBrowser/SelectorOverlay.vala \
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
	Menus/Concrete/ChangeViewMenu.vala \
	Menus/Concrete/ExitMenu.vala \
	Menus/Concrete/GameBrowserAppearanceMenu.vala \
	Menus/Concrete/GameFolderMenu.vala \
	Menus/Concrete/GameMenu.vala \
	Menus/Concrete/GameSettingsMenu.vala \
	Menus/Concrete/MainMenu.vala \
	Menus/Concrete/OptionGroupingMenu.vala \
	Menus/Concrete/PlatformFolderMenu.vala \
	Menus/Concrete/PlatformMenu.vala \
	Menus/Concrete/PlatformProgramSettingsMapMenu.vala \
	Menus/Concrete/ProgramDefaultSettingsMenu.vala \
	Menus/Concrete/ProgramMenu.vala \
	Menus/Concrete/SwitchGuiMenu.vala \
	Menus/Fields/BooleanField.vala \
	Menus/Fields/DoubleField.vala \
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
	Menus/MenuItemSeparator.vala \
	Menus/MenuItemActionType.vala \
	Menus/MenuObject.vala \
	Menus/MenuSelector.vala \
	Menus/ObjectBrowserItem.vala \
	Menus/ObjectMenu.vala \
	Menus/SubMenuItem.vala \
	Selectors/EverythingSelector.vala \
	Selectors/GameFolderSelector.vala \
	Selectors/PlatformFolderSelector.vala \
	Selectors/PlatformSelector.vala \
	Selectors/Selector.vala \
	Selectors/SelectorItemSet.vala \
	$(NULL)

gtksourceview_custom_SOURCES = \
	gtksourceview/embedded_languages.c \
	gtksourceview/gtksourcebuffer.c \
	gtksourceview/gtksourceiter.c \
	gtksourceview/gtksourceview.c \
	gtksourceview/gtksourceundomanager.c \
	gtksourceview/gtksourceundomanagerdefault.c \
	gtksourceview/gtktextregion.c \
	gtksourceview/gtksourcelanguage.c \
	gtksourceview/gtksourcelanguagemanager.c \
	gtksourceview/gtksourcelanguage-parser-1.c \
	gtksourceview/gtksourcelanguage-parser-2.c \
	gtksourceview/gtksourceview-i18n.c \
	gtksourceview/gtksourceview-utils.c \
	gtksourceview/gtksourcestyle.c \
	gtksourceview/gtksourcestyleschememanager.c \
	gtksourceview/gtksourcestylescheme.c \
	gtksourceview/gtksourceengine.c \
	gtksourceview/gtksourcecontextengine.c \
	gtksourceview/gtksourcemark.c \
	gtksourceview/gtksourceprintcompositor.c \
	gtksourceview/gtksourcegutter.c \
	gtksourceview/gtksourcecompletion.c \
	gtksourceview/gtksourcecompletioninfo.c \
	gtksourceview/gtksourcecompletionitem.c \
	gtksourceview/gtksourcecompletionproposal.c \
	gtksourceview/gtksourcecompletionprovider.c \
	gtksourceview/gtksourcecompletionmodel.c \
	gtksourceview/gtksourcecompletionutils.c \
	gtksourceview/gtksourcecompletioncontext.c \
	gtksourceview/gtksourceview-marshal.c \
	gtksourceview/gtksourceview-typebuiltins.c \
	$(NULL)

pandafe_SOURCES = \
	$(gtksourceview_custom_SOURCES) \
	pandafe.vala.stamp \
	$(pandafe_VALASOURCES:.vala=.c) \
	$(NULL)

pandafe.submodule-libs.check:
	@$(top_srcdir)/scripts/update-stamp-from-dependencies.sh main.c "$(GEE_LTLIB)" "$(CATAPULT_LTLIB)" "$(PANDORA_GLIB_LTLIB)"

pandafe.submodule-vapi.check:
	@$(top_srcdir)/scripts/update-stamp-from-dependencies.sh main.vala "$(GEE_VAPI)" "$(CATAPULT_VAPI)" "$(PANDORA_GLIB_VAPI)"

pandafe.vala.stamp: $(pandafe_VALASOURCES) 
	$(VALA_V)$(VALAC) $(VALAFLAGS) -C $(SUBMODULE_VALAFLAGS) --vapidir $(srcdir)/../vapi \
		--pkg catapult --pkg pandora-glib --pkg gee-0.8 --pkg gtk+-2.0 --pkg sdl --pkg sdl-image --pkg sdl-ttf --pkg sdl-gfx --pkg posix \
		--pkg gtksourceview-2.0 --pkg vte --pkg build-info --pkg GdkKeySyms --pkg sdl-keyboard $^
	@touch $@

build-info.h: 
	@echo "#define PACKAGE_DATADIR \"$(pkgdatadir)\"" > build-info.h; \
	LOCAL_CONFIG_DIR=".pandafe"; \
	if test "x$(prefix)" = "x$(PND_MOUNT_DIR)"; then \
		LOCAL_CONFIG_DIR="."; \
	fi; \
	echo "#define LOCAL_CONFIG_DIR \"$$LOCAL_CONFIG_DIR\"" >> build-info.h

pandafe_LDADD = \
	$(GEE_LTLIB) \
	$(CATAPULT_LTLIB) \
	$(PANDORA_GLIB_LTLIB) \
	$(SDL_LIBS) \
	$(SDL_IMAGE_LIBS) \
	$(SDL_TTF_LIBS) \
	$(SDL_GFX_LIBS) \
	$(GTK_LIBS) \
	$(LIBXML_LIBS) \
	$(VTE_LIBS) \
	$(NULL)

EXTRA_DIST = \
	$(pandafe_VALASOURCES) \
	pandafe.vala.stamp \
	$(NULL)

MAINTAINERCLEANFILES = \
  $(pandafe_VALASOURCES:.vala=.c) \
  $(NULL)
