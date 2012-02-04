using Gee;
using Catapult;

namespace Data
{
	public class ProgramSettings : HashMap<string, string>, IYamlObject
	{		
		public uint clockspeed { get; set; }
		
		public void merge_override(ProgramSettings settings) {
			foreach(var key in settings.keys)
				this[key] = settings[key];
			if (settings.clockspeed != 0)
				clockspeed = settings.clockspeed;
		}
		
		// yaml
		protected Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {			
			var mapping = new Yaml.MappingNode();
			build_additional_properties(mapping, builder);
			foreach(var key in this.keys)
				mapping.set_scalar(key, builder.build_value(this[key]));
			return mapping;
		}
		protected virtual void build_additional_properties(Yaml.MappingNode mapping, Yaml.NodeBuilder builder) {
			mapping.set_scalar("clockspeed", builder.build_value(clockspeed));			
		}
		protected bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return false;
			foreach(var scalar_key in mapping.scalar_keys()) {
				var scalar_value = mapping[scalar_key] as Yaml.ScalarNode;
				if (scalar_value == null)
					continue;
				if (apply_property_value(scalar_key.value, scalar_value, parser) == true)
					continue;
				this[scalar_key.value] = scalar_value.value;
			}
			return true;
		}
		protected virtual bool apply_property_value(string key, Yaml.ScalarNode node, Yaml.NodeParser parser) {
			if (key == "clockspeed") {
				clockspeed = parser.parse<uint>(node, 0);
				return true;
			}
			return false;
		}
		
		protected string get_yaml_tag() { return ""; }
		protected Yaml.Node? build_unhandled_value_node(Yaml.NodeBuilder builder, Value value) { return null; }
		protected bool apply_unhandled_value_node(Yaml.Node node, string property_name, Yaml.NodeParser parser) { return false; }
	}
	
	public class ProgramDefaultSettings : ProgramSettings
	{
		public string extra_arguments { get; set; }
		
		protected override void build_additional_properties(Yaml.MappingNode mapping, Yaml.NodeBuilder builder) {
			if (extra_arguments != null)
				mapping.set_scalar("extra-arguments", builder.build_value(extra_arguments));
			base.build_additional_properties(mapping, builder);
		}
		protected override bool apply_property_value(string key, Yaml.ScalarNode node, Yaml.NodeParser parser) {
			if (key == "extra-arguments") {
				extra_arguments = node.value;
				return true;
			}
			return base.apply_property_value(key, node, parser);
		}
	}
}
