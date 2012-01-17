using Gtk;
using Gee;
using Catapult;
using Catapult.Gui;
using Catapult.Gui.Fields;
using Data;

namespace Fields
{
	public class ProgramListField : ListValueField<Program>
	{
		DataInterface data_interface;
		public ProgramListField(DataInterface data_interface, string id, string? label=null, Gee.List<Program>? list=null) {
			base(id, label);
			this.data_interface = data_interface;
			if (list != null) {
				replace_items(list);
				make_clean();
			}
		}

		protected override bool values_are_equal(Program a, Program b) { return a.name == b.name; }
		protected override string get_name_from_value(Program value) { return value.name; }
		protected override bool on_add_button_pressed(out Program new_item) {
			Program item = null;
			try {
				item = EntityDialog.create<Program>(Data.data_interface());
			} catch (Error e) {
				debug("Error while creating Program: %s", e.message);
			}
			new_item = item;
			return (item != null);
		}
		protected override bool on_edit_button_pressed(Program item) {
			bool retVal = false;
			try {
				retVal = EntityDialog.edit_object(Data.data_interface(), item, "Program", item.name);
			} catch (Error e) {
				debug("Error while editing Program: %s", e.message);
			}
			return retVal;
		}

	}
}
