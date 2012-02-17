using Gee;
using Catapult;
using Data;
using Data.GameList;
using Fields;
using Menus;
using Menus.Fields;

public enum PlatformType {
	ROM,
	CUSTOM,
	NATIVE
}
public class Platform : NamedEntity, MenuObject
{
	construct {
		programs = new ArrayList<Program>();
	}
	public PlatformType platform_type {
		get {
			if (this.get_type() == typeof(NativePlatform))
				return PlatformType.NATIVE;
			return _platform_type;
		}
		set {
			if (value == PlatformType.NATIVE)
				error("Setting PlatformType.NATIVE is not valid.");
			_platform_type = value;
		}
	}
	PlatformType _platform_type;

	// properties for ROM platforms
	public string rom_folder_root { get; set; }
	public string rom_file_extensions { get; set; }

	public Gee.List<Program> programs { get; set; }
	public Program default_program { get; set; }

	public Program? get_program(string program_id) {
		if (default_program != null && default_program.app_id == program_id)
			return default_program;
			
		foreach(var program in programs) {
			if (program.app_id == program_id)
				return program;
		}
		
		return null;
	}

	public GameFolder get_root_folder() {
		ensure_provider();
		return _provider.root_folder;
	}

	public GameFolder? get_folder(string unique_id) {
		if (unique_id == null || unique_id == "")
			return null;

		return get_root_folder().get_descendant_folder(unique_id);
	}

	void ensure_provider() {
		if (_provider == null)
			_provider = get_provider();
	}
	GameListProvider _provider;
	protected virtual GameListProvider get_provider() {
		return new RomList(this, name, rom_folder_root, rom_file_extensions);
	}

	// yaml
	protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
		var mapping = new Yaml.MappingNode();
		unowned ObjectClass klass = this.get_class();
	    var properties = klass.list_properties();
	    foreach(var prop in properties) {
			if (prop.name != "default-program")
				builder.add_object_mapping(mapping, this, prop);
		}
		if (programs.size > 1) {
			string default_program_name = (default_program != null) ? default_program.name : null;
			mapping.set_scalar("default-program", new Yaml.ScalarNode(null, null, default_program_name));
		}
		return mapping;
	}
	protected override bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
		var mapping = node as Yaml.MappingNode;
		if (mapping != null) {
			Yaml.ScalarNode default_program_key_node = null;
			foreach(var key_node in mapping.scalar_keys()) {
				if (key_node.value != "default-program")
					parser.populate_object_property(mapping, key_node, this);
				else
					default_program_key_node = key_node;
			}
			if (default_program_key_node != null) {
				var default_program_value_node = mapping[default_program_key_node] as Yaml.ScalarNode;
				if (default_program_value_node != null) {
					foreach(var program in programs) {
						if (program.name == default_program_value_node.value) {
							default_program = program;
						}
					}
				}
			}
			if (default_program == null && programs.size > 0)
				default_program = programs[0];
			return true;
		}
		return false;
	}

	// menu
	protected void build_menu(MenuBuilder builder) {
		name_field = builder.add_string("name", "Name", null, this.name);
		builder.add_enum("platform_type", "Type", null, this.platform_type);
		builder.add_folder("rom_folder_root", "Rom Folder Root", null, this.rom_folder_root);
		builder.add_string("rom_file_extensions", "Rom File Extensions", null, this.rom_file_extensions);
		
		programs_field = new ProgramListField("programs", "Programs", null, programs);
		builder.add_field(programs_field);
		
		default_program_field = new ProgramSelectionField("default_program", "Default Program", null, programs, default_program);
		builder.add_field(default_program_field);
		
		initialize_fields();
	}
	void initialize_fields() {
		programs_field.changed.connect(() => default_program_field.set_programs(programs_field.value));
	}
	protected bool save_object(Menu menu) {
		DataInterface di = Data.data_interface();		
		if (name_field.has_changes()) {
			string id = this.id ?? generate_id();			
			try {
				Platform? existing = di.load<Platform>(id);
				if (existing != null) {
					menu.error("Id '%s' conflicts with Platform '%s'.".printf(id, existing.name));
					return false;
				}
			} catch {
			}
		}
		try {
			menu.message("Saving platform '%s'...".printf(name));
			di.save(this);
			ensure_folders_on_update(menu);
			Data.flush_platforms();
			return true;
		}		
		catch(Error e) {
			menu.error(e.message);
			return false;
		}		
	}
	void ensure_folders_on_update(Menu menu) {
//~ 		var existing_id = get_root_folder().unique_id();
		_provider = null;
		menu.message("Scanning platform folders...");
		var new_root = get_root_folder();
		new_root.rescan_children(true);
//~ 		if (new_root.unique_id() != existing_id) {
//~ 			
//~ 		}
	}
	
	protected void release_fields() {
		name_field = null;
		programs_field = null;
		default_program_field = null;
	}
	
	Menus.Fields.StringField name_field;
	ProgramListField programs_field;
	ProgramSelectionField default_program_field;
	
}
