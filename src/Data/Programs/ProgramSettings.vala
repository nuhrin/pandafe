using Gee;
using Catapult;

namespace Data.Programs
{
	public class ProgramSettings : HashMap<string, string>, IYamlObject
	{
		public uint clockspeed { get; set; }
		
		public void merge_override(ProgramSettings settings) {
			foreach(var entry in settings.entries)
				this[entry.key] = settings[entry.key];
			merge_override_additional(settings);
		}
		protected virtual void merge_override_additional(ProgramSettings settings) {
			if (settings.clockspeed != 0)
				clockspeed = settings.clockspeed;
		}
		
		// yaml
		protected Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var mapping = new Yaml.MappingNode();
			build_additional_properties(mapping, builder);
			builder.populate_mapping_with_map_items(this, mapping);
			return mapping;
		}
		protected virtual void build_additional_properties(Yaml.MappingNode mapping, Yaml.NodeBuilder builder) {
			mapping.set_scalar("clockspeed", builder.build_value(clockspeed));
		}
		protected void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return;
			foreach(var scalar_key in mapping.scalar_keys()) {
				var scalar_value = mapping[scalar_key] as Yaml.ScalarNode;
				if (scalar_value == null)
					continue;
				if (apply_property_value(scalar_key.value, scalar_value.value) == true)
					continue;
				this[scalar_key.value] = scalar_value.value;
			}
		}

		protected virtual bool apply_property_value(string key, string value) {
			if (key == "clockspeed") {
				clockspeed = int.parse(value);
				return true;
			}
			return false;
		}
	}
	
	public class ProgramDefaultSettings : ProgramSettings
	{
		public string extra_arguments { get; set; }
		public bool? show_output { get; set; }
		
		protected override void merge_override_additional(ProgramSettings settings) {
			var default_settings = settings as ProgramDefaultSettings;
			if (default_settings != null) {
				if(default_settings.extra_arguments != null)
					extra_arguments = default_settings.extra_arguments;
				if (default_settings.show_output != null)
					show_output = default_settings.show_output;
			}
			base.merge_override_additional(settings);
		}
		
		protected override void build_additional_properties(Yaml.MappingNode mapping, Yaml.NodeBuilder builder) {
			if (extra_arguments != null)
				mapping.set_scalar("extra-arguments", builder.build_value(extra_arguments));
			if (show_output != null)
				mapping.set_scalar("show-output", builder.build_value(show_output.to_string()));
			base.build_additional_properties(mapping, builder);
		}
		protected override bool apply_property_value(string key, string value) {
			if (key == "extra-arguments") {
				extra_arguments = value;
				return true;
			} else if (key == "show-output") {
				bool flag;
				if (bool.try_parse(value, out flag) == true)
					show_output = flag;
				else
					show_output = null;
				return true;
			}
			return base.apply_property_value(key, value);
		}
	}
}
