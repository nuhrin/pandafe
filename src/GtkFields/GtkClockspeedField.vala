using Gtk;
using Gee;
using Catapult.Gui.Fields;
using Data.Pnd;

namespace GtkFields
{
	public class GtkClockspeedField : CompositeField
	{
		const uint CLOCKSPEED_DEFAULT = 600;
		const uint CLOCKSPEED_MIN = 150;
		const uint CLOCKSPEED_MAX = 1000;

		BooleanField flag_field;
		UIntField value_field;
		public GtkClockspeedField(string id, string label, uint clockspeed=0) {
			base(id);

			flag_field = box.add_bool(id +"_flag", label);
			value_field = box.add_uint(id+"_value", null, clockspeed, CLOCKSPEED_MIN, CLOCKSPEED_MAX);
			box.set_field_packing(value_field, true, true, 0, Gtk.PackType.START);
			set_value_field(value_field);

			if (clockspeed == 0) {
				value_field.value = CLOCKSPEED_DEFAULT;
				value_field.sensitive = false;
			} else {
				enabled = true;
			}
			flag_field.changed.connect(() => {
				if (enabled == true) {
					value_field.sensitive = true;
				} else {
					value_field.sensitive = false;
					value_field.value = CLOCKSPEED_DEFAULT;
				}
			});
		}

		public bool enabled {
			get { return flag_field.value; }
			set { flag_field.value = value; }
		}

		public new uint value {
			get { return (uint)get_field_value(); }
			set { set_field_value(value); }
		}

		protected override Value get_field_value() {
			if (enabled == false)
				return 0;
			return base.get_field_value();
		}
		protected override void set_field_value(Value value) {
			if (enabled == false)
				return;
			uint speed = (uint)value;
			if (speed < CLOCKSPEED_MIN)
				speed = CLOCKSPEED_MIN;
			else if (speed > CLOCKSPEED_MAX)
				speed = CLOCKSPEED_MAX;

			base.set_field_value(speed);
		}
	}
}
