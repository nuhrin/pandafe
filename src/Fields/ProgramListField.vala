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
		public ProgramListField(string id, string name, string? help=null, Gee.List<Program> value, string? title=null) {
			base(id, name, help, value, title);
		}
		
		protected override ListEditor<Program> get_list_editor(string? title) {
			return new ProgramListEditor(id, title ?? name, null, value, p=>p.name);
		}
		
		class ProgramListEditor : ListEditor<Program>
		{
			public ProgramListEditor(string id, string title, string? help=null, Gee.List<Program> list, owned MapFunc<string?, Program> get_name_string) {
				base(id, title, help, list, (owned)get_name_string);
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
	public class ProgramDataListField : ListField<Program>
	{
		public ProgramDataListField(string id, string name, string? help=null, Gee.List<Program> value, string? title=null) {
			base(id, name, help, value, title);
		}
		
		protected override ListEditor<Program> get_list_editor(string? title) {
			return new ProgramDataListEditor(id, title ?? name, null, value, p=>p.name);
		}
		
		class ProgramDataListEditor : ListEditor<Program>
		{
			public ProgramDataListEditor(string id, string title, string? help=null, Gee.List<Program> list, owned MapFunc<string?, Program> get_name_string) {
				base(id, title, help, list, (owned)get_name_string);
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
			protected override bool confirm_deletion() { return true; }
			protected override bool on_delete(ListItem<Program> item) {
				string? error;
				if (Data.programs().remove_program(item.value, out error) == true)
					return true;
				debug(error);				
				return false;
			}
			protected override string? get_cancel_item_text() { return null; }
			protected override string? get_save_item_text() { return "Return"; }
		}
	}
}
