using Gee;
using Data;
using Data.Options;
using Data.Programs;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class ProgramSettingsMenu : Menu  
	{	
		public static bool edit(Program program, ProgramSettings settings, int clockspeed=-1) {
			var menu = new ProgramSettingsMenu(program, settings, clockspeed);
			new MenuBrowser(menu, 40, 40).run();
			return menu.was_saved;
		}
		public static bool edit_default(Program program, ProgramDefaultSettings settings, int clockspeed=-1, string? extra_arguments=null) {
			var menu = new ProgramSettingsMenu.default(program, settings, clockspeed, extra_arguments);
			new MenuBrowser(menu, 40, 40).run();
			return menu.was_saved;
		}
		
		OptionSet options;
		HashMap<Option,MenuItemField> field_hash;
		ProgramSettings original_settings;
		ProgramDefaultSettings? default_settings;
		ProgramSettings settings;
		StringField extra_arguments_field;
		ClockSpeedField clockspeed_field;
		
		public ProgramSettingsMenu(Program program, ProgramSettings settings, int clockspeed=-1) {
			this.internal(program, settings, null);
			if (clockspeed >= 0)
				set_clockspeed(clockspeed);			
		}
		public ProgramSettingsMenu.default(Program program, ProgramDefaultSettings settings, int clockspeed=-1, string? extra_arguments=null) {
			this.internal(program, settings, settings);
			if (clockspeed >= 0)
				set_clockspeed(clockspeed);
			if (extra_arguments != null)
				set_extra_arguments(extra_arguments);
		}
		ProgramSettingsMenu.internal(Program program, ProgramSettings settings, ProgramDefaultSettings? default_settings=null) {
			var name_prefix = (default_settings != null) ? "Default Settings: " : "Settings: ";
			base(name_prefix + program.name);
			this.options = program.options;			
			this.original_settings = settings;
			this.default_settings = default_settings;
			var effective = new ProgramSettings();
			effective.merge_override(program.default_settings);
			effective.merge_override(settings);
			this.settings = effective;
			field_hash = new HashMap<Option,MenuItemField>();
			ensure_items();		
		}
		
		
		public bool was_saved { get; private set; }
		
		void set_clockspeed(uint clockspeed) {
			clockspeed_field.value = clockspeed;
		}
		void set_extra_arguments(string extra_arguments) {
			if (extra_arguments_field != null)
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
			if (default_settings != null)
				default_settings.extra_arguments = extra_arguments_field.value;							
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
			if (default_settings != null) {
				string name = (options.size > 0) ? "Extra Arguments" : "Arguments";
				extra_arguments_field = new StringField("extra_arguments", name, null, default_settings.extra_arguments ?? "");
				items.add(extra_arguments_field);
			}
			clockspeed_field = new ClockSpeedField("clockspeed", "Clockspeed", null, settings.clockspeed, 150, 1000, 5);
			items.add(clockspeed_field);
			items.add(new MenuItem.cancel_item());
			items.add(new MenuItem.save_item());
		}		
	}
}
