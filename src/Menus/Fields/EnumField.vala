/* EnumField.vala
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
using Layers.Controls;

namespace Menus.Fields
{
	public class EnumField : MenuItemField
	{
		EnumClass enum_class;
		Type value_type;
		int _value_index;
		ArrayList<string> _nicks;
		ArrayList<int> _values;
		int max_value_length;

		public EnumField(string id, string name, string? help=null, Value enum_value)
			requires(enum_value.type().is_enum())
		{
			base(id, name, help);
			enum_class = (EnumClass)enum_value.type().class_ref();
			value_type = enum_value.type();
			_nicks = new ArrayList<string>();
			_values = new ArrayList<int>();
			int index=0;
			max_value_length=0;
			int value = enum_value.get_enum();
			foreach(var ev in enum_class.values) {
				int nick_length = ev.value_nick.length;
				if (nick_length > max_value_length)
					max_value_length = nick_length;
				_nicks.add(ev.value_nick);
				_values.add(ev.value);
				if (value == ev.value)
					_value_index = index;
				index++;
			}
		}

		public new int value {
			get { return _values[_value_index]; }
			set {
				int new_index=0;
				int index=0;
				foreach(var ev in enum_class.values) {
					if (value == ev.value) {
						new_index = index;
						break;
					}
					index++;
				}
				if (new_index != _value_index) {
					_value_index = new_index;
					changed();
				}
			}
		}

		public override string get_value_text() { return _nicks[_value_index]; }
		public override int get_minimum_menu_value_text_length() { return max_value_length; }

		protected override Value get_field_value() { return this.value; }
		protected override void set_field_value(Value value) { this.value = value.get_enum(); }
		protected override bool has_value() { return true; }

		protected override void activate(MenuSelector selector) {
			var rect = selector.get_selected_item_value_entry_rect();
			if (rect != null) {
				var items = new ArrayList<int>();
				for(int index=0;index<_nicks.size;index++)
					items.add(index);
				if (items.size < 2)
					return;
				var control = new ValueSelector<int>(id + "_selector", rect.x, rect.y, (int16)rect.w, index=> _nicks[index], items, _value_index);
				int new_index = (int)control.run();
				if (new_index != _value_index) {
					_value_index = new_index;
					changed();
				}
				selector.update_selected_item_value();
				selector.update();
			}
		}

		protected override bool select_previous() {
			if (_value_index < 1)
				return false;

			_value_index--;
			changed();
			return true;
		}
		protected override bool select_next() {
			if (_value_index >= _values.size - 1)
				return false;

			_value_index++;
			changed();
			return true;
		}

	}
}
