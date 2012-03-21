using Catapult;
using Menus;
using Menus.Fields;

namespace Data.Options
{
	public class IntegerOption : Option
	{
		public IntegerOption(OptionSet parent) {
			base(parent);
		}
		public override OptionType option_type { get { return OptionType.INTEGER; } }
		public int min_value { get; set; }
		public int max_value { get; set; }
		public int default_value { get; set; }
		public bool include_option_for_default_value { get; set; }
		
		// menu
		protected override void build_edit_fields(MenuBuilder builder) {
			builder.add_int("min_value", "Minimum Value", null, min_value, int.MIN, int.MAX);
			builder.add_int("max_value", "Maximum Value", null, max_value, int.MIN, int.MAX);
			builder.add_int("default_value", "Default Value", null, default_value, int.MIN, int.MAX);
			builder.add_bool("include_option_for_default_value", "Include for Default", null, include_option_for_default_value);
		}
		
		// setting field
		public override MenuItemField get_setting_field(string? setting) {
			return new IntegerField(name, name, help, get_setting_value(setting), min_value, max_value);
		}
		public override string get_setting_value_from_field(MenuItemField field) {
			return (field as IntegerField).value.to_string();
		}
		
		// setting
		public override string get_option_from_setting_value(string? setting) {
			int value = get_setting_value(setting);
			if (value == default_value && include_option_for_default_value == false)
				return "";
			
			return option + value.to_string();
		}
		
		int get_setting_value(string? setting) {
			int val = (setting != null)
				? int.parse(setting)
				: default_value;			
			
			if (val < min_value)
				val = min_value;
			if (val > max_value)
				val = max_value;
			
			return val;
		}
	}
}
