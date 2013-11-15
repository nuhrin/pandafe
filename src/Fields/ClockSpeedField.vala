/* ClockSpeedField.vala
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

using Layers.Controls;
using Menus.Fields;

namespace Fields
{
	public class ClockSpeedField : UIntField
	{
		const uint DEFAULT_VALUE = 600;
		const uint MIN_VALUE = 150;
		const string DEFAULT_VALUE_TEXT = "default";
		const string DEFAULT_CHOICE_TEXT = "default";
		const string CUSTOM_CHOICE_TEXT = "custom";
		
		bool is_default;
		uint _default_value;
		int max_value_length;
		public ClockSpeedField(string id, string name, string? help=null, uint value, uint step=5) {
			var max_value = Data.preferences().maximum_clockspeed;
			base(id, name, help, (value == 0) ? DEFAULT_VALUE : value, MIN_VALUE, max_value, step);
			is_default = (value == 0);
			_default_value = DEFAULT_VALUE;
			max_value_length = max_value.to_string().length;
			if (DEFAULT_VALUE_TEXT.length > max_value_length)
				max_value_length = DEFAULT_VALUE_TEXT.length;
		}

		public new uint value {
			get { return (is_default) ? 0 : base._value; }
			set { 
				if (value == 0) {
					if (is_default == false) {
						is_default = true;
						changed();
					}
				} else {
					is_default = false;
					base.value = value;
				}
			}
		}
		
		public uint default_value { 
			get { return _default_value; }
			set {
				uint new_default = (value == 0) ? DEFAULT_VALUE : value;
				if (is_default == true)
					base._value = new_default;
				_default_value = new_default;
			}
		}

		public override string get_value_text() { return (is_default) ? DEFAULT_VALUE_TEXT : base.get_value_text(); }
		public override int get_minimum_menu_value_text_length() { return max_value_length; }

		protected override Value get_field_value() { return this.value; }
		protected override void set_field_value(Value value) { this.value = (uint)value; }

		protected override bool select_previous() {
			if (is_default == false) {
				is_default = true;
				changed();
				return true;
			}
			return false;
		}
		protected override bool select_next() {
			if (is_default == true) {
				is_default = false;
				changed();
				return true;
			}
			return false;
		}


		protected override void activate(Menus.MenuSelector selector) {
			var rect = selector.get_selected_item_value_entry_rect();
 			var choice_selector = new StringSelector("clockspeed_choice", rect.x, rect.y, 200);			
 			choice_selector.add_item(DEFAULT_CHOICE_TEXT);
			choice_selector.add_item(CUSTOM_CHOICE_TEXT);
			if (is_default == false)
				choice_selector.selected_index = 1;
 			if (choice_selector.run() == 0) {
 				if (select_previous() == true) {
					selector.update_selected_item_value();
					selector.update();
				}
 				return;
 			}			
			
 			uint before = base._value;
			bool before_default = is_default;
			is_default = false;
			base.activate(selector);
			if (base._value == before && before_default == true)
				is_default = true;
		}		
	}
}
