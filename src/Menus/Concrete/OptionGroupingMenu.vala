using Gee;
using Data;
using Data.Options;
using Data.Programs;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class OptionGroupingMenu : Menu  
	{	
		OptionSet options;
		ProgramSettings settings;		
		string program_name;
		string? title_prefix;
		HashMap<Option,MenuItemField> field_hash;
		
		public OptionGroupingMenu(OptionGrouping grouping, ProgramSettings settings, string program_name, string? title_prefix=null) {
			base("%s%s Settings: %s".printf(title_prefix ?? "", grouping.name, program_name));
			this.options = grouping.options;
			this.settings = settings;
			this.program_name = program_name;
			this.title_prefix = title_prefix;
			field_hash = new HashMap<Option,MenuItemField>();			
		}
		
		public void populate_settings_from_fields(ProgramSettings target_settings) {
			foreach(var option in options) {
				var field = field_hash[option];
				var grouping_field = field as OptionGroupingField;
				if (grouping_field != null)
					grouping_field.populate_settings_from_fields(target_settings);
				else
					target_settings[option.setting_name] = option.get_setting_value_from_field(field);
			}
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) {
			foreach(var option in options) {
				var grouping = option as OptionGrouping;
				if (grouping != null) {
					var field = grouping.get_grouping_field(settings, program_name, title_prefix);
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
			items.add(new MenuItem.cancel_item("Return"));
		}	
	}
}