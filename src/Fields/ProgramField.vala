using Data;
using Data.Pnd;
using Menus;
using Menus.Fields;
using Layers.Controls;

namespace Fields
{
	public class ProgramField : MenuItemField
	{
		Program? _program;
		public ProgramField(string id, string name, string? help=null, Program? program) {
			base(id, name, help);
			_program = program;
		}

		public new Program? value {
			get { return _program; }
			set { change_value(value); }
		}

		public override string get_value_text() { return (_program != null) ? _program.name : ""; }
		public override int get_minimum_menu_value_text_length() { return 15; }

		protected override Value get_field_value() { return _program; }
		protected override void set_field_value(Value value) { change_value((Program?)value); }
		protected override bool has_value() { return (_program != null && _program.name.strip() != ""); }

		protected override void activate(Menus.MenuSelector selector) {
			var rect = selector.get_selected_item_value_entry_rect();
			var all_programs = Data.programs().get_all_programs();					
			var action_selector = new StringSelector("program_field_action", rect.x, rect.y, 250);
			if (_program != null)
				action_selector.add_item("Edit");
			if (all_programs.any())
				action_selector.add_item("Select Existing");
			action_selector.add_item("Create");
			action_selector.run();
			if (action_selector.was_canceled)
				return;
			string action = action_selector.selected_item();
			switch(action) {
				case "Edit":
					ObjectMenu.edit("Edit Program", _program);					
					break;
				case "Select Existing":
					uint existing_program_index = 0;
					if (_program != null) {
						uint index=0;
						foreach(var program in all_programs) {
							if (program.id == _program.id) {
								existing_program_index = index;
								break;
							}
							index++;
						}
					}
					var existing_selector = new ValueSelector<Program>("existing_program", rect.x, rect.y, 250, 
						p => p.name, all_programs, existing_program_index);
					existing_selector.can_select_single_item = true;
					existing_selector.run();
					if (existing_selector.was_canceled)
						return;
					change_value(existing_selector.selected_item());
					break;
				case "Create":
					var chooser = new PndAppChooser("app_chooser", "Choose App");
					var selected_app = chooser.run();
					if (selected_app == null)
						return;
					var program = Data.programs().get_program_for_app(selected_app.id);
					if (ObjectMenu.edit("Edit Program", program) == false)
						return;
					change_value(program);
					break;
				default:
					break;
			}
			selector.update_selected_item_value();
			selector.update();
		}

		bool change_value(Program? new_value) {
			if (new_value == null) {
				if (_program == null)
					return false;
			} else {
				if (_program != null && _program.id == new_value.id)
					return false;
			}
			_program = new_value;
			changed();
			return true;	
		}
	}
}
