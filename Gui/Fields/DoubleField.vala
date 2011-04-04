using Gtk;

namespace yayafe.Gui.Fields
{
	public class DoubleField : LabeledField
	{
		public DoubleField(string name, string? label=null, double value=0, double min=double.MIN, double max=double.MAX, uint digits=2) {
			base(name, label);
			this.value = value;
			this.min_value = min;
			this.max_value = max;
			this.digits=2;
		}
		public new double value
		{
			get { return spin.get_value_as_int(); }
			set { spin.value = value; }
		}

		public double min_value
		{
			get { return (int)spin.adjustment.lower; }
			set { spin.adjustment.lower = value; if (value > this.value) this.value = value; }
		}
		public double max_value
		{
			get { return (int)spin.adjustment.upper; }
			set { spin.adjustment.upper = value; if (value < this.value) this.value = value; }
		}
		public uint digits
		{
			get { return spin.digits; }
			set { spin.digits = value; }
		}
		public double step_increment
		{
			get { return spin.adjustment.step_increment; }
			set { spin.adjustment.step_increment = value; }
		}

		protected override Value get_field_value() { return this.value; }
		protected override void set_field_value(Value value) { this.value = (double)value; }

		protected override Widget target_widget { get { return spin_button; } }

		SpinButton spin_button {
			get {
				if (spin == null) {
					spin = new SpinButton.with_range(double.MIN, double.MAX, 1);
					spin.value = 0;
					spin.value_changed.connect(() => this.changed());
				}
				return spin;
			}
		}
		SpinButton spin;
	}
}