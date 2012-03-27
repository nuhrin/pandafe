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
		public static bool edit(string program_name, ProgramDefaultSettings settings, OptionSet options, int clockspeed=-1, string? extra_arguments=null) {
			var menu = new ProgramDefaultSettingsMenu("Default", program_name, settings, options, clockspeed, extra_arguments);
			new MenuBrowser(menu).run();
			return menu.was_saved;
		}
	
		string? title_prefix;
		string program_name;
		OptionSet options;
		HashMap<Option,MenuItemField> field_hash;
		ProgramDefaultSettings original_settings;
		ProgramDefaultSettings settings;
		StringField extra_arguments_field;
		ClockSpeedField clockspeed_field;
		
		public ProgramDefaultSettingsMenu(string title_prefix, string program_name, ProgramDefaultSettings settings, OptionSet options, int clockspeed=-1, string? extra_arguments=null) {
			base(title_prefix + " Settings: " + program_name);
			this.title_prefix = title_prefix;
			this.program_name = program_name;
			this.options = options;
			this.original_settings = settings;
			var effective = new ProgramDefaultSettings();
			effective.merge_override(settings);
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
		
		protected override bool do_cancel() {
			was_saved = false;
			return true;
		}
		protected override bool do_save() {
			original_settings.clear();			
			foreach(var option in options) {
				var field = field_hash[option];
				var grouping_field = field as OptionGroupingField;
				if (grouping_field != null)
					grouping_field.populate_settings_from_fields(original_settings);
				else
					original_settings[option.setting_name] = option.get_setting_value_from_field(field);
			}
			original_settings.extra_arguments = extra_arguments_field.value;							
			original_settings.clockspeed = clockspeed_field.value;
			was_saved = true;
			return true;
		}
		protected override void do_refresh(uint select_index) {
			clear_items();
			ensure_items();
		}

		protected override void populate_items(Gee.List<MenuItem> items) {
			foreach(var option in options) {
				var grouping = option as OptionGrouping;
				if (grouping != null) {
					var field = grouping.get_grouping_field(original_settings, null, program_name, title_prefix + " ");
					field_hash[option] = field;
					items.add(field);
					continue;
				}
				string? setting = null;
				if (settings.has_key(option.setting_name) == true)
					setting = settings[option.setting_name];
				var field = option.get_setting_field(setting);
				field_hash[option] = field;
				items.add(field);
			}
			string name = (options.size > 0) ? "Extra Arguments" : "Arguments";
			extra_arguments_field = new StringField("extra_arguments", name, null, settings.extra_arguments ?? "");
			items.add(extra_arguments_field);
			
			clockspeed_field = new ClockSpeedField("clockspeed", "Clockspeed", null, settings.clockspeed, 150, 1000, 5);
			items.add(clockspeed_field);
			items.add(new MenuItemSeparator());
			var reset_index = items.size;
			items.add(new MenuItem.custom("Reset", "Reset settings to defaults", "", () => {
				this.settings.clear();
				refresh(reset_index);
			}));
			items.add(new MenuItem.cancel_item());
			items.add(new MenuItem.save_item());
		}
	}
}
