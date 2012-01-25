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
		
		public override bool do_cancel() {
			return true;
		}
	
		public override bool do_save() {
			return true;
		}
				
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new RescanItem(folder));
			if (folder.platform().platform_type == PlatformType.ROM)
				items.add(new OpenTerminalItem(folder));
			items.add(new MenuItem.cancel_item("Return"));			
		}
		
		class RescanItem : FolderActionItem {
			public RescanItem(GameFolder folder) { base("Rescan", "Scanning folder...", folder); }
			public override void do_action() { folder.rescan_children(true); }
		}
		class OpenTerminalItem : FolderActionItem {
			public OpenTerminalItem(GameFolder folder) { base("Open in terminal", "Opening terminal...", folder); }
			public override void do_action() { debug("(open terminal)"); }
		}
		abstract class FolderActionItem : MenuItem {
			protected GameFolder folder;
			string message;
			protected FolderActionItem(string name, string message, GameFolder folder) {
				base(name);
				this.folder = folder;
				this.message = message;
			}
			public override void activate(MenuSelector selector) {
				selector.menu.message(message);
				do_action();
				selector.menu.message("");
			}
			protected abstract void do_action();
		}
	}
}
