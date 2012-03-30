using Data.Platforms;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class PlatformMenu : Menu  
	{	
		Platform platform;
		PlatformFolder? platform_folder;
		public PlatformMenu(Platform platform, string? help=null, PlatformFolder? platform_folder=null) {
			base("Platform: " + platform.name, help ?? "Show a menu for the current platform");
			this.platform = platform;
			this.platform_folder = platform_folder;
			ensure_items();		
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Edit", "Edit the platform definition", null, () => {
				if (ObjectMenu.edit("Platform: " + platform.name, platform) == true) {
					saved();
				}
			}));
			items.add(new MenuItem.custom("Rescan", "Rescan the platform for game changes", "", () => {
				if (platform.platform_type == PlatformType.NATIVE) {
					this.message("Scanning PNDs...");
					Data.rescan_pnd_data();
				}
				platform.rescan(f=> this.message("Scanning folder '%s'...".printf(f.unique_name())));
				refresh(1);
			}));
			
			if (platform_folder != null) {
				items.add(new MenuItemSeparator());
				
				var platform_folder_menu = new PlatformFolderMenu(platform_folder, "Show a menu for the folder containing this platform");
				var platform_folder_item_index = items.size;
				platform_folder_menu.saved.connect(() => refresh(platform_folder_item_index));
				items.add(platform_folder_menu);
			}
		}						
	}

}
