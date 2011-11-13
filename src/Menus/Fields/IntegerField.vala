
namespace Menus.Fields
{
	public class IntegerField : MenuItemField
	{
		int _value;
		int min_value;
		int max_value;
		int step;
		public IntegerField(string id, string name, string? help=null, int value, int min_value, int max_value, int step=1) {
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

		void change_value(int new_value) {
			if (new_value < min_value)
				new_value = min_value;
			else if (new_value > max_value)
				new_value = max_value;

			if (new_value == _value)
				return;

			_value = new_value;
			changed();
		}

		protected override bool select_previous() {
			if (_value == min_value)
				return false;

			_value--;
			changed();
			return true;
		}
		protected override bool select_next() {
			if (_value == max_value)
				return false;

			_value++;
			changed();
			return true;
		}


	}
}
