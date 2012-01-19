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

			this.min_value = min_value;
			this.max_value = max_value;
			if (value < min_value)
				_value = min_value;
			else if (value > max_value)
				_value = max_value;
			else
				_value = value;
			this.step = step;
		}

		public new int value {
			get { return _value; }
			set { change_value(value); }
		}

		public override string get_value_text() { return _value.to_string(); }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((int)value); }

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
				int16 width = @interface.get_monospaced_font_width((uint)max_length + 2);
				if (width > rect.w)
					width = (int16)rect.w;
				var entry = new IntegerEntry(id + "_entry", rect.x, rect.y, width, _value, min_value, max_value, step);
				entry.validation_error.connect(() => {
					this.error("%s must be an integer between %d and %d (%d).".printf(name, min_value, max_value, entry.value));
				});
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
