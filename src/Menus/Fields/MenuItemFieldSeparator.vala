/* MenuItemFieldSeparator.vala
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

using SDL;

namespace Menus.Fields
{
	public class MenuItemFieldSeparator : MenuItemField
	{
		public MenuItemFieldSeparator() {
			base("", "");
		}
		
		public override string get_value_text() { return ""; }
		public override int get_minimum_menu_value_text_length() { return 0; }
		
		public override bool handles_keydown_event(KeyboardEvent event) { return false; }
		public override bool process_keydown_event(KeyboardEvent event) { return false; }
		
		public override void activate(MenuSelector selector) { }
		
		protected override Value get_field_value() { return ""; }
		protected override void set_field_value(Value value) { }
		protected override bool has_value() { return false; }		
		
		protected override bool is_initially_enabled() { return false; }
		protected override bool can_change_enabled_state() { return false; }
		
	}
}
