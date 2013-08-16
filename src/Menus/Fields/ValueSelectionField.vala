/* ValueSelectionField.vala
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


using Gee;
using Layers.Controls;

namespace Menus.Fields
{
	public class ValueSelectionField<G> : MenuItemField
	{
		protected int _selected_index;
		protected ArrayList<G> items;
		MapFunc<string, G> getItemName;
		MapFunc<Value?, G> getItemValue;
		int max_value_length;
		
		public ValueSelectionField(string id, string name, string? help=null, owned MapFunc<string, G> getItemName, owned MapFunc<Value?, G> getItemValue,
								   Iterable<G>? items=null, G? value=null) {
			base(id, name, help);
			this.getItemName = (owned)getItemName;
			this.getItemValue = (owned)getItemValue;
			_selected_index = -1;
			this.items = new ArrayList<G>();
			max_value_length = 0;
			if (items != null) {
				int index=0;
				foreach(var item in items) {
					var item_name = getItemName(item);
					if (item_name.length > max_value_length)
						max_value_length = item_name.length;
					if (_selected_index == -1 && item == value)
						_selected_index = index;
					this.items.add(item);
					index++;
				}
			}
		}

		public new G value {
			owned get { return (_selected_index != -1) ? items[_selected_index] : null; }
		}

		public void add_item(G item) {
			items.add(item);
		}
		public void set_items(Iterable<G> items) {
			var selected_value = value;
			_selected_index = -1;
			this.items.clear();
			int index=0;
			max_value_length = 0;
			foreach(var item in items) {
				var name = getItemName(item);
				if (name.length > max_value_length)
					max_value_length = name.length;
				if (_selected_index == -1 && item == selected_value)
					_selected_index = index;
				add_item(item);
				index++;
			}
			changed();
		}
		public void set_items_array(G[] items) {
			var selected_value = value;
			_selected_index = -1;
			this.items.clear();
			int index=0;
			max_value_length = 0;
			foreach(var item in items) {
				var name = getItemName(item);
				if (name.length > max_value_length)
					max_value_length = name.length;
				if (_selected_index == -1 && item == selected_value)
					_selected_index = index;
				add_item(item);
				index++;
			}
			changed();
		}		

		public override string get_value_text() { return (value != null) ? getItemName(value) : ""; }
		public override int get_minimum_menu_value_text_length() { return max_value_length; }

		protected override bool select_previous() { 
			if (items.size == 0)
				return false;
			if (_selected_index < 0)
				return change_value_index(0);				
			
			if (_selected_index == 0)
				return false;
			return change_value_index(_selected_index - 1);
		}
		protected override bool select_next() { 
			if (items.size == 0)
				return false;
			if (_selected_index < 0)
				return change_value_index(0);
			if (_selected_index >= items.size - 1)
				return false;
				
			return change_value_index(_selected_index + 1);
		}
		
		protected override Value get_field_value() { return getItemValue(this.value); }
		protected override void set_field_value(Value value) { }
		protected override bool has_value() { return (_selected_index >= 0); }
		
		protected override bool do_validation() {
			if (_selected_index == -1 && items.size > 0) {
				error("%s not selected.".printf(name));
				return false;
			}
			
			return true;
		}

		protected override void activate(MenuSelector selector) {
			if (items.size == 0)
				return;
			if (items.size == 1) {
				if (has_value() == false && select_next() == true) {
					selector.update_selected_item_value();
					selector.update();					
				}
				return;
			}
			var rect = selector.get_selected_item_value_entry_rect();
			if (rect != null) {
				var control = new ValueSelector<G>(id + "_selector", rect.x, rect.y, (int16)rect.w, (owned)getItemName, items, _selected_index);
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
	}
}
