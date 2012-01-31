using Gee;
using Catapult;

namespace Data
{
	public class ProgramSettings : HashMap<string, string>
	{
		public void merge_override(ProgramSettings settings) {
			foreach(var key in settings.keys)
				this[key] = settings[key];			
		}
	}
	
	public class ProgramDefaultSettings : ProgramSettings, IYamlObject
	{
		public string extra_arguments { get; set; }
		
		// yaml
		protected Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {			
			var mapping = new Yaml.MappingNode();
			if (extra_arguments != null)
				mapping.set_scalar("extra-arguments", builder.build_value(extra_arguments));
			foreach(var key in this.keys)
				mapping.set_scalar(key, builder.build_value(this[key]));
			return mapping;
		}
		protected bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return false;
			foreach(var scalar_key in mapping.scalar_keys()) {
				var scalar_value = mapping[scalar_key] as Yaml.ScalarNode;
				if (scalar_value == null)
					continue;
				if (scalar_key.value == "extra-arguments")
					extra_arguments = scalar_value.value;
				else
					this[scalar_key.value] = scalar_value.value;
			}
			return true;
		}
		
		protected string get_yaml_tag() { return ""; }
		protected Yaml.Node? build_unhandled_value_node(Yaml.NodeBuilder builder, Value value) { return null; }
		protected bool apply_unhandled_value_node(Yaml.Node node, string property_name, Yaml.NodeParser parser) { return false; }
	}
}
