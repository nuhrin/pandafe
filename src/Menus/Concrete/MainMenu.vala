using Gee;
using Catapult;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class MainMenu : Menu
	{
		public MainMenu() {
			base("Pandafe");
			ensure_items();			
		}
		protected override void populate_items(Gee.List<MenuItem> items) {
			items.add(new MenuBrowserItem("Config", null, new ConfigurationMenu()));
			items.add(new MenuBrowserItem("Data", null, new DataMenu()));
			items.add(new MenuItem.custom("Scan PNDs", null, "Scanning PNDs...", () => {
				Data.rescan_pnd_data();
			}));
			
			items.add(new MenuItemSeparator());
			items.add(new MenuItem.custom("Quit", null, "", () => {
				if (Data.pnd_mountset().has_mounted == true) {
					message("Unmounting PNDs...");
					Data.pnd_mountset().unmount_all();
				}
				@interface.quit_all();
			}));
		}
	}
	class ConfigurationMenu : Menu
	{		
		public ConfigurationMenu() { 
			base("Pandafe Configuration");
			ensure_items();
		}
				
		protected override void populate_items(Gee.List<MenuItem> items) { 
			var preferences = Data.preferences();
			var appearance_field = new GameBrowserAppearanceField("appearance", "Appearance", null, "Default Appearance", preferences.appearance, new Data.GameBrowserAppearance.default());
			appearance_field.changed.connect(() => {
				Data.save_preferences();
				@interface.game_browser_ui.set_appearance(preferences.appearance);
			});
			items.add(appearance_field);
			var platform_folders_field = new PlatformFolderListField.root("folders", "Platforms", null, Data.platforms().get_platform_folder_data().folders);
			var platform_folders_item_index = items.size;
			platform_folders_field.changed.connect(() => {
				string? error;
				if (Data.platforms().save_platform_folder_data(out error) == true)
					refresh(platform_folders_item_index);
				else
					this.error(error);
			});
			items.add(platform_folders_field);
		}
	}
	class DataMenu : Menu
	{
		public DataMenu() { 
			base("Pandafe Data Management");
			ensure_items();
		}
				
		protected override void populate_items(Gee.List<MenuItem> items) { 
			var platforms_field = new PlatformListField("platforms", "Platforms", null, Data.platforms().get_all_platforms().to_list(), "Platforms Data");
			items.add(platforms_field);
			var programs_field = new ProgramDataListField("programs", "Programs", null, Data.programs().get_all_programs().to_list(), "Programs Data");
			items.add(programs_field);
			var gamesettings_field = new GameSettingsListField("settings", "Game Settings", null, "Game Settings Data");
			items.add(gamesettings_field);
		}
	}
}
