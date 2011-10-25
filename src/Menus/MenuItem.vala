using SDL;

namespace Menus
{
	public class MenuItem : Object
	{
		string _name;
		public MenuItem(string name) {
			_name = name;
		}
		public unowned string name { get { return _name; } }

		public virtual bool can_activate { get { return false; } }

		public virtual bool process_keydown_event(KeyboardEvent event) { return false; }
		public virtual bool process_keyup_event(KeyboardEvent event) { return false; }
	}
}
