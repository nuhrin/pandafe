using Gee;
using Data;
using Data.Options;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class ProgramSettingsMenu : Menu  
	{	
		public static bool edit(Program program, ProgramSettings settings) {
			var menu = new ProgramSettingsMenu(program, settings);
			new MenuBrowser(menu, 40, 40).run();
			return menu.saved;
		}
		
		OptionSet options;
		HashMap<Option,MenuItemField> field_hash;
		ProgramSettings original_settings;
		ProgramDefaultSettings? default_settings;
		ProgramSettings settings;
		StringField extra_arguments_field;
		ClockSpeedField clockspeed_field;
		
		public ProgramSettingsMenu(Program program, ProgramSettings settings) {
			var default_settings = settings as ProgramDefaultSettings;
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
		
		public bool saved { get; private set; }
		
		public override bool do_cancel() {
			saved = false;
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
			default_settings.clockspeed = clockspeed_field.value;
			saved = true;
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
			clockspeed_field = new ClockSpeedField("clockspeed", "Clockspeed", null, default_settings.clockspeed, 150, 1000, 5);
			items.add(clockspeed_field);
			items.add(new MenuItem.cancel_item());
			items.add(new MenuItem.save_item());
		}		
	}
}
