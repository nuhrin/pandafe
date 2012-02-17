using Gee;
using Catapult;
using Data.Programs;

public class GameSettings : Entity
{
	construct {
		program_settings = new ProgramSettingsMap();
	}
	
	public string? selected_program_id { get; set; }
	
	public ProgramSettingsMap program_settings { get; set; }
	
	protected override string generate_id() {
		assert_not_reached();
	}
	
	public class ProgramSettingsMap : HashMap<string,ProgramSettings>, IYamlObject
	{
		// yaml
		protected Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var mapping = new Yaml.MappingNode();
			builder.populate_mapping<string,ProgramSettings>(mapping, this);
			return mapping;
		}
		protected bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return false;
			foreach(var scalar_key in mapping.scalar_keys()) {
				var settings_mapping = mapping[scalar_key] as Yaml.MappingNode;
				if (settings_mapping == null)
					continue;
				this[scalar_key.value] = parser.parse<ProgramSettings>(settings_mapping, new ProgramSettings());
			}
			return true;
		}

		protected string get_yaml_tag() { return ""; }
		protected Yaml.Node? build_unhandled_value_node(Yaml.NodeBuilder builder, Value value) { return null; }
		protected bool apply_unhandled_value_node(Yaml.Node node, string property_name, Yaml.NodeParser parser) { return false; }
	}
}
