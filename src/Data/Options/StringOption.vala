using Catapult;
using Menus;
using Menus.Fields;

namespace Data.Options
{
	public class StringOption : Option
	{
		public StringOption(OptionSet parent) {
			base(parent);
		}
		public override OptionType option_type { get { return OptionType.STRING; } }
		public string? default_value { get; set; }
		
		// menu
		protected override void build_edit_fields(MenuBuilder builder) {
			builder.add_string("default_value", "Default", null, default_value);
		}
		
		// setting field
		public override MenuItemField get_setting_field(string? setting) {
			return new StringField(name, name, help, get_setting_value(setting));
		}
		public override string get_setting_value_from_field(MenuItemField field) {
			return (field as StringField).value ?? "";
		}
		
		// setting
		public override string get_option_from_setting_value(string? setting) {
			var value = get_setting_value(setting);
			if (value == null || value.strip() == "")
				return "";
                       
			return option + value;
		}
		
		string? get_setting_value(string? setting) {
			if (setting != null)
				return setting;			
			return default_value;
		}
	}
}
