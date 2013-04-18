/* ObjectMenu.vala
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
	public class ObjectMenu : Menu
	{		
		Object obj;
		MenuObject mo;

		public static bool edit(string title, Object obj) {
			var menu = new ObjectMenu(title, null, obj);
			new MenuBrowser(menu).run();			
			return menu.was_saved;
		}
		public static MenuBrowserItem get_browser_item(string name, string? title, string? help, Object obj) {
			var menu = new ObjectMenu(title ?? name, null, obj);
			return new MenuBrowserItem(name, help, menu);
		}
		
		ObjectMenu(string name, string? help=null, Object obj) {
			base(name, help);
			this.obj = obj;
			mo = this.obj as MenuObject;			
		}
		public bool was_saved { get; private set; }
				
		protected override bool do_validation() {
			if (mo != null)
				return mo.i_validate_menu(this);
			return true;
		}		
		protected override bool do_cancel() {
			// revert...
			was_saved = false;
			return true;
		}
		protected override bool do_save() {
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
	
		protected override void cleanup() {
			if (mo != null)
				mo.i_release_fields();
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
