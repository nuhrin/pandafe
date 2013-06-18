/* MenuObject.vala
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

using Menus.Fields;

namespace Menus
{
	public interface MenuObject : Object
	{
		protected virtual void build_menu(MenuBuilder builder) {
			builder.add_object_properties(this);
		}
		internal void i_build_menu(MenuBuilder builder) { build_menu(builder); }
		protected bool apply_menu(Menu menu) {
			var fields = menu.fields();
			foreach(var field in fields) {
				if (field.has_changes()) {
					if (apply_changed_field(menu, field) == false)
						this.set_property(field.id, field.value);
				}
			}
			return true;
		}
		internal bool i_apply_menu(Menu menu) { return apply_menu(menu); }
		protected virtual bool apply_changed_field(Menu menu, MenuItemField field) {
			return false;
		}
		internal bool i_validate_menu(Menu menu) { return validate_menu(menu); }
		protected virtual bool validate_menu(Menu menu) { return true; }
		
		protected virtual bool save_object(Menu menu) { return true; }
		internal bool i_save_object(Menu menu) { return save_object(menu); }
		
		protected virtual void release_fields(bool was_saved) { }
		internal void i_release_fields(bool was_saved) { release_fields(was_saved); }
		
		public virtual signal void refreshed(uint select_index) { }
	}
}
