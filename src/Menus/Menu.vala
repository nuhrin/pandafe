using Gee;
using Catapult;

namespace Menus
{
	public class Menu : MenuItem
	{
		Menu? _parent;
		ArrayList<MenuItem> _items;
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

		public void add_item(MenuItem item) {
			items.add(item);
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
		}

	}
}
