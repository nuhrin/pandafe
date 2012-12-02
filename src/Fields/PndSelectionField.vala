/* PndSelectionField.vala
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
using Data.Pnd;
using Layers.Controls;
using Menus.Fields;

namespace Fields
{
	public class PndSelectionField : MenuItemField
	{
		int _selected_index;
		ArrayList<string> items;
		PndData data;
		
		public PndSelectionField(string id, string name, string? help=null, PndData data, string? pnd_id) {
			base(id, name, help);
			this.data = data;
			populate_items(pnd_id);
		}

		public new string value {
			owned get { return (_selected_index > 0) ? items[_selected_index] : ""; }
			set { change_value(value); }
		}
		public PndItem? get_selected_pnd() {
			return data.get_pnd(value);
		}

		void populate_items(string? selected_id) {
			_selected_index = 0;
			items = new ArrayList<string>();
			items.add("None");
			int index=1;
			foreach(var pnd in data.get_all_pnds()) {
				items.add(pnd.pnd_id);				
				if (selected_id != null && _selected_index == 0 && pnd.pnd_id == selected_id) {
					_selected_index = index;
				}
				index++;
			}
			foreach(string item in items) {
				if (item == value && _selected_index == 0)
					_selected_index = index;
				this.items.add(item);
				index++;				
			}			
		}

		public override string get_value_text() { return this.value; }
		public override int get_minimum_menu_value_text_length() { return -1; }

		protected override bool select_previous() { 
			if (_selected_index < 0)
				return change_value_index(0);				
			
			if (_selected_index == 0)
				return false;
			return change_value_index(_selected_index - 1);
		}
		protected override bool select_next() { 
			if (_selected_index < 0)
				return change_value_index(0);
			if (_selected_index >= items.size - 1)
				return false;
				
			return change_value_index(_selected_index + 1);
		}

		protected override Value get_field_value() { return this.value; }
		protected override void set_field_value(Value value) { change_value((string)value); }
		protected override bool has_value() { return (_selected_index > 0); }

		protected override void activate(Menus.MenuSelector selector) {
			var rect = selector.get_selected_item_value_entry_rect();
			if (rect != null) {
				var control = new StringSelector(id + "_selector", rect.x, rect.y, (int16)rect.w, items, _selected_index);
				change_value_index((int)control.run());
				selector.update_selected_item_value();
				selector.update();
			}
		}
		
		bool change_value_index(int new_index) {
			if (_selected_index == new_index)
				return false;
			_selected_index = new_index;
			changed();
			return true;
		}
		bool change_value(string new_value) {
			for(int index=0;index<items.size;index++) {
				if (items[index] == new_value)
					return change_value_index(index);					
			}
			
			return false;
		}
	}
}
