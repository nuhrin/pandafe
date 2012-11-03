using Gee;
using Catapult;
using Data.Programs;

namespace Data.Platforms
{
	public class PlatformProgramSettingsMap :  HashMap<string,ProgramDefaultSettings>, IYamlObject
	{
		public PlatformProgramSettingsMap() {
			base();
		}
		public PlatformProgramSettingsMap.clone(PlatformProgramSettingsMap basis) {
			this();
			foreach(var key in basis.keys) {
				var settings = basis[key];
				var new_settings = new ProgramDefaultSettings();
				new_settings.merge_override(settings);
				this[key] = new_settings;
			}
		}
		
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
				this[scalar_key.value] = parser.parse<ProgramDefaultSettings>(settings_mapping, new ProgramDefaultSettings());
			}
		}
	}
}
