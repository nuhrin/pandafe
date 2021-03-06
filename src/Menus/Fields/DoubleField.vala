/* DoubleField.vala
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
	public class DoubleField : MenuItemField
	{
		double _value;
		double min_value;
		double max_value;
		double step;
		uint precision;

		public DoubleField(string id, string name, string? help=null, double value, double min_value, double max_value, double step=0.1, uint precision=1) {
			base(id, name, help);
			if (max_value < min_value)
				GLib.error("max_value (%f) < max_value (%f)", max_value, min_value);

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
			this.precision = precision;
		}

		public new double value {
			get { return _value; }
			set { change_value(value); }
		}

		public signal void text_value_changed(double text_value);

		public override string get_value_text() { return get_value_string(_value); }
		public override int get_minimum_menu_value_text_length() { return get_value_string(max_value).length + 1; }
		
		protected string get_value_string(double value) {
			return "%%.%uf".printf(precision).printf(value);
		}
		
		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((double)value); }
		protected override bool has_value() { return true; }

		protected override bool select_previous() {
			return change_value(_value - step);
		}
		protected override bool select_next() {
			return change_value(_value + step);
		}


		protected override void activate(MenuSelector selector) {
			var rect = selector.get_selected_item_value_entry_rect();
			if (rect != null) {
				int max_length = get_value_string(max_value).length;
				var min_value_length = get_value_string(min_value).length;
				if (min_value_length > max_length)
					max_length = min_value_length;
				if (max_length < 8)
					max_length = 8;
				int16 width = @interface.menu_ui.controls.font_width((uint)max_length + 2);
				if (width > rect.w)
					width = (int16)rect.w;
				var entry = new DoubleEntry(id + "_entry", rect.x, rect.y, width, _value, min_value, max_value, step, precision);
				entry.validation_error.connect(() => {
					this.error("%s must be an double between %%.%uf and %%.%uf.".printf(name, precision, precision).printf(min_value, max_value));
				});
				entry.error_cleared.connect(() => error_cleared());
				entry.text_value_changed.connect((v) => text_value_changed(v));
				change_value(entry.run());
				selector.update_selected_item_value();
				selector.update();
			}
		}
		
		bool change_value(double new_value) {
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
