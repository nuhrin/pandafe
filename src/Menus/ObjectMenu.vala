using Gee;
using Catapult;

using Menus.Fields;

namespace Menus
{
	public class ObjectMenu : Menu
	{		
		Object obj;
		MenuObject mo;
		
		public static bool edit(string title, Object obj) {
			var menu = new ObjectMenu(title, null, obj);
			new MenuBrowser(menu, 40, 40).run();
			if (menu.mo != null)
				menu.mo.i_release_fields();
			return menu.was_saved;
		}
		
		ObjectMenu(string name, string? help=null, Object obj) {
			base(name, help);
			this.obj = obj;
			mo = this.obj as MenuObject;
		}
		~ObjectMenu() {
			if (mo != null)
				mo.i_release_fields();
		}
		public bool was_saved { get; private set; }
		
		public override bool do_validation() {
			if (mo != null)
				return mo.i_validate_menu(this);
			return true;
		}		
		public override bool do_cancel() {
			// revert...
			was_saved = false;
			return true;
		}
		public override bool do_save() {
			if (mo != null) {
				if (mo.i_apply_menu(this) == true) {
					if (mo.i_save_object(this) == true) {
						was_saved = true;
						return true;
					}
				}
				return false;
			}
				
			foreach(var field in fields()) {
				if (field.has_changes())
					obj.set_property(field.id, field.value);
			}
			was_saved = true;
			return true;
		}
	
		protected override void populate_items(Gee.List<MenuItem> items) { 
			var builder = new MenuBuilder();
			if (mo != null) {
				mo.i_build_menu(builder);
			} else {
				builder.add_object_properties(obj);
			}
			foreach(var field in builder.fields()) {
				items.add(field);
			}
			if (builder.has_action) {
				foreach(var action in builder.actions())
					items.add(action);
			} else {
				items.add(new MenuItem.cancel_item());
				items.add(new MenuItem.save_item());
			}
		}
//~ 		void copy_object_properties(Object from, Object to) {
//~ 			unowned ObjectClass klass = from.get_class();
//~ 	    	var properties = klass.list_properties();
//~ 	    	foreach(var prop in properties) {
//~ 				if (((prop.flags & ParamFlags.READWRITE) == ParamFlags.READWRITE) == false)
//~ 					continue;
//~ 				Type type = prop.value_type;
//~ 				Value value = Value(type);
//~ 				from.get_property(prop.name, ref value);
//~ 				to.set_property(prop.name, value);
//~ 			}
//~ 		}
	}
}
