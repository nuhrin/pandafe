using Gee;
using Catapult;

using Menus.Fields;

namespace Menus
{
	public class Menu : MenuItem
	{
		string? _title;
		Menu? _parent;
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
		public Gee.List<MenuItem> items { 
			owned get {
				ensure_items();
				return _items.read_only_view;
			}
		}
		public Enumerable<MenuItemField> fields() {
			return new Enumerable<MenuItem>(items).of_type<MenuItemField>();
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
				_field_id_hash[field.id] = field;
				_field_index_hash[field.id] = _items.size;				
				field.error.connect((error) => throw_field_error(field, error));
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
			return true;
		}
		public void refresh(uint select_index) {
			do_refresh(select_index);
			refreshed(select_index);
		}
		
		protected virtual bool do_validation() { return true; }
		protected virtual bool do_cancel() { return true; }
		protected virtual bool do_save() { return true; }
		protected virtual void do_refresh(uint select_index) {  }

		protected void throw_field_error(MenuItemField field, string error) {
			ensure_items();
			if (_field_index_hash != null && _field_index_hash.has_key(field.id))
				field_error(field, _field_index_hash[field.id], error);			
		}

		protected virtual void populate_items(Gee.List<MenuItem> items) { }
		protected void clear_items() {
			if (_items != null)
				_items = null;
		}
		protected void ensure_items() {
			if (_items != null)
				return;
				
			_items = new ArrayList<MenuItem>();
			populate_items(_items);
			bool has_field = false;
			for(int index=0; index<_items.size; index++) {
				var field = _items[index] as MenuItemField;
				if (field == null)
					continue;
				if (has_field == false) {
					ensure_field_hash();
					has_field = true;
				}
				_field_id_hash[field.id] = field;
				_field_index_hash[field.id] = index;
				field.error.connect((error) => throw_field_error(field, error));
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
	}
}
