using Gee;
using Catapult;

using Menus.Fields;

namespace Menus
{
	public class Menu : MenuItem
	{
		Menu? _parent;
		ArrayList<MenuItem> _items;
		HashMap<string, MenuItemField> _field_id_hash;
		Predicate<Menu>? on_save;
		Predicate<Menu>? on_cancel; 
		public Menu(string name, string? help=null, Menu? parent=null, owned Predicate? on_save=null, owned Predicate<Menu>? on_cancel=null ) {
			base(name, help);
			this.on_save = (owned)on_save;
			this.on_cancel = (owned)on_cancel;
		}
		public Menu? parent { get { return _parent; } }
		public Gee.List<MenuItem> items { 
			get {
				ensure_items();
				return _items;
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
			items.add(item);
			var field = item as MenuItemField;
			if (field != null) {
				ensure_field_hash();
				_field_id_hash[field.id] = field;
			}
		}
		
		public T? get_field<T>(string id) {
			if (_field_id_hash == null || _field_id_hash.has_key(id) == false)
				return null;
			return (T)_field_id_hash[id];
		}
		
		public virtual bool cancel() {
			debug("Menu '%s': cancel", name);
			if (on_cancel != null)
				return on_cancel(this);
			return true;
		}
		public virtual bool save() { 
			debug("Menu '%s': save", name);
			if (on_save != null)
				return on_save(this);
			return true;
		}


		protected virtual void populate_items(Gee.List<MenuItem> items) { }
		protected void ensure_items() {
			if (_items != null)
				return;
				
			_items = new ArrayList<MenuItem>();
			populate_items(_items);
			foreach(var field in fields()) {
				ensure_field_hash();
				_field_id_hash[field.id] = field;
			}
		}
		void ensure_field_hash() {
			if (_field_id_hash == null)
				_field_id_hash = new HashMap<string, MenuItemField>();
		}
		
		protected virtual Layers.Layer? build_additional_menu_browser_layer() { return null; }

	}
}
