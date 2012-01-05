using Gee;
using Catapult;

using Menus.Fields;

namespace Menus
{
	public class ObjectMenu : Menu
	{
		Object obj;
		MenuObject mo;
		public ObjectMenu(string name, string? help=null, Object obj) {
			base(name, help);
			this.obj = obj;
			mo = obj as MenuObject;
		}
		public override bool cancel() {
			// revert...?
			return true;
		}
		public override bool save() {
			// validate...
			if (mo != null)
				return mo.i_apply_menu(this);
			return true;
		}
	
		protected override void populate_items(Gee.List<MenuItem> items) { 
			var builder = new MenuBuilder();
			if (mo != null) {
				mo.i_build_menu(builder);
			} else {
				builder.add_object_properties(obj);
			}
			foreach(var item in builder.items) {
				items.add(item);
			}
			items.add(new MenuItem.cancel_item());
			items.add(new MenuItem.save_item());
		}
	}
}
