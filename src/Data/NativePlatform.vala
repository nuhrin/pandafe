using Gee;
using Catapult;
using Catapult.Gui;
using Data;
using Data.GameList;

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
		builder.add_mapping(mapping, "categories", categories);
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

	// gui
	protected override void populate_field_container(FieldContainer container) {

	}

}