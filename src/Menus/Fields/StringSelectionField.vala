using Gee;
using Layers.Controls;

namespace Menus.Fields
{
	public class StringSelectionField : MenuItemField
	{
		int _selected_index;
		ArrayList<string> items;
		
		public StringSelectionField(string id, string name, string? help=null, Iterable<string>? items=null, string? value=null) {
			base(id, name, help);

			_selected_index = -1;
			this.items = new ArrayList<string>();
			if (items != null) {
				int index=0;
				foreach(string item in items) {
					if (item == value && _selected_index == -1)
						_selected_index = index;
					this.items.add(item);
					index++;
				}
			}
		}

		public new string value {
			owned get { return (_selected_index != -1) ? items[_selected_index] : ""; }
			set { change_value(value); }
		}

		public void add_item(string item) {
			items.add(item);
		}
		public void set_items(Iterable<string> items) {
			this.items.clear();
			foreach(string item in items)
				add_item(item);			
		}
		public void set_items_array(string[] items) {
			this.items.clear();
			foreach(string item in items)
				add_item(item);
		}

		public override string get_value_text() { return this.value; }

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

		protected override void activate(MenuSelector selector) {
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
