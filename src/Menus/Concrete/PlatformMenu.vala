using Data.Platforms;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class PlatformMenu : Menu  
	{	
		Platform platform;
		PlatformFolder? platform_folder;
		public PlatformMenu(Platform platform, PlatformFolder? platform_folder=null) {
			base("Platform: " + platform.name);
			this.platform = platform;
			this.platform_folder = platform_folder;
			ensure_items();		
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Edit", null, null, () => {
				if (ObjectMenu.edit("Platform: " + platform.name, platform) == true) {
					saved();
				}
			}));
			items.add(new MenuItem.custom("Rescan", null, "Scanning platform folders...", () => {
				platform.rescan(f=> this.message("Scanning folder '%s'...".printf(f.unique_name())));
				refresh(1);
			}));
			
			if (platform_folder != null) {
				items.add(new MenuItemSeparator());
				
				var platform_folder_menu = new PlatformFolderMenu(platform_folder);
				var platform_folder_item_index = items.size;
				platform_folder_menu.saved.connect(() => refresh(platform_folder_item_index));
				items.add(platform_folder_menu);
			}
		}						
	}

}
