using Gee;

namespace Menus.Fields
{
	public class EnumField : MenuItemField
	{
		EnumClass enum_class;
		Type value_type;
		int _value_index;
		ArrayList<string> _nicks;
		ArrayList<int> _values;

		public EnumField(string id, string name, string? help=null, Value enum_value)
			requires(enum_value.type().is_enum())
		{
			base(id, name, help);
			enum_class = (EnumClass)enum_value.type().class_ref();
			value_type = enum_value.type();
			_nicks = new ArrayList<string>();
			_values = new ArrayList<int>();
			int index=0;
			int value = enum_value.get_enum();
			foreach(var ev in enum_class.values) {
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

		protected override Value get_field_value() { return this.value; }
		protected override void set_field_value(Value value) { this.value = value.get_enum(); }


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
