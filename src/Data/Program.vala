using Catapult;
using Fields;
using Menus;
using Menus.Fields;

namespace Data
{
	public class Program : Object, MenuObject
	{
		public string name { get; set; }
		public string pnd_id { get; set; }
		public string pnd_app_id { get; set; }
		public string command { get; set; }
		public string custom_command { get; set; }

		public string arguments { get; set; }
		public uint clockspeed { get; set; }

		// menu
		protected void build_menu(MenuBuilder builder) {
			name_field = builder.add_string("name", "Name", null, this.name);
			name_field.add_validator(value=> {
				string? str = (string?)value;
				if (str == null || str == "")
					return false;
				return true;
			}, "Name is required.");
			app_field = new PndAppField("pnd_app", "Pnd App", "Choose the app...", pnd_app_id, pnd_id);
			builder.add_field(app_field);
			
			command_field = builder.add_string("command", "Command", null, command ?? "");
			// custom command field
			custom_command_field = new CustomCommandField("custom_command", "Custom Command", null, name, custom_command, pnd_app_id, pnd_id);
			builder.add_field(custom_command_field);
			
			
			arguments_field = builder.add_string("arguments", "Arguments", arguments ?? "");
			clockspeed_field = new ClockSpeedField("clockspeed", "Clockspeed", "How fast?", clockspeed, 150, 1000, 5);
			builder.add_field(clockspeed_field);
			
			initialize_fields();
		}
		void initialize_fields() {
			app_field.changed.connect(() => {
				update_fields_from_app(true);
				custom_command_field.set_app(app_field.pnd_app_id, app_field.pnd_id);
			});
			update_fields_from_app(false);
		}
		void update_fields_from_app(bool replace) {
			var app = app_field.value;
			//command_field.sensitive = (app == null);
			if (app != null) {
				if (replace == true || command_field.value == "")
					command_field.value = app.exec_command ?? "";
				if (replace == true || arguments_field.value == "")
					arguments_field.value = app.exec_arguments ?? "";
				clockspeed_field.default_value = app.clockspeed;
			} else {
				clockspeed_field.default_value = 0;
			}
		}
		protected bool apply_menu(Menu menu) {
			if (name_field.has_changes())
				name = name_field.value;
			if (app_field.has_changes()) {
				pnd_id = app_field.pnd_id;
				pnd_app_id = app_field.pnd_app_id;
			}
			if (command_field.has_changes())
				command = command_field.value;
			if (custom_command_field.has_changes())
				custom_command = custom_command_field.value;
			if (arguments_field.has_changes())
				arguments = arguments_field.value;
			if (clockspeed_field.has_changes())
				clockspeed = clockspeed_field.value;
				
			return true;
		}
		
		Menus.Fields.StringField name_field;
		PndAppField app_field;
		Menus.Fields.StringField command_field;
		CustomCommandField custom_command_field;
		Menus.Fields.StringField arguments_field;
		ClockSpeedField clockspeed_field;

	}
}
