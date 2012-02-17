using Gee;
using SDL;
using Catapult;
using Data;
using Layers.Controls;
using Layers.Controls.List;
using Menus;
using Menus.Fields;

namespace Fields
{
	public class ProgramListField : ListField<Program>
	{
		public ProgramListField(string id, string name, string? help=null, Gee.List<Program> value) {
			base(id, name, help, value);
		}
		
		protected override ListEditor<Program> get_list_editor() {
			return new ProgramListEditor(id, name, value, p=>p.name);
		}
		
		class ProgramListEditor : ListEditor<Program>
		{
			public ProgramListEditor(string id, string name, Gee.List<Program> list, owned MapFunc<string?, Program> get_name_string) {
				base(id, name, list, (owned)get_name_string);
			}
			protected override bool create_item(Rect selected_item_rect, out Program item) {
				item = null;
				var chooser = new PndAppChooser("new_program_app_chooser", "Select app for program...");
				var app = chooser.run();
				if (app != null) {
					item = Data.programs().get_program_for_app(app.id);
					return true;
				}
				return false;
			}
			protected override bool edit_list_item(ListItem<Program> item, uint index) {
				return ObjectMenu.edit("Edit Program", item.value);
			}
		}
	}
}
