using Layers.Controls;
using Menus.Fields;

namespace Fields
{
	public class ClockSpeedField : UIntField
	{
		const uint DEFAULT_VALUE = 600;
		const string DEFAULT_VALUE_TEXT = "default";		
		
		bool is_default;
		uint _default_value;
		public ClockSpeedField(string id, string name, string? help=null, uint value, uint min_value, uint max_value, uint step=1) {
			base(id, name, help, (value == 0) ? DEFAULT_VALUE : value, min_value, max_value, step);
			is_default = (value == 0);
			_default_value = DEFAULT_VALUE;
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
 			choice_selector.add_item("Default");
			choice_selector.add_item("Custom...");
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
