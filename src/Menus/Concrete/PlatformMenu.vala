using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class PlatformMenu : Menu  
	{	
		Platform platform;
		public PlatformMenu(Platform platform) {
			base("Platform: " + platform.name);
			this.platform = platform;
			ensure_items();		
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Edit", null, null, () => {
				ObjectMenu.edit("Platform: " + platform.name, platform);
			}));
			items.add(new MenuItem.custom("Rescan", null, "Scanning platform folders...", () => {
				platform.get_root_folder().rescan_children(true);
			}));		
		}						
	}

}
