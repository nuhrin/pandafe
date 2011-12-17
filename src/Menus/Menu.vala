using Gee;
using Catapult;

namespace Menus
{
	public class Menu : MenuItem
	{
		Menu? _parent;
		Predicate<Menu>? on_save;
		Predicate<Menu>? on_cancel; 
		public Menu(string name, string? help=null, Menu? parent=null, owned Predicate? on_save=null, owned Predicate<Menu>? on_cancel=null ) {
			base(name, help);
			this.on_save = (owned)on_save;
			this.on_cancel = (owned)on_cancel;
			items = new ArrayList<MenuItem>();
		}
		public Menu? parent { get { return _parent; } }
		public Gee.List<MenuItem> items { get; private set; }

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


	}
}
