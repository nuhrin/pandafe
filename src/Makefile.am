NULL =

AUTOMAKE_OPTIONS = subdir-objects

AM_CPPFLAGS = \
	$(GEE_CFLAGS) \
	$(CATAPULT_CFLAGS) \
	$(PANDORA_GLIB_CFLAGS) \
	$(SDL_CFLAGS) \
	$(SDL_IMAGE_CFLAGS) \
	$(GTK_CFLAGS) \
	$(VTE_CFLAGS) \
	-I./gtksourceview \
	$(NULL)

BUILT_SOURCES = \
	pandafe.submodule-vapi.check \
	pandafe.submodule-libs.check \
	build-info.h \
	$(NULL)

bin_PROGRAMS = \
	pandafe \
	$(NULL)

pandafe_SOURCES = \
	main.vala \
	EventHandler.vala \
	GameBrowser.vala \
	GameBrowserUI.vala \
	GuiInstaller.vala \
	InterfaceHelper.vala \
	RuntimeEnvironment.vala \
	Spawning.vala \
	SpawningResult.vala \
	Utility.vala \
	Data/Color.vala \
	Data/Favorites.vala \
	Data/GameBrowserState.vala \
	Data/GameBrowserViewData.vala \
	Data/GameSettings.vala \
	Data/GamesRunList.vala \
	Data/Appearances/Appearance.vala \
	Data/Appearances/AppearanceAreaType.vala \
	Data/Appearances/AppearanceAreaUI.vala \
	Data/Appearances/AppearanceDefaults.vala \
	Data/Appearances/AppearanceFontAreaType.vala \
	Data/Appearances/AppearanceInfo.vala \
	Data/Appearances/AppearanceProvider.vala \
	Data/Appearances/AppearanceType.vala \
	Data/Appearances/GameBrowser/GameBrowserAppearance.vala \
	Data/Appearances/GameBrowser/GameBrowserAppearanceBase.vala \
	Data/Appearances/GameBrowser/GameBrowserAreaBase.vala \
	Data/Appearances/GameBrowser/GameBrowserFontAreaBase.vala \
	Data/Appearances/GameBrowser/GameBrowserFooter.vala \
	Data/Appearances/GameBrowser/GameBrowserHeader.vala \
	Data/Appearances/GameBrowser/GameBrowserList.vala \
	Data/Appearances/GameBrowser/GameBrowserListSpacing.vala \
	Data/Appearances/Menu/MenuAppearance.vala \
	Data/Appearances/Menu/MenuAppearanceBase.vala \
	Data/Appearances/Menu/MenuAreaBase.vala \
	Data/Appearances/Menu/MenuControls.vala \
	Data/Appearances/Menu/MenuFontAreaBase.vala \
	Data/Appearances/Menu/MenuFooter.vala \
	Data/Appearances/Menu/MenuHeader.vala \
	Data/GameList/AllGames.vala \
	Data/GameList/GameFolder.vala \
	Data/GameList/GameItem.vala \
	Data/GameList/GameNodeMenuData.vala \
	Data/GameList/IGameListNode.vala \
	Data/GameList/RomFiles.vala \
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
	Data/Pnd/AppOverride.vala \
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
	Fields/AppearanceField.vala \
	Fields/ColorField.vala \
	Fields/ClockSpeedField.vala \
	Fields/CustomCommandField.vala \
	Fields/GameSettingsListField.vala \
	Fields/NativePlatformCategoryAppListField.vala \
	Fields/NativePlatformCategoryListField.vala \
	Fields/NativePlatformSubCategoryListField.vala \
	Fields/OptionGroupingField.vala \
	Fields/PlatformFolderListField.vala \
	Fields/PlatformListField.vala \
	Fields/PlatformNodeListField.vala \
	Fields/PndCategoryField.vala \
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
	Layers/Controls/DeletionConfirmation.vala \
	Layers/Controls/DoubleEntry.vala \
	Layers/Controls/FileChooser.vala \
	Layers/Controls/FolderChooser.vala \
	Layers/Controls/GameCategorySelector.vala \
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
	Layers/GameBrowser/CategorySelectorOverlay.vala \
	Layers/GameBrowser/HeaderLayer.vala \
	Layers/GameBrowser/MenuOverlay.vala \
	Layers/GameBrowser/PlatformSelectorOverlay.vala \
	Layers/GameBrowser/SelectorOverlay.vala \
	Layers/GameBrowser/StatusMessageLayer.vala \
	Layers/MenuBrowser/MenuHeaderLayer.vala \
	Layers/MenuBrowser/MenuMessageLayer.vala \
	Layers/DummyLayer.vala \
	Layers/Layer.vala \
	Layers/LayerBase.vala \
	Layers/ScreenAlphaLayer.vala \
	Layers/ScreenLayer.vala \
	Layers/SurfaceLayer.vala \
	Menus/Concrete/ChangeViewMenu.vala \
	Menus/Concrete/ExitMenu.vala \
	Menus/Concrete/GameAppMenu.vala \
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
	Menus/Concrete/RomFileMenu.vala \
	Menus/Concrete/SwitchGuiMenu.vala \
	Menus/Fields/BooleanField.vala \
	Menus/Fields/DoubleField.vala \
	Menus/Fields/EnumField.vala \
	Menus/Fields/FileField.vala \
	Menus/Fields/FolderField.vala \
	Menus/Fields/IntegerField.vala \
	Menus/Fields/ListField.vala \
	Menus/Fields/ObjectBrowserField.vala \
	Menus/Fields/ObjectField.vala \
	Menus/Fields/MenuItemField.vala \
	Menus/Fields/MenuItemFieldSeparator.vala \
	Menus/Fields/StringField.vala \
	Menus/Fields/StringListField.vala \
	Menus/Fields/StringSelectionField.vala \
	Menus/Fields/UIntField.vala \
	Menus/Fields/ValueSelectionField.vala \
	Menus/Menu.vala \
	Menus/MenuBrowser.vala \
	Menus/MenuBrowserItem.vala \
	Menus/MenuBuilder.vala \
	Menus/MenuItem.vala \
	Menus/MenuItemSeparator.vala \
	Menus/MenuItemActionType.vala \
	Menus/MenuObject.vala \
	Menus/MenuSelector.vala \
	Menus/MenuUI.vala \
	Menus/ObjectBrowserItem.vala \
	Menus/ObjectMenu.vala \
	Menus/SubMenuItem.vala \
	Selectors/EverythingSelector.vala \
	Selectors/GameCategorySelector.vala \
	Selectors/GameFolderSelector.vala \
	Selectors/GamePlatformSelector.vala \
	Selectors/PlatformFolderSelector.vala \
	Selectors/PlatformSelector.vala \
	Selectors/Selector.vala \
	Selectors/SelectorItemSet.vala \
	$(NULL)

