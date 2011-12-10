using SDL;

namespace Menus
{
	public class MenuItem : Object
	{
		public MenuItem.cancel_item(string? name=null, string? help=null) { this.with_action(MenuItemActionType.CANCEL, name, help); }
		public MenuItem.save_item(string? name=null, string? help=null) { this.with_action(MenuItemActionType.SAVE, name, help); }
		public MenuItem.quit_item(string? name=null, string? help=null) { this.with_action(MenuItemActionType.QUIT, name, help); }
		protected MenuItem.with_action(MenuItemActionType action, string? name=null, string? help=null) {
			this(name ?? action.name(), help);
			this.action = action;
		}		
		protected MenuItem(string name, string? help=null) {
			_name = name;
			_help = help;
		}
		string _name;
		string? _help;
		
		public unowned string name { get { return _name; } }
		public MenuItemActionType action { get; private set; }		
		public unowned string? help { get { return _help; } }
		
		public virtual void activate(MenuSelector selector) { }

		public virtual bool process_keydown_event(KeyboardEvent event) { return false; }
		public virtual bool process_keyup_event(KeyboardEvent event) { return false; }

		public virtual void connect_to_selector(MenuSelector selector) { }
	}
}
