using SDL;

namespace Menus
{
	public class MenuBrowserItem : SubMenuItem, MenuItem
	{	
		Menu _menu;
		public MenuBrowserItem(string name, string? help=null, Menu menu) {
			base(name, help);
			set_menu(menu);
		}
		public Menu menu { get { return _menu; } }
		public void set_menu(Menu menu) {
				_menu = menu;
				_menu.cancelled.connect(() => cancelled());
				_menu.saved.connect(() => saved());
				_menu.finished.connect(() => finished());
		}		
		
		public override void activate(MenuSelector selector) { 
			new MenuBrowser(menu).run();
		}
		
		public override bool is_menu_item() { return true; }
	}
}