pandafe.submodule-libs.check:
	@$(top_srcdir)/scripts/update-stamp-from-dependencies.sh main.c "$(GEE_LTLIB)" "$(CATAPULT_LTLIB)" "$(PANDORA_GLIB_LTLIB)"

pandafe.submodule-vapi.check:
	@$(top_srcdir)/scripts/update-stamp-from-dependencies.sh main.vala "$(GEE_VAPI)" "$(CATAPULT_VAPI)" "$(PANDORA_GLIB_VAPI)"

pandafe_VALAFLAGS = \
	$(VALAFLAGS) -C $(SUBMODULE_VALAFLAGS) --vapidir $(srcdir)/../vapi \
		--pkg catapult --pkg pandora-glib --pkg gee-0.8 --pkg gtk+-2.0 --pkg sdl --pkg sdl-image --pkg sdl-ttf --pkg sdl-gfx --pkg posix \
		--pkg gtksourceview-2.0 --pkg vte --pkg build-info --pkg GdkKeySyms --pkg sdl-keyboard 

build-info.h: 
	@echo "#define PACKAGE_DATADIR \"$(pkgdatadir)\"" > build-info.h; \
	IS_PND=0; \
	if test "x$(prefix)" = "x$(PND_MOUNT_DIR)"; then \
		IS_PND=1; \
	fi; \
	echo "#define IS_PND $$IS_PND" >> build-info.h;

pandafe_LDADD = \
	$(GEE_LTLIB) \
	$(CATAPULT_LTLIB) \
	$(PANDORA_GLIB_LTLIB) \
	$(top_builddir)/gtksourceview/libgtksourceview_custom.la \
	$(SDL_LIBS) \
	$(SDL_IMAGE_LIBS) \
	$(SDL_TTF_LIBS) \
	$(SDL_GFX_LIBS) \
	$(GTK_LIBS) \
	$(VTE_LIBS) \
	-lm \
	$(NULL)

EXTRA_DIST = \
	$(NULL)

MAINTAINERCLEANFILES = \
  $(NULL)
