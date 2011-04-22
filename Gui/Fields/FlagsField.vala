using Gtk;

namespace yayafe.Gui.Fields
{
	public class FlagsField : ValueMultipleSelectionField
	{
		GLibPatch.FlagsClass flags_class;
		public FlagsField(string name, string? label=null, Value flags_value)
			requires(flags_value.type().is_flags())
		{
			base(name, label, typeof(int));
			flags_class = (GLibPatch.FlagsClass)flags_value.type().class_ref();
			foreach(var fv in flags_class.values)
				add_item(fv.value_nick, fv.value);
			this.value = flags_value.get_flags();
		}

		public new uint value {
			get { return get_field_value().get_flags(); }
			set { set_field_value(value); }
		}

//		protected override bool values_are_equal(Value a, Value b) {
//			//return a.get_enum() == b.get_enum();
//			return false;
//		}
	}
}