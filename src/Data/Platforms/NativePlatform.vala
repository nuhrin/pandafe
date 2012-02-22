using Gee;
using Catapult;
using Data.GameList;
using Data.Platforms;
using Menus;
using Fields;

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
	
	// menu
	protected override void build_menu(MenuBuilder builder) {
		categories_field = new NativePlatformCategoryListField("categories", "Included Categories", 
			"If specified, only apps in these categories will be included." , categories);
		builder.add_field(categories_field);
	}
	protected override bool save_object(Menu menu) {
		if (Data.save_native_platform() == true) {
			menu.message("Scanning native platform...");
			get_provider().rescan();
		}
		return true;
	}
	
	NativePlatformCategoryListField categories_field;
}
