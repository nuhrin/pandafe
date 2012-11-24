using Gee;
using Catapult;
using Data;
using Data.GameList;
using Data.Programs;
using Data.Platforms;
using Menus;

public enum PlatformType 
{
	NONE,
	ROM,
	PROGRAM,
	NATIVE
}

public abstract class Platform : NamedEntity, MenuObject
{
	protected Platform(PlatformType platform_type) {
		this.platform_type = platform_type;
	}
	public PlatformType platform_type { get; private set; }
	public GameBrowserAppearance? appearance { get; set; }
	
	public string platform_type_description() {
		if (platform_type == PlatformType.PROGRAM)
			return "Program Platform";
		else if (platform_type == PlatformType.NATIVE)
			return "Native Platform";
		return "Platform";
	}
	public abstract bool supports_game_settings { get; }
	public abstract Program? get_program(string? program_id=null);
	public GameFolder get_root_folder() { return provider.root_folder; }
	public GameFolder? get_folder(string unique_name) {
		if (unique_name == null || unique_name == "")
			return null;

		return get_root_folder().get_descendant_folder(unique_name);
	}
	public GameFolder? get_folder_by_id(string unique_id) {
		if (unique_id == null || unique_id == "")
			return null;
		
		var root_folder = get_root_folder();
		if (unique_id == root_folder.unique_id())
			return root_folder;

		return root_folder.get_descendant_folder_by_id(unique_id);
	}
	
	public void rebuild_folders(owned ForEachFunc<GameFolder>? pre_scan_action=null) {
		reset_provider();
		rescan((owned)pre_scan_action);
	}
	public void rescan(owned ForEachFunc<GameFolder>? pre_scan_action=null) {
		provider.rescan((owned)pre_scan_action);
		rescanned();
	}
	public signal void rescanned();
	public signal void folder_scanned(GameFolder folder);
	
	protected GameListProvider provider {
		get {
			if (_provider == null)
				_provider = create_provider();
			return _provider;
		}
	}	
	GameListProvider _provider;	
	protected void reset_provider() { _provider = null; }
	protected abstract GameListProvider create_provider();

	// yaml
	protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
		var mapping = new Yaml.MappingNode();
		unowned ObjectClass klass = this.get_class();
	    var properties = klass.list_properties();
	    
	    builder.add_item_to_mapping("name", name, mapping);
	    builder.add_item_to_mapping("platform-type", platform_type, mapping);
	    if (appearance != null)
			builder.add_item_to_mapping("appearance", appearance, mapping);
	    
	    foreach(var prop in properties) {
			if (prop.name == "appearance" || prop.name == "name" || yaml_use_default_for_property(prop.name) == false)
				continue;
			
			builder.add_object_property_to_mapping(this, prop.name, mapping);
		}
		
		build_yaml_additional(mapping, builder);
		
		return mapping;
	}
	protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
		var mapping = node as Yaml.MappingNode;
		if (mapping == null)
			return;
			
		foreach(var key_node in mapping.scalar_keys()) {
			if (key_node.value == "platform-type" || yaml_use_default_for_property(key_node.value) == false)
				continue;
				
			parser.set_object_property(this, key_node.value, mapping[key_node]);				
		}
		
		apply_yaml_additional(mapping, parser);		
	}
	protected virtual bool yaml_use_default_for_property(string property) { return true; }
	protected virtual void build_yaml_additional(Yaml.MappingNode mapping, Yaml.NodeBuilder builder) { }
	protected virtual void apply_yaml_additional(Yaml.MappingNode mapping, Yaml.NodeParser parser) { }
	
	// menu
	protected abstract void build_menu(MenuBuilder builder);	
	protected virtual bool save_object(Menus.Menu menu) {
		string? error;
		if (Data.platforms().save_platform(this, generate_id(), out error, f=> menu.message("Scanning folder '%s'...".printf(f.unique_name()))) == false) {
			menu.error(error);
			return false;
		}
		return true;		
	}	
	protected virtual void release_fields() { }	
}
