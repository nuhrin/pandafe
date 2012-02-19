using Catapult;
using Menus;
using Menus.Fields;

namespace Data.Options
{
	public class FlagOption : Option
	{
		public override OptionType option_type { get { return OptionType.FLAG; } }
		public bool on_by_default { get; set; }
		
		// menu
		protected override void build_edit_fields(MenuBuilder builder) {
			builder.add_bool("on_by_default", "On By Default", null, on_by_default);
		}
		
		// setting field
		public override MenuItemField get_setting_field(string? setting) {
			return new BooleanField(name, name, help, get_setting_value(setting));
		}
		public override string get_setting_value_from_field(MenuItemField field) {
			return (field as BooleanField).value.to_string();
		}
		
		// setting
		public override string get_option_from_setting_value(string? setting) {
			if (setting == null)
				return (on_by_default == true) ? option : "";
				
			if (get_setting_value(setting) == true)
				return option;
			return "";
		}
		
		bool get_setting_value(string? setting) {
			if (setting != null) {
				bool val;
				if (bool.try_parse(setting, out val) == true)
					return val;
			}
			return on_by_default;
		}
	}
}
