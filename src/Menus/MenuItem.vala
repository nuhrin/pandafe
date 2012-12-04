/* MenuItem.vala
 * 
 * Copyright (C) 2012 nuhrin
 * 
 * This file is part of Pandafe.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *      nuhrin <nuhrin@oceanic.to>
 */

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
			_enabled = is_initially_enabled();
		}
		string _name;
		string? _help;
		MenuItemActivationAction? activate_action;
		string? activate_action_message;
		
		public unowned string name { get { return _name; } }
		public MenuItemActionType action { get; private set; }
		public unowned string? help { get { return _help; } }
		
		public bool enabled 
		{
			get { return _enabled; }
			set {
				if (can_change_enabled_state() == true)
					_enabled = value;
			}
		}
		bool _enabled;
		
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
		
		public virtual bool handles_keydown_event(KeyboardEvent event) { return false; }
		public virtual bool process_keydown_event(KeyboardEvent event) { return false; }
		public virtual bool handles_keyup_event(KeyboardEvent event) { return false; }
		public virtual bool process_keyup_event(KeyboardEvent event) { return false; }

		public virtual bool is_menu_item() { return false; }
		
		protected virtual bool is_initially_enabled() { return true; }
		protected virtual bool can_change_enabled_state() { return true; }
	}
}
