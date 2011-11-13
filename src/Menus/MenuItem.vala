using SDL;

namespace Menus
{
	public class MenuItem : Object
	{
		string _name;
		string? _help;
		public MenuItem(string name, string? help=null) {
			_name = name;
			_help = help;
		}
		public unowned string name { get { return _name; } }
		public unowned string? help { get { return _help; } }
		public virtual bool can_activate { get { return false; } }

		public virtual bool process_keydown_event(KeyboardEvent event) { return false; }
		public virtual bool process_keyup_event(KeyboardEvent event) { return false; }

		public virtual void connect_to_selector(MenuSelector selector) { }
	}
}
