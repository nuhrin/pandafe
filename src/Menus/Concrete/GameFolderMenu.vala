using Fields;
using Menus.Fields;
using Data.GameList;

namespace Menus.Concrete
{
	public class GameFolderMenu : Menu  
	{	
		GameFolder folder;
		public GameFolderMenu(GameFolder folder) {
			base("Folder: " + ((folder.parent != null) ? folder.name : "Root"));
			this.folder = folder;
			ensure_items();		
		}		
				
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Rescan", null, "Scanning folder...", () => {
				folder.rescan_children(true);
			}));
			if (folder.platform().platform_type == PlatformType.ROM) {
				items.add(new MenuItem.custom("Open in terminal", null, "Opening terminal...", () => {
					debug("(open terminal)");
				}));
			}
		}		
	}
}
