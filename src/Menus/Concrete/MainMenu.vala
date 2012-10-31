using Gee;
using Catapult;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class MainMenu : Menu
	{
		public MainMenu() {
			base("Pandafe " + Build.BUILD_VERSION);
			ensure_items();			
		}
		protected override void populate_items(Gee.List<MenuItem> items) {
			items.add(new MenuBrowserItem("Config", "Show configuration menu", new ConfigurationMenu()));
			items.add(new MenuBrowserItem("Data", "Show data management menu", new DataMenu()));
			items.add(new MenuItem.custom("Scan PNDs", "Scan system for new pnd apps, and rescan native platform", "Scanning PNDs...", () => {
				Data.rescan_pnd_data();
				Data.platforms().get_native_platform().rescan(f=> this.message("Scanning folder '%s'...".printf(f.unique_name())));
				refresh(2);
			}));
			
			items.add(new MenuItemSeparator());
			if (Data.preferences().show_exit_menu == true) {
				items.add(new MenuBrowserItem("Quit", "Exit Pandafe", new ExitMenu()));
			} else {
				items.add(new MenuItem.custom("Quit", "Exit Pandafe", "", () => {
					@interface.cleanup_and_exit(msg => this.message(msg));
				}));
			}
		}
	}
	class ConfigurationMenu : Menu
	{		
		public ConfigurationMenu() { 
			base("Pandafe Configuration");
			ensure_items();
		}
				
		protected override void populate_items(Gee.List<MenuItem> items) { 			
			items.add(ObjectMenu.get_browser_item("Preferences", "Pandafe Preferences", "Edit preferences", Data.preferences()));
			var platform_folders_field = new PlatformFolderListField.root("folders", "Platforms", "Edit platform folders", Data.platforms().get_platform_folder_data().folders);
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
			var platforms_field = new PlatformListField("platforms", "Platforms", "Add/Edit/Delete platform definitions", Data.platforms().get_all_platforms().to_list(), "Platforms Data");
			items.add(platforms_field);
			var programs_field = new ProgramDataListField("programs", "Programs", "Add/Edit/Delete program definitions", Data.programs().get_all_programs().to_list(), "Programs Data");
			items.add(programs_field);
			var gamesettings_field = new GameSettingsListField("settings", "Game Settings", "Edit/Delete all game settings", "Game Settings Data");
			items.add(gamesettings_field);
		}
	}
}
