/* BooleanField.vala
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
	public class BooleanField : MenuItemField
	{
		bool _value;
		string true_value;
		string false_value;
		public BooleanField(string id, string name, string? help=null, bool value=false, string true_value="true", string false_value="false") {
			base(id, name, help);
			_value = value;
			this.true_value = true_value;
			this.false_value = false_value;
		}

		public new bool value {
			get { return _value; }
			set { change_value(value); }
		}

		public override string get_value_text() { return (_value == true) ? true_value : false_value; }
		public override int get_minimum_menu_value_text_length() { return 5; } // "false""
		
		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((bool)value); }
		protected override bool has_value() { return true; }

		protected override void activate(MenuSelector selector) {
			var rect = selector.get_selected_item_value_entry_rect();
			if (rect != null) {
				var items = new ArrayList<bool>();
				items.add(true);
				items.add(false);				
				var control = new ValueSelector<bool>(id + "_selector", rect.x, rect.y, (int16)rect.w, val=> (val) ? true_value : false_value, items, (_value) ? 0 : 1);
				change_value(control.run() == 0);
				selector.update_selected_item_value();
				selector.update();
			}
		}

		void change_value(bool new_value) {
			if (new_value == _value)
				return;
			_value = new_value;
			changed();
		}

		protected override bool select_previous() {
			change_value(!_value);
			return true;
		}
		protected override bool select_next() {
			change_value(!_value);
			return true;
		}

	}
}
