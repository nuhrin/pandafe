using Catapult;
using Menus;
using Menus.Fields;
using Fields;
using Data.Programs;

namespace Data.Options
{
	public class OptionGrouping : Option
	{
		public OptionGrouping() {
			options = new OptionSet();
		}
		public override OptionType option_type { get { return OptionType.GROUPING; } }
		public OptionSet options { get; set; }
		
		// menu
		protected override void build_menu(MenuBuilder builder) {
			add_name_field(name, builder);
			var options_field = new ProgramOptionsListField("options", "Options", null, options);
			options_field.required = true;
			builder.add_field(options_field);
			builder.add_string("help", "Help", "Help text to display during option selection", help ?? "");
		}
		protected override void build_edit_fields(MenuBuilder builder) { }
		protected bool save_object(Menu menu) {
			set_option_setting_prefix();
			return true;
		}
		
		// setting field
		public override MenuItemField get_setting_field(string? setting) {
			assert_not_reached();
		}
		public override string get_setting_value_from_field(MenuItemField field) {
			return "";
		}
		public OptionGroupingField get_grouping_field(string program_name, ProgramSettings settings) {
			return new OptionGroupingField(name, name, help, this, program_name, settings);
		}
		
		// setting
		public override string get_option_from_setting_value(string? setting) {
			return "";
		}
		
		
		// yaml
		internal override void populate_yaml_mapping(Yaml.NodeBuilder builder, Yaml.MappingNode mapping) {
			builder.add_mapping_values(mapping, "name", name);
			builder.add_mapping_values(mapping, "help", help);
			builder.add_mapping_values(mapping, "options", options);
		}
		internal override void post_yaml_load() { 
			set_option_setting_prefix();
		}
		void set_option_setting_prefix() {
			foreach(var option in options)
				option.set_setting_prefix(this.setting_name + "/");			
		}
	}
}
