using Gtk;

namespace yayafe.Gui.Fields
{
	public class EnumField : ValueSelectionField
	{
		EnumClass enum_class;
		public EnumField(string name, string? label=null, Value enum_value)
			requires(enum_value.type().is_enum())
		{
			base(name, label, enum_value.type());
			enum_class = (EnumClass)enum_value.type().class_ref();
			int index = 0;
			int value = enum_value.get_enum();
			foreach(var ev in enum_class.values)
			{
				Value val = Value(value_type);
				val.set_enum(ev.value);
				add_item(ev.value_nick, val);
				if (value == ev.value)
					combo_box.active = index;
				index++;
			}
		}

		public new int value {
			get { return get_field_value().get_enum(); }
			set {
				Value val = Value(value_type);
				foreach(var ev in enum_class.values) {
					if (value == ev.value) {
						val.set_enum(value);
						set_field_value(val);
						return;
					}
				}
				val.set_enum(0);
				set_field_value(val);
			}
		}

		protected override bool values_are_equal(Value a, Value b) {
			return a.get_enum() == b.get_enum();
		}
	}
}