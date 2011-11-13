using Gee;
using Catapult;

namespace Menus
{
	public class Menu : MenuItem
	{
		Menu? _parent;
		public Menu(string name, string? help=null, Menu? parent=null) {
			base(name, help);
			items = new ArrayList<MenuItem>();
		}
		public Menu? parent { get { return _parent; } }
		public Gee.List<MenuItem> items { get; private set; }

		public void add_item(MenuItem item) {
			items.add(item);
		}


	}
}
