using Fields;
using Menus.Fields;
using Data.GameList;

namespace Menus.Concrete
{
	public class GameFolderMenu : Menu  
	{	
		GameFolder folder;		
		Platform platform;
		public GameFolderMenu(GameFolder folder, string? help=null) {
			string name = "Folder: " + ((folder.parent != null) ? folder.name : "Root");
			base(name, help);
			this.title = "Game " + name;
			this.folder = folder;			
			platform = folder.platform();
			ensure_items();
		}

		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Rescan", "Rescan the folder for game changes", "Scanning folder...", () => {
				if (platform.platform_type == PlatformType.NATIVE) {
					this.message("Scanning PNDs...");
					Data.rescan_pnd_data();
				}
				folder.rescan_children(true);
			}));

			items.add(new MenuItemSeparator());
			
			var platform_menu = new PlatformMenu(platform);
			var platform_item_index = items.size;
			platform_menu.saved.connect(() => refresh(platform_item_index));			
			items.add(platform_menu);
		}		
	}
}
