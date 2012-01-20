using Catapult;
using Catapult.Gui;
using Catapult.Gui.Fields;
using Catapult.Gui.Fieldsets;
using GtkFields;
using Fields;
using Menus;
using Menus.Fields;

namespace Data
{
	public class Program : Object, GuiEntity, MenuObject
	{
		public string name { get; set; }
		public string pnd_id { get; set; }
		public string pnd_app_id { get; set; }
		public string command { get; set; }
		public string custom_command { get; set; }

		public string arguments { get; set; }
		public uint clockspeed { get; set; }

		// gui
		protected void populate_field_container(FieldContainer container) {
			// add Program frame
			var program_frame = new FrameFieldset("ProgramFrame", "Program");
			program_frame.add_string("name", "_Name", this.name);

			var pndData = Data.pnd_data();
			pnd_id_field = new GtkPndSelectionField(pndData, "pnd_id", "_Pnd", pnd_id);
			program_frame.add_field(pnd_id_field);
			app_id_field = new GtkPndAppSelectionField(pndData, "pnd_app_id", "Pnd _App", pnd_id, pnd_app_id);
			program_frame.add_field(app_id_field);

			command_field = program_frame.add_string("command", "_Command", command ?? "");
			custom_command_field = new GtkCustomCommandField("custom_command", "C_ustom Command", name, custom_command, pnd_id, pnd_app_id);
			program_frame.add_field(custom_command_field);

			container.add_field(program_frame);

			// add Options frame
			var options_frame = new FrameFieldset("OptionsFrame", "Options");

			arguments_field = options_frame.add_string("arguments", "_Arguments", arguments ?? "");
			clockspeed_field = new GtkClockspeedField("clockspeed", "_Clockspeed", clockspeed);
			options_frame.add_field(clockspeed_field);

			container.add_field(options_frame);

			initialize_fields();
		}
		void initialize_fields() {
			pnd_id_field.changed.connect(() => {
				var pnd_id = pnd_id_field.value;
				app_id_field.reload(pnd_id);
				app_id_field.sensitive = (pnd_id != "");
				custom_command_field.pnd_id = pnd_id;
				custom_command_field.pnd_app_id = app_id_field.app_id;
			});
			if (pnd_id == "")
				app_id_field.sensitive = false;
			app_id_field.changed.connect(() =>  {
				update_fields_from_app(true);
				custom_command_field.pnd_app_id = app_id_field.app_id;
			});

			update_fields_from_app(false);
		}
		void update_fields_from_app(bool replace) {
			var app = app_id_field.value;
			command_field.sensitive = (app == null);
			if (app != null) {
				command_field.sensitive = false;
				if (replace == true || command_field.value == "")
					command_field.value = app.exec_command ?? "";
				if (replace == true || arguments_field.value == "")
					arguments_field.value = app.exec_arguments ?? "";
				if (replace == true || clockspeed_field.enabled == false) {
					if (app.clockspeed == 0) {
						clockspeed_field.enabled = false;
					} else {
						clockspeed_field.enabled = true;
						clockspeed_field.value = app.clockspeed;
					}
				}
			} else {
				command_field.sensitive = true;
			}
		}
		GtkPndSelectionField pnd_id_field;
		GtkPndAppSelectionField app_id_field;
		Gui.Fields.StringField command_field;
		GtkCustomCommandField custom_command_field;
		Gui.Fields.StringField arguments_field;
		GtkClockspeedField clockspeed_field;
		
		// menu
		protected void build_menu(MenuBuilder builder) {
			name_menu_item = builder.add_string("name", "Name", null, this.name);
			name_menu_item.add_validator(value=> {
				string? str = (string?)value;
				if (str == null || str == "")
					return false;
				return true;
			}, "Name is required.");
			app_menu_item = new PndAppField("pnd_app", "Pnd App", "Choose the app...", pnd_app_id, pnd_id);
			builder.add_item(app_menu_item);
			
			command_menu_item = builder.add_string("command", "Command", null, command ?? "");
			// custom command field
			custom_command_menu_item = new CustomCommandField("custom_command", "Custom Command", null, name, custom_command, pnd_app_id, pnd_id);
			builder.add_item(custom_command_menu_item);
			
			
			arguments_menu_item = builder.add_string("arguments", "Arguments", arguments ?? "");
			clockspeed_menu_item = new ClockSpeedField("clockspeed", "Clockspeed", "How fast?", clockspeed, 150, 1000, 5);
			builder.add_item(clockspeed_menu_item);
			
			initialize_menu_items();
		}
		void initialize_menu_items() {
			app_menu_item.changed.connect(() => {
				update_menu_items_from_app(true);
				custom_command_menu_item.set_app(app_menu_item.pnd_app_id, app_menu_item.pnd_id);
			});
			update_menu_items_from_app(false);
		}
		void update_menu_items_from_app(bool replace) {
			var app = app_menu_item.value;
			//command_field.sensitive = (app == null);
			if (app != null) {
				if (replace == true || command_menu_item.value == "")
					command_menu_item.value = app.exec_command ?? "";
				if (replace == true || arguments_menu_item.value == "")
					arguments_menu_item.value = app.exec_arguments ?? "";
				clockspeed_menu_item.default_value = app.clockspeed;
			} else {
				clockspeed_menu_item.default_value = 0;
			}
		}
		protected bool apply_menu(Menu menu) {
			if (name_menu_item.has_changes())
				name = name_menu_item.value;
			return false;
		}
		
		Menus.Fields.StringField name_menu_item;
		PndAppField app_menu_item;
		Menus.Fields.StringField command_menu_item;
		CustomCommandField custom_command_menu_item;
		Menus.Fields.StringField arguments_menu_item;
		ClockSpeedField clockspeed_menu_item;
		Menus.Fields.FolderField rom_folder_root_menu_item;

	}
}
