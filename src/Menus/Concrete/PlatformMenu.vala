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
		
		public override bool do_cancel() {
			return true;
		}
	
		public override bool do_save() {
			return true;
		}
				
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new EditItem(platform));
			items.add(new RescanItem(platform));
			items.add(new MenuItem.cancel_item("Return"));			
		}		
		
		class EditItem : PlatformActionItem {
			public EditItem(Platform platform) { base("Edit", null, platform); }
			public override void do_action() {
				ObjectMenu.edit("Platform: " + platform.name, platform);
			}
		}
		class RescanItem : PlatformActionItem {
			public RescanItem(Platform platform) { base("Rescan", "Scanning platform folders...", platform); }
			public override void do_action() { platform.get_root_folder().rescan_children(true); }
		}
		abstract class PlatformActionItem : MenuItem {
			protected Platform platform;
			string? message;
			protected PlatformActionItem(string name, string? message, Platform platform) {
				base(name);
				this.platform = platform;
				this.message = message;
			}
			public override void activate(MenuSelector selector) {
				if (message != null) {
					selector.menu.message(message);
					do_action();
					selector.menu.message("");
				} else {
					do_action();
				}
			}
			protected abstract void do_action();
		}
	}

}
