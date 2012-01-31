using Gee;
using Catapult;

namespace Data.Options
{
	public class OptionSet : ArrayList<Option>, IYamlObject
	{
		public string get_option_string_from_settings(ProgramSettings settings, string? extra_arguments) {
			var sb = new StringBuilder();
			foreach(var option in this) {
				string? setting = null;
				if (settings.has_key(option.name) == true)
					setting = settings[option.name];
				var output = option.get_option_from_setting_value(setting);
				if (output != "")
					sb.append(output).append(" ");
			}
			if (extra_arguments != null)
				sb.append(" ").append(extra_arguments);
			return sb.str.strip();
		}
		
		// yaml
		protected Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var sequence = new Yaml.SequenceNode();
			foreach(var option in this)
				sequence.add(build_option_yaml_node(builder, option));
			return sequence;
		}
		protected bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var sequence = node as Yaml.SequenceNode;
			if (sequence == null)
				return false;
			foreach(var option_mapping in sequence.mappings()) {
				OptionType option_type = get_option_type_from_mapping(parser, option_mapping);
				if (option_type != OptionType.NONE) {
					var option = option_type.create_option();
					if (option != null) {
						apply_option_yaml_node(option_mapping, parser, option);
						this.add(option);
					}
				}
			}
			return true;
		}
		
		Yaml.Node build_option_yaml_node(Yaml.NodeBuilder builder, Option option) {
			var mapping = new Yaml.MappingNode();			
			builder.add_mapping(mapping, "option-type", option.option_type);
			builder.populate_object_mapping(mapping, option);
			return mapping;
		}
		
		OptionType get_option_type_from_mapping(Yaml.NodeParser parser, Yaml.MappingNode mapping) {			
			var key = mapping.scalar_keys().where(s=>s.value == "option-type").first();
			if (key != null)
				return parser.parse<OptionType>(mapping[key], OptionType.NONE);
			
			return OptionType.NONE;
		}
		
		protected void apply_option_yaml_node(Yaml.Node node, Yaml.NodeParser parser, Option option) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return;
			foreach(var key in mapping.scalar_keys()) {
				if (key.value == "option-type")
					continue;
				parser.populate_object_property(mapping, key, option);
			}
		}
		
		protected string get_yaml_tag() { return ""; }
		protected Yaml.Node? build_unhandled_value_node(Yaml.NodeBuilder builder, Value value) { return null; }
		protected bool apply_unhandled_value_node(Yaml.Node node, string property_name, Yaml.NodeParser parser) { return false; }
	}
}
