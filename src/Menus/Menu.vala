/* Menu.vala
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

using Gee;
using Catapult;

using Menus.Fields;

namespace Menus
{
	public class Menu : MenuItem
	{
		string? _title;
		weak Menu? _parent;
		ArrayList<MenuItem> _items;
		HashMap<string, MenuItemField> _field_id_hash;
		HashMap<string, int> _field_index_hash;
		Predicate<Menu>? on_save;
		Predicate<Menu>? on_cancel; 
		public Menu(string name, string? help=null, Menu? parent=null, owned Predicate? on_save=null, owned Predicate<Menu>? on_cancel=null ) {
			base(name, help);
			this.on_save = (owned)on_save;
			this.on_cancel = (owned)on_cancel;
		}
		public Menu? parent { get { return _parent; } }
		public unowned string title {
			get {
				if (_title != null)
					return _title;
				return name; 
			}
			set { _title = value; }
		}
		public uint item_count {
			get {
				ensure_items();
				return _items.size;
			}
		}
		public bool item_enabled(uint index) { 
			var item = item_at(index);
			if (item != null)
				return item.enabled;
			return false;
		}
		public MenuItem? item_at(uint index) {
			ensure_items();
			if (index >= _items.size)
				return null;
			return _items[(int)index];
		}
		public MenuItemField? field_at(uint index) {
			var item = item_at(index);
			return item as MenuItemField;			
		}
		public Enumerable<MenuItem> items() { 
			ensure_items();
			return new Enumerable<MenuItem>(_items);
		}
		public Enumerable<MenuItemField> fields() {
			return items().of_type<MenuItemField>();
		}

		public Layers.Layer? additional_menu_browser_layer { 
			get {
				if (_additional_menu_browser_layer == null)
					_additional_menu_browser_layer = build_additional_menu_browser_layer();
				return _additional_menu_browser_layer;
			}
		}
		Layers.Layer? _additional_menu_browser_layer;
		
		public void add_item(MenuItem item) {
			ensure_items();
			var field = item as MenuItemField;
			if (field != null) {
				ensure_field_hash();
				string field_id = field.id;
				_field_id_hash[field_id] = field;
				_field_index_hash[field_id] = _items.size;
				field.error.connect((error) => throw_field_error(field_id, error));
				field.error_cleared.connect(() => clear_error());
				field.message.connect((message) => this.message(message));
			}
			_items.add(item);
		}
		
		public T? get_field<T>(string id) {
			if (_field_id_hash == null || _field_id_hash.has_key(id) == false)
				return null;
			return (T)_field_id_hash[id];
		}
		
		public signal void message(string message);
		public signal void error(string error);
		public signal void field_error(MenuItemField field, int index, string error);
		public signal void clear_error();
		public signal void cancelled();
		public signal void saved();
		public signal void refreshed(uint selected_index);
		public signal void finished();
		
		public bool validate() {
			bool success = true;
			foreach(var field in fields()) {
				if (field.validate() == false)
					success = false;
			}
			if (success == true && do_validation() == false)
				return false;
			return success;
		}
		
		public bool cancel() {
			if (on_cancel != null) {
				if (on_cancel(this) == false)
					return false;
			}
			if (do_cancel() == false)
				return false;
						
			cancelled();
			finished();
			clear_items();
			return true;
		}
		public bool save() { 
			if (on_save != null) {
				if (on_save(this) == false)
					return false;
			}
			if (validate() == false)
				return false;
				
			if (do_save() == false)
				return false;
						
			saved();
			finished();
			clear_items();
			return true;
		}
		public void refresh(uint select_index) {
			if (do_refresh(select_index) == false)
				return;
			clear_items();
			ensure_items();
			refreshed(select_index);
		}
		
		public virtual uint initial_selection_index() { return 0; }
		public virtual string? initial_help() { return null; }
		
		protected virtual bool do_validation() { return true; }
		protected virtual bool do_cancel() { return true; }
		protected virtual bool do_save() { return true; }
		protected virtual bool do_refresh(uint select_index) { return true; }
		protected virtual void cleanup() { }
		
		protected void throw_field_error(string field_id, string error) {
			ensure_items();
			if (_field_index_hash != null && _field_index_hash.has_key(field_id)) {
				var field = _field_id_hash[field_id];
				field_error(field, _field_index_hash[field.id], error);
			}
		}

		protected virtual void populate_items(Gee.List<MenuItem> items) { }
		void clear_items() {
			if (_items == null)
				return;
			disconnect_all_item_handlers();
			cleanup();
			_field_id_hash = null;
			_field_index_hash = null;
			_items = null;
		}
		void ensure_items() {
			if (_items != null)
				return;
				
			_items = new ArrayList<MenuItem>();
			populate_items(_items);
			bool has_field = false;
			for(int index=0; index<_items.size; index++) {
				var item = _items[index];
				var field = item as MenuItemField;
				if (field == null)
					continue;
				if (has_field == false) {
					ensure_field_hash();
					has_field = true;
				}
				string field_id = field.id;
				_field_id_hash[field_id] = field;
				_field_index_hash[field_id] = index;
				field.error.connect((error) => throw_field_error(field_id, error));
				field.error_cleared.connect(() => clear_error());
				field.message.connect((message) => this.message(message));
			}
		}
		void ensure_field_hash() {
			if (_field_id_hash == null)
				_field_id_hash = new HashMap<string, MenuItemField>();
			if (_field_index_hash == null)
				_field_index_hash = new HashMap<string, int>();
		}
		
		protected virtual Layers.Layer? build_additional_menu_browser_layer() { return null; }
		
		public override bool is_menu_item() { return true; }

		protected void field_connect(MenuItemField field, owned SignalConnect<MenuItemField> connect) {
			_field_signal_handlers[field] = connect(field);	
		}
		protected void item_connect(MenuItem item, owned SignalConnect<MenuItem> connect) {
			_field_signal_handlers[item] = connect(item);	
		}
		protected void field_disconnect_handlers(MenuItemField field) {
			item_disconnect_handlers(field);
		}
		protected void item_disconnect_handlers(MenuItem item) {
			if (_field_signal_handlers.contains(item) == false)
				return;
			foreach(var handler in _field_signal_handlers[item])
				item.disconnect(handler);
			_field_signal_handlers.remove_all(item);
		}
		void disconnect_all_item_handlers() {
			foreach(var item in _field_signal_handlers.get_all_keys()) {
				foreach(var handler in _field_signal_handlers[item])
					item.disconnect(handler);
			}
			_field_signal_handlers.clear();
		}
		HashMultiMap<MenuItem, ulong> _field_signal_handlers = new HashMultiMap<MenuItem, ulong>();
	}
}
