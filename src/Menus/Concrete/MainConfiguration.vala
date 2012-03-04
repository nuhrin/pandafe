using Gee;
using Catapult;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class MainConfiguration : Menu
	{
		public static void run() {
			var menu = new MainConfiguration();
			menu.add_item(new MenuItem.cancel_item("Return"));
			new MenuBrowser(new MainConfiguration()).run();
		}
		
		public MainConfiguration() { 
			base("Pandafe Configuration");
			ensure_items();
		}
				
		protected override void populate_items(Gee.List<MenuItem> items) { 
			var preferences = Data.preferences();
			var appearance_field = new GameBrowserAppearanceField("appearance", "Appearance", null, null, preferences.appearance, new Data.GameBrowserAppearance.default());
			appearance_field.changed.connect(() => {
				Data.save_preferences();
				@interface.game_browser_ui.set_appearance(preferences.appearance);
			});
			items.add(appearance_field);
			var platform_folders_field = new PlatformFolderListField.root("folders", "Folders", null, Data.platforms().get_platform_folder_data().folders);
			platform_folders_field.changed.connect(() => {
				string? error;
				if (Data.platforms().save_platform_folder_data(out error) == false)
					this.error(error);
			});
			items.add(platform_folders_field);
//~ 			var platforms = new PlatformListField("platforms", "Platforms", null, Data.platforms());
//~ 			platforms.changed.connect(() => {
//~ 				Data.preferences().update_platform_order(platforms.value);				
//~ 				Data.save_preferences();
//~ 				Data.flush_platforms();
//~ 			});
//~ 			items.add(platforms);
			items.add(new MenuItem.custom("Scan PNDs", null, "Scanning PNDs...", () => {
				Data.rescan_pnd_data();
			}));
		}		

	}
}
