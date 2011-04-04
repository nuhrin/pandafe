using Gtk;

namespace yayafe.Gui.Fields
{
	public class StringField : LabeledField
	{
		public StringField(string name, string? label=null, string value="") {
			base(name, label);
			this.value = value;
		}
		public new string value
		{
			get { return entry.text; }
			set { entry.text = value; }
		}
		protected override Value get_field_value() { return entry.text; }
		protected override void set_field_value(Value value) { entry.text = (string)value; }

		protected override Widget target_widget { get { return entry; } }

		Entry entry {
			get {
				if (_entry == null) {
					_entry = new Entry();
					_entry.changed.connect(() => this.changed());
				}
				return _entry;
			}
		}
		Entry _entry;
	}
}