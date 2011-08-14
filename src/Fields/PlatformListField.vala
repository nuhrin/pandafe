using Gtk;
using Gee;
using Catapult;
using Catapult.Gui;
using Catapult.Gui.Fields;
using Data;

namespace Fields
{
	public class PlatformListField : ListValueField<Platform>
	{
		public PlatformListField(string id, string? label=null, Gee.List<Platform>? list=null) {
			base(id, label);
			if (list != null) {
				replace_items(list);
				make_clean();
			}
		}

		protected override bool values_are_equal(Platform a, Platform b) { return a.name == b.name; }
		protected override string get_name_from_value(Platform value) { return value.name; }
		protected override bool on_add_button_pressed(out Platform new_item) {
			Platform item = null;
			try {
				item = EntityDialog.create<Platform>(Data.data_interface());
			} catch (Error e) {
				debug("Error while creating Platform: %s", e.message);
			}
			if (item == null)
				return false;
			new_item = item;
			return true;
		}
		protected override bool on_edit_button_pressed(Platform item) {
			bool retVal = false;
			try {
				retVal = EntityDialog.edit<Platform>(Data.data_interface(), item);
			} catch (Error e) {
				debug("Error while editing Platform: %s", e.message);
			}
			return retVal;
		}

	}
}
