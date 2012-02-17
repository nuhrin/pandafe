using SDL;

namespace Menus
{
	public delegate void MenuItemActivationAction();
	public class MenuItem : Object
	{
		public MenuItem.cancel_item(string? name=null, string? help=null) { this.with_action(MenuItemActionType.CANCEL, name, help); }
		public MenuItem.save_item(string? name=null, string? help=null) { this.with_action(MenuItemActionType.SAVE, name, help); }
		public MenuItem.save_and_quit_item(string? name=null, string? help=null) { 
			this.with_action(MenuItemActionType.SAVE_AND_QUIT, name ?? MenuItemActionType.SAVE.name(), help); 
		}
		public MenuItem.quit_item(string? name=null, string? help=null) { this.with_action(MenuItemActionType.QUIT, name, help); }
		
		public MenuItem.custom(string name, string? help, string? action_message, owned MenuItemActivationAction action) {
			this(name, help);
			this.activate_action_message = action_message;
			this.activate_action = (owned)action;
		}
		
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
		MenuItemActivationAction? activate_action;
		string? activate_action_message;
		
		public unowned string name { get { return _name; } }
		public MenuItemActionType action { get; private set; }
		public unowned string? help { get { return _help; } }
		
		public virtual void activate(MenuSelector selector) { 
			if (activate_action != null) {
				if (activate_action_message != null) {
					selector.menu.message(activate_action_message);
					activate_action();
					selector.menu.message("");
				} else {
					activate_action();
				}
			}
		}

		public virtual bool process_keydown_event(KeyboardEvent event) { return false; }
		public virtual bool process_keyup_event(KeyboardEvent event) { return false; }

		public virtual bool is_menu_item() { return false; }
	}
}
