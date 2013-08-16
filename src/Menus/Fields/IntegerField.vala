/* IntegerField.vala
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

namespace Menus.Fields
{
	public class IntegerField : MenuItemField
	{
		int _value;
		int min_value;
		int max_value;
		uint step;
		public IntegerField(string id, string name, string? help=null, int value, int min_value, int max_value, uint step=1) {
			base(id, name, help);
			if (max_value < min_value)
				GLib.error("max_value (%d) < max_value (%d)", max_value, min_value);

			_value = value;
			this.min_value = min_value;
			this.max_value = max_value;
			if (value < min_value)
				_value = min_value;
			else if (value > max_value)
				_value = max_value;
			if (_value != value)
				changed();
			this.step = step;
		}

		public new int value {
			get { return _value; }
			set { change_value(value); }
		}

		public override string get_value_text() { return _value.to_string(); }
		public override int get_minimum_menu_value_text_length() { return max_value.to_string().length + 1; }
		
		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((int)value); }
		protected override bool has_value() { return true; }

		protected override bool select_previous() {
			return change_value(_value - (int)step);
		}
		protected override bool select_next() {
			return change_value(_value + (int)step);
		}


		protected override void activate(MenuSelector selector) {
			var rect = selector.get_selected_item_value_entry_rect();
			if (rect != null) {
				int max_length = max_value.to_string().length;
				var min_value_length = min_value.to_string().length;
				if (min_value_length > max_length)
					max_length = min_value_length;
				if (max_length < 8)
					max_length = 8;
				int16 width = @interface.menu_ui.font_width((uint)max_length + 2);
				if (width > rect.w)
					width = (int16)rect.w;
				var entry = new IntegerEntry(id + "_entry", rect.x, rect.y, width, _value, min_value, max_value, step);
				entry.validation_error.connect(() => {
					this.error("%s must be an integer between %d and %d.".printf(name, min_value, max_value));
				});
				entry.error_cleared.connect(() => error_cleared());
				change_value(entry.run());
				selector.update_selected_item_value();
				selector.update();
			}
		}
		
		bool change_value(int new_value) {
			if (new_value < min_value)
				new_value = min_value;
			else if (new_value > max_value)
				new_value = max_value;

			if (new_value == _value)
				return false;

			_value = new_value;
			changed();
			return true;
		}
	}
}
