
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

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((bool)value); }

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
