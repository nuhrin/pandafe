using Catapult;
using Catapult.Gui;
using Catapult.Gui.Fields;
using Catapult.Gui.Fieldsets;
using Fields;

namespace Data
{
	public class Program : Object, GuiEntity
	{
		public string name { get; set; }
		public string pnd_id { get; set; }
		public string pnd_app_id { get; set; }
		public string command { get; set; }
		public string custom_command { get; set; }

		public string arguments { get; set; }
		public uint clockspeed { get; set; }

		protected void populate_field_container(FieldContainer container) {
			// add Program frame
			var program_frame = new FrameFieldset("ProgramFrame", "Program");
			program_frame.add_string("name", "_Name", this.name);

			var pndData = Data.pnd_data();
			pnd_id_field = new PndSelectionField(pndData, "pnd_id", "_Pnd", pnd_id);
			program_frame.add_field(pnd_id_field);
			app_id_field = new PndAppSelectionField(pndData, "pnd_app_id", "Pnd _App", pnd_id, pnd_app_id);
			program_frame.add_field(app_id_field);

			command_field = program_frame.add_string("command", "_Command", command ?? "");
			custom_command_field = new CustomCommandField("custom_command", "C_ustom Command", name, custom_command, pnd_id, pnd_app_id);
			program_frame.add_field(custom_command_field);

			container.add_field(program_frame);

			// add Options frame
			var options_frame = new FrameFieldset("OptionsFrame", "Options");

			arguments_field = options_frame.add_string("arguments", "_Arguments", arguments ?? "");
			clockspeed_field = new ClockspeedField("clockspeed", "_Clockspeed", clockspeed);
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
				custom_command_field.pnd_app_id = app_id_field.value;
			});
			if (pnd_id == "")
				app_id_field.sensitive = false;
			app_id_field.changed.connect(() =>  {
				update_fields_from_app(true);
				custom_command_field.pnd_app_id = app_id_field.value;
			});

			update_fields_from_app(false);
		}
		void update_fields_from_app(bool replace) {
			var app = app_id_field.get_selected_app();
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
		PndSelectionField pnd_id_field;
		PndAppSelectionField app_id_field;
		StringField command_field;
		CustomCommandField custom_command_field;
		StringField arguments_field;
		ClockspeedField clockspeed_field;
	}
}
