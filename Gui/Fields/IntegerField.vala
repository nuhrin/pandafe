using Gtk;

namespace yayafe.Gui.Fields
{
	public class IntegerField : LabeledField
	{
		public IntegerField(string name, string? label=null, int value=0, int min=int.MIN, int max=int.MAX) {
			base(name, label);
			this.value = value;
			this.min_value = min;
			this.max_value = max;
		}
		public new int value
		{
			get { return spin.get_value_as_int(); }
			set { spin.value = value; }
		}

		public int min_value
		{
			get { return (int)spin.adjustment.lower; }
			set { spin.adjustment.lower = value; if (value > this.value) this.value = value; }
		}
		public int max_value
		{
			get { return (int)spin.adjustment.upper; }
			set { spin.adjustment.upper = value; if (value < this.value) this.value = value; }
		}

		protected override Value get_field_value() { return this.value; }
		protected override void set_field_value(Value value) { this.value = (int)value; }

		protected override Widget target_widget { get { return spin_button; } }

		SpinButton spin_button {
			get {
				if (spin == null) {
					spin = new SpinButton.with_range(int.MIN, int.MAX, 1);
					spin.value = 0;
					spin.value_changed.connect(() => this.changed());
				}
				return spin;
			}
		}
		SpinButton spin;
	}
}