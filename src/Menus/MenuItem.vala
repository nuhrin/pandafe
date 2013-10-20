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
		static uint next_unique_id;
		static Gee.HashMap<uint,string> id_name_hash;
		static Gee.HashMap<uint,string> id_type_hash;
		static Gee.HashMap<string,Gee.ArrayList<uint>> watch_ids_hash;
		static void register_creation(MenuItem item) {
			if (id_name_hash == null) {
				id_name_hash = new Gee.HashMap<uint,string>();
				id_type_hash = new Gee.HashMap<uint,string>();
			}
			id_name_hash[next_unique_id] = item.name;
			id_type_hash[next_unique_id] = item.get_type().name();
			item.unique_id = next_unique_id;
			next_unique_id++;			
		}
		static void register_destruction(MenuItem item) {
			id_name_hash.unset(item.unique_id);
			id_type_hash.unset(item.unique_id);
		}
		public static void print_all_registered_items() {
			if (id_name_hash == null || id_name_hash.size == 0)
				return;
			print("all MenuItem instances not destroyed:\n");
			var ids = new Gee.ArrayList<uint>();
			ids.add_all(id_name_hash.keys);
			ids.sort();
			foreach(var uid in ids) {
				print("- %u: %s (%s)\n", uid, id_name_hash[uid], id_type_hash[uid]);
			}
		}
		public static void register_watch(string name) {
			if (watch_ids_hash == null)
				watch_ids_hash = new Gee.HashMap<string,Gee.ArrayList<uint>>();
			if (watch_ids_hash.has_key(name) == true)
				GLib.error("register_watch: watch %s is already registered. :(", name);
			
			var ids = new Gee.ArrayList<uint>();
			ids.add_all(id_name_hash.keys);
			watch_ids_hash[name] = ids;
		}
		public static void update_watch(string name)  {
			if (watch_ids_hash == null || watch_ids_hash.has_key(name) == false)
				GLib.error("update_watch: watch %s is not registered. :(", name);
			
			var ids = watch_ids_hash[name];
			var new_ids = new Gee.ArrayList<uint>();
			new_ids.add_all(id_name_hash.keys);
			foreach(var id in id_name_hash.keys) {
				if (ids.contains(id) == true)
					new_ids.remove(id);
			}
			watch_ids_hash[name] = new_ids;
		}
		public static void unregister_watch(string name) {
			if (watch_ids_hash == null || watch_ids_hash.has_key(name) == false)
				GLib.error("unregister_watch: watch %s is not registered. :(", name);
								
			var ids = watch_ids_hash[name];
			watch_ids_hash.unset(name);
			var remaining_ids = new Gee.ArrayList<uint>();
			foreach(var id in ids) {
				if (id_name_hash.has_key(id) == true)
					remaining_ids.add(id);
			}
			if (remaining_ids.size == 0)
				return;
			remaining_ids.sort();
			print("watch %s: all MenuItem instances not destroyed:\n", name);
			foreach(var uid in remaining_ids) {
				print("- %u: %s (%s)\n", uid, id_name_hash[uid], id_type_hash[uid]);
			}
		}
		
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
			if (RuntimeEnvironment.dev_mode)
				register_creation(this);
		}
		~MenuItem() {
			if (RuntimeEnvironment.dev_mode)
				register_destruction(this);
		}
		uint unique_id;
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
