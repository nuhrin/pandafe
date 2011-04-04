using YamlDB;
using yayafe.Gui.Fields;

namespace yayafe.Gui
{
	public interface GuiEntity : Object
	{
		protected abstract void build_dialog(DialogBuilder builder);
		internal void i_build_dialog(DialogBuilder builder) { build_dialog(builder); }

		protected abstract void apply_dialog(DialogReader reader);
		internal void i_apply_dialog(DialogReader reader) { apply_dialog(reader); }

		protected abstract LabeledField get_reference_selection_field(DataInterface data_interface);
		internal LabeledField i_get_reference_selection_field(DataInterface data_interface) { return get_reference_selection_field(data_interface); }
	}
}
