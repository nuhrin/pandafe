using Gee;
using Catapult;
using Data.GameList;
using Data.Platforms;
using Menus;
using Fields;

public class NativePlatform : Platform
{
	construct {
		name = "Pandora";
		categories = new ArrayList<NativePlatformCategory>();
	}

	public Gee.List<NativePlatformCategory> categories { get; set; }

	protected override GameListProvider create_provider() { return new PndList(); }

	// yaml
	protected override string generate_id() {
		assert_not_reached();
	}
	protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
		var mapping = new Yaml.MappingNode();
		if (appearance != null)
			mapping.set_scalar("appearance", builder.build_value(appearance));
		builder.add_item_to_mapping("categories", categories, mapping);
		return mapping;
	}
	protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
		parser.populate_object_properties_from_mapping(this, node as Yaml.MappingNode);
	}
	
	// menu
	protected override void build_menu(MenuBuilder builder) {
		var categories_field = new NativePlatformCategoryListField("categories", "Included Categories", 
			"If specified, only apps in these categories will be included." , categories);
		builder.add_field(categories_field);
		
//~ 		var appearance_field = new GameBrowserAppearanceField("appearance", "Appearance", null, name + " Appearance", appearance, Data.preferences().appearance);
//~ 		builder.add_field(appearance_field);
	}
	protected override bool save_object(Menus.Menu menu) {
		string? error;
		if (Data.platforms().save_native_platform(out error, f=> menu.message("Scanning category '%s'...".printf(f.unique_name()))) == false) {
			menu.error(error);
			return false;
		}
		return true;
	}	
}
