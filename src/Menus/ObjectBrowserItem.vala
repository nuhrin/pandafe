using SDL;

namespace Menus
{
	public class ObjectBrowserItem : MenuItem
	{		
		public ObjectBrowserItem(string name, string? help=null, Object obj) {
			base(name, help);
			this.object = obj;
		}
		public Object object { get; set; }
		public bool was_saved { get; private set; }
		
		public signal void cancelled();
		public signal void saved();
		public signal void finished();
		
		public override void activate(MenuSelector selector) {
			was_saved = ObjectMenu.edit(name, object);
			if (was_saved == true)
				saved();
			else
				cancelled();
			finished();
		}
		
		public override bool is_menu_item() { return true; }
	}
}
