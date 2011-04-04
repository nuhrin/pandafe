using Gtk;

namespace yayafe.Gui.Fields
{
	public class BooleanField : LabeledField
	{
		public BooleanField(string name, string? label=null, bool checked=false) {
			base(name, label);
			value = checked;
		}

		public override string label
		{
			get { return check_button.label; }
			set { check_button.label = value; }
		}

		public new bool value
		{
			get { return check_button.active; }
			set { check_button.active = value; }
		}

		protected override Value get_field_value() { return check_button.active; }
		protected override void set_field_value(Value value) { check_button.active = (bool)value; }

		protected override Widget target_widget { get { return check_button; } }
		protected override Widget build_widget() { return check_button; }

		CheckButton check_button {
			get {
				if (chk == null) {
					chk = new CheckButton.with_mnemonic("");
					chk.toggled.connect(() => this.changed());
				}
				return chk;
			}
		}
		CheckButton chk;
	}
}
