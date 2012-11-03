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
	public string? platform { get; set; }
	
	protected override string generate_id() {
		assert_not_reached();
	}
	
	public class ProgramSettingsMap : HashMap<string,ProgramSettings>, IYamlObject
	{
		// yaml
		protected Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			return builder.populate_mapping_with_map_items(this);
		}
		protected void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return;
			foreach(var scalar_key in mapping.scalar_keys()) {
				var settings_mapping = mapping[scalar_key] as Yaml.MappingNode;
				if (settings_mapping == null)
					continue;
				this[scalar_key.value] = parser.parse<ProgramSettings>(settings_mapping, new ProgramSettings());
			}
		}
	}
}
