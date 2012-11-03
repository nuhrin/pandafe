using Gee;
using Catapult;
using Data.Programs;

namespace Data.Options
{
	public class OptionSet : ArrayList<Option>, IYamlObject
	{
		public string get_option_string_from_settings(ProgramSettings settings, string? extra_arguments) {
			var sb = new StringBuilder();
			var options = setting_options();
			foreach(var option in options) {
				string? setting = null;
				if (settings.has_key(option.setting_name) == true)
					setting = settings[option.setting_name];
				var output = option.get_option_from_setting_value(setting);
				if (output != null && output != "")
					sb.append(output).append(" ");
			}
			if (extra_arguments != null)
				sb.append(" ").append(extra_arguments);
			return sb.str.strip();
		}
		Gee.List<Option> setting_options() {
			var list = new ArrayList<Option>();
			add_options(this, list);
			return list;			
		}
		void add_options(OptionSet options, ArrayList<Option> list) {
			foreach(var option in options) {
				var option_grouping = option as OptionGrouping;
				if (option_grouping != null)
					add_options(option_grouping.options, list);
				else
					list.add(option);
			}
		}
		
		// yaml
		protected Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var sequence = new Yaml.SequenceNode();
			foreach(var option in this)
				sequence.add(build_option_yaml_node(builder, option));
			return sequence;
		}
		protected void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var sequence = node as Yaml.SequenceNode;
			if (sequence == null)
				return;
			foreach(var option_mapping in sequence.mappings()) {
				OptionType option_type = get_option_type_from_mapping(parser, option_mapping);
				if (option_type != OptionType.NONE) {
					var option = option_type.create_option(this);
					if (option != null) {
						apply_option_yaml_node(option_mapping, parser, option);
						this.add(option);
					}
				}
			}
		}
		
		Yaml.Node build_option_yaml_node(Yaml.NodeBuilder builder, Option option) {
			var mapping = new Yaml.MappingNode();			
			builder.add_item_to_mapping("type", option.option_type, mapping);
			option.populate_yaml_mapping(builder, mapping);
			return mapping;
		}
		
		OptionType get_option_type_from_mapping(Yaml.NodeParser parser, Yaml.MappingNode mapping) {			
			var key = mapping.scalar_keys().where(s=>s.value == "type").first();
			if (key != null)
				return parser.parse<OptionType>(mapping[key], OptionType.NONE);
			
			return OptionType.NONE;
		}
		
		protected void apply_option_yaml_node(Yaml.Node node, Yaml.NodeParser parser, Option option) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return;
			foreach(var key in mapping.scalar_keys()) {
				if (key.value == "type")
					continue;
				parser.set_object_property(option, key.value, mapping[key]);
			}
			option.post_yaml_load();
		}		
	}
}
