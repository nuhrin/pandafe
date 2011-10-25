
namespace Menus.Fields
{
	public class BooleanField : MenuItemField
	{
		bool _value;
		string true_value;
		string false_value;
		public BooleanField(string id, string name, bool value=false, string true_value="true", string false_value="false") {
			base(id, name);
			_value = value;
			this.true_value = true_value;
			this.false_value = false_value;
		}

		public new bool value {
			get { return _value; }
			set { _value = value; }
		}

		public override string get_value_text() { return (_value == true) ? true_value : false_value; }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { _value = (bool)value; }


		protected override bool select_previous() {
			if (_value == false)
				return false;

			_value = false;
			return true;
		}
		protected override bool select_next() {
			if (_value == true)
				return false;

			_value = true;
			return true;
		}

	}
}
