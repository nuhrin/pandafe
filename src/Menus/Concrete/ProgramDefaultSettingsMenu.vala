using Gee;
using Data;
using Data.Options;
using Data.Programs;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class ProgramDefaultSettingsMenu : Menu  
	{
		public static bool edit(Program program, int clockspeed=-1, string? extra_arguments=null) {
			var menu = new ProgramDefaultSettingsMenu(program, clockspeed, extra_arguments);
			new MenuBrowser(menu, 40, 40).run();
			return menu.was_saved;
		}
		
		OptionSet options;
		HashMap<Option,MenuItemField> field_hash;
		ProgramDefaultSettings original_settings;
		ProgramDefaultSettings settings;
		StringField extra_arguments_field;
		ClockSpeedField clockspeed_field;
		
		public ProgramDefaultSettingsMenu(Program program, int clockspeed=-1, string? extra_arguments=null) {
			base("Default Settings: " + program.name);
			this.options = program.options;			
			this.original_settings = program.default_settings;
			var effective = new ProgramDefaultSettings();
			effective.merge_override(program.default_settings);
			this.settings = effective;
			field_hash = new HashMap<Option,MenuItemField>();
			ensure_items();		
			if (clockspeed >= 0)
				set_clockspeed(clockspeed);
			if (extra_arguments != null)
				set_extra_arguments(extra_arguments);
		}
				
		public bool was_saved { get; private set; }
		
		void set_clockspeed(uint clockspeed) {
			clockspeed_field.value = clockspeed;
		}
		void set_extra_arguments(string extra_arguments) {
			extra_arguments_field.value = extra_arguments;
		}
		
		public override bool do_cancel() {
			was_saved = false;
			return true;
		}
		public override bool do_save() {
			original_settings.clear();			
			foreach(var option in options) {
				var field = field_hash[option];
				original_settings[option.name] = option.get_setting_value_from_field(field);
			}
			original_settings.extra_arguments = extra_arguments_field.value;							
			original_settings.clockspeed = clockspeed_field.value;
			was_saved = true;
			return true;
		}
		protected override void populate_items(Gee.List<MenuItem> items) {
			foreach(var option in options) {
				string? setting = null;
				if (settings.has_key(option.name) == true)
					setting = settings[option.name];
				var field = option.get_setting_field(setting);
				field_hash[option] = field;
				items.add(field);
			}
			string name = (options.size > 0) ? "Extra Arguments" : "Arguments";
			extra_arguments_field = new StringField("extra_arguments", name, null, settings.extra_arguments ?? "");
			items.add(extra_arguments_field);
			
			clockspeed_field = new ClockSpeedField("clockspeed", "Clockspeed", null, settings.clockspeed, 150, 1000, 5);
			items.add(clockspeed_field);
			items.add(new MenuItem.cancel_item());
			items.add(new MenuItem.save_item());
		}		
	}
}
