using Fields;
using Menus.Fields;
using Data.GameList;

namespace Menus.Concrete
{
	public class GameFolderMenu : Menu  
	{	
		GameFolder folder;		
		Platform platform;
		public GameFolderMenu(GameFolder folder) {
			base("Folder: " + ((folder.parent != null) ? folder.name : "Root"));
			this.folder = folder;			
			platform = folder.platform();
			ensure_items();		
		}		
				
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Rescan", null, "Scanning folder...", () => {
				folder.rescan_children(true);
			}));
//~ 			if (folder.platform().platform_type == PlatformType.ROM) {
//~ 				items.add(new MenuItem.custom("Open in terminal", null, "Opening terminal...", () => {
//~ 					debug("(open terminal)");
//~ 				}));
//~ 			}
			
			var platform_menu = new PlatformMenu(platform);
			var platform_item_index = items.size;
			platform_menu.saved.connect(() => refresh(platform_item_index));			
			items.add(platform_menu);
		}		
	}
}
