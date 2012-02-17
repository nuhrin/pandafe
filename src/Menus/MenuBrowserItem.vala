using SDL;

namespace Menus
{
	public class MenuBrowserItem : MenuItem
	{	
		Menu _menu;
		public MenuBrowserItem(string name, string? help=null, Menu menu) {
			base(name, help);
			this.menu = menu;
		}
		public Menu menu { 
			get { return _menu; }
			set {
				_menu = value;
				_menu.cancelled.connect(() => cancelled());
				_menu.saved.connect(() => saved());
				_menu.finished.connect(() => finished());
			}
		}
		
		public signal void cancelled();
		public signal void saved();
		public signal void finished();
		
		public override void activate(MenuSelector selector) { 
			new MenuBrowser(menu, 40, 40).run();
		}
		
		public override bool is_menu_item() { return true; }
		
//~ 		void connect_signals(Menu menu) {
//~ 			cancelled_handler_id = menu.cancelled.connect(() => cancelled());
//~ 			saved_handler_id = menu.saved.connect(() => saved());
//~ 			finished_handler_id = menu.finished.connect(() => finished());
//~ 		}
//~ 		void disconnect_signals(Menu menu) {
//~ 			this.disconnect(cancelled_handler_id);
//~ 			this.disconnect(saved_handler_id);
//~ 			this.disconnect(finished_handler_id);
//~ 		}
//~ 		ulong cancelled_handler_id;
//~ 		ulong saved_handler_id;
//~ 		ulong finished_handler_id;
	}
}
