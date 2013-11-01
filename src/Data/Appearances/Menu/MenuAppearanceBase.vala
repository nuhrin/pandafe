/* MenuAppearanceBase.vala
 * 
 * Copyright (C) 2013 nuhrin
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

using Menus;
using Menus.Fields;

namespace Data.Appearances.Menu
{
	public abstract class MenuAppearanceBase<G> : Catapult.YamlObject, MenuObject, AppearanceType<G>
	{
		// AppearanceType implementation
		public abstract G copy();
		public abstract void copy_from(G other);
		public virtual void set_name(string? name) { _name = name; }
		protected unowned string? __get_name() { return _name; }
		string? _name;
		protected unowned string default_font() { return AppearanceDefaults.MENU_FONT; }
		protected virtual unowned string default_font_preferred() { return AppearanceDefaults.MENU_FONT_PREFERRED; }
		protected virtual int default_font_size() { return AppearanceDefaults.MENU_FONT_SIZE; }
		protected int max_font_size() { return AppearanceDefaults.MENU_MAX_FONT_SIZE; }
		protected int min_font_size() { return AppearanceDefaults.MENU_MIN_FONT_SIZE; }
		protected unowned string default_background_color() { return AppearanceDefaults.MENU_BACKGROUND_COLOR; }		

		// menu
		protected abstract void appearance_changed();
		protected abstract void color_changed();
		protected abstract string get_appearance_description();
		protected abstract void build_menu(MenuBuilder builder);
		protected Gee.HashMultiMap<MenuItemField, ulong> get_field_handler_map()  {
			if (_field_handlers == null)
				_field_handlers = new Gee.HashMultiMap<MenuItemField, ulong>();
			return _field_handlers;
		}
		Gee.HashMultiMap<MenuItemField, ulong> _field_handlers;
		protected void release_fields(bool was_saved) {
			release_field_handlers();
			cleanup_fields();
		}
		protected abstract void cleanup_fields();
		protected void release_field_handlers() { release_field_handlers_implementation(); }
		protected bool suppress_default_actions() { return true; }
		protected bool apply_changed_field(Menus.Menu menu, MenuItemField field) { return true; }
	}
}
