using Gee;
using Catapult;
using Data.GameList;
using Data.Platforms;

public class NativePlatform : Platform
{
	public const string ENTITY_ID = "native_platform";
	construct {
		name = "Pandora";
		categories = new ArrayList<NativePlatformCategory>();
	}

	public Gee.List<NativePlatformCategory> categories { get; set; }

	protected override GameListProvider get_provider() {
		return new PndList();
	}

	// yaml
	protected override string generate_id() { return ENTITY_ID; }
	protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
		var mapping = new Yaml.MappingNode();
		builder.add_mapping_values(mapping, "categories", categories);
		return mapping;
	}
	protected override bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
		var mapping = node as Yaml.MappingNode;
		if (mapping != null) {
			parser.populate_object(mapping, this);
			return true;
		}
		return false;
	}
}
