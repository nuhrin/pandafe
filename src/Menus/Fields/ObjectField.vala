/* ObjectField.vala
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
using SDL;
using Catapult;
using Layers.Controls;
using Layers.MenuBrowser;

namespace Menus.Fields
{
	public class ObjectField : MenuItemField
	{
		Object obj;
		Type type;
		
		public ObjectField(string id, string name, string? help=null, Object obj) {
			base(id, name, help);
			this.obj = obj;
			type = obj.get_type();
		}

		public new Object value {
			get { return obj; }
			set { change_value(value); }
		}
		

		public override string get_value_text() { return "..."; }
		public override int get_minimum_menu_value_text_length() { return 3; }
		
		protected override Value get_field_value() { return obj; }
		protected override void set_field_value(Value value) { change_value(value.get_object()); }
		protected override bool has_value() { return true; }

		protected override void activate(MenuSelector selector) {
			ObjectMenu.edit(name, obj);			
		}

		void change_value(Object obj) {
			if (obj != this.obj) {
				this.obj = obj;
				changed();
			}
		}
		
	}
}
