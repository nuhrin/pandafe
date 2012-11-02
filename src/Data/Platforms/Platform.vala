using Gee;
using Catapult;
using Data;
using Data.GameList;
using Data.Programs;
using Data.Platforms;
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
		program_settings = new PlatformProgramSettingsMap();
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
	public GameBrowserAppearance? appearance { get; set; }
	
	// properties for ROM platforms
	public string rom_folder_root { get; set; }
	public string rom_file_extensions { get; set; }

	public Gee.List<Program> programs { get; set; }
	public Program default_program { get; set; }
	public PlatformProgramSettingsMap program_settings { get; set; }

	public Program? get_program(string program_id) {
		if (default_program != null && default_program.app_id == program_id)
			return default_program;
			
		foreach(var program in programs) {
			if (program.app_id == program_id)
				return program;
		}
		
		return null;
	}
	public string get_program_arguments(Program program, ProgramSettings? settings=null) {
		var effective = new ProgramSettings();
		string extra_arguments = "";
		if (program_settings.has_key(program.app_id) == true) {
			var platform_settings = program_settings[program.app_id];
			effective.merge_override(platform_settings);
			extra_arguments = platform_settings.extra_arguments;
		} else {
			effective.merge_override(program.default_settings);
			extra_arguments = program.default_settings.extra_arguments;
		}
		if (settings != null)
			effective.merge_override(settings);
		
		return program.options.get_option_string_from_settings(effective, extra_arguments);
	}
	public uint get_program_clockspeed(Program program, ProgramSettings? settings=null) {
		uint clockspeed = 0;
		if (settings != null)
			clockspeed = settings.clockspeed;
		if (clockspeed == 0 && program_settings.has_key(program.app_id) == true)
			clockspeed = program_settings[program.app_id].clockspeed;				
		if (clockspeed == 0)
			clockspeed = program.default_settings.clockspeed;
		if (clockspeed == 0) {
			var app = program.get_app();
			if (app != null)
				clockspeed = app.clockspeed;
		}
		return clockspeed;
	}

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
	protected virtual GameListProvider create_provider() {
		return new RomList(this, name, rom_folder_root ?? "", rom_file_extensions);
	}

	// yaml
	protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
		var mapping = new Yaml.MappingNode();
		unowned ObjectClass klass = this.get_class();
	    var properties = klass.list_properties();
	    foreach(var prop in properties) {
			if (prop.name == "appearance") {
				if (appearance != null)
					builder.add_object_mapping(mapping, this, prop);
			}  else if (prop.name != "default-program")
				builder.add_object_mapping(mapping, this, prop);
		}
		if (programs.size > 1) {
			string default_program_id = (default_program != null) ? default_program.app_id : null;
			mapping.set_scalar("default-program", new Yaml.ScalarNode(null, null, default_program_id));
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
						if (program.app_id == default_program_value_node.value) {
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
	protected virtual void build_menu(MenuBuilder builder) {
		name_field = builder.add_string("name", "Name", null, this.name);
		name_field.required = true;
		//builder.add_enum("platform_type", "Type", null, this.platform_type);
		var folder_field = builder.add_folder("rom_folder_root", "Rom Folder Root", null, this.rom_folder_root);
		folder_field.required = true;
		
		var exts_field = builder.add_string("rom_file_extensions", "Rom File Extensions", null, this.rom_file_extensions);
		exts_field.required = true;
		
		programs_field = new ProgramListField("programs", "Programs", null, programs);
		programs_field.required = true;
		builder.add_field(programs_field);
		
		default_program_field = new ProgramSelectionField("default_program", "Default Program", null, programs, default_program);
		default_program_field.required = true;
		builder.add_field(default_program_field);
		
		program_settings_field = new PlatformProgramSettingsMapField("program_settings", "Program Settings", null, name, program_settings, programs);
		builder.add_field(program_settings_field);
		
//~ 		var appearance_field = new GameBrowserAppearanceField("appearance", "Appearance", null, name + " Appearance", appearance, Data.preferences().appearance);
//~ 		builder.add_field(appearance_field);

		initialize_fields();
	}
	void initialize_fields() {
		name_field.changed.connect(() => {
			program_settings_field.set_platform_name(name_field.value);
		});
		programs_field.changed.connect(() => {
			default_program_field.set_programs(programs_field.value);
			program_settings_field.set_programs(programs_field.value);
		});
	}
	protected virtual bool save_object(Menus.Menu menu) {
		string? error;
		if (Data.platforms().save_platform(this, generate_id(), out error, f=> menu.message("Scanning folder '%s'...".printf(f.unique_name()))) == false) {
			menu.error(error);
			return false;
		}
		return true;		
	}
	
	protected void release_fields() {
		name_field = null;
		programs_field = null;
		default_program_field = null;
		program_settings_field = null;
	}
	
	Menus.Fields.StringField name_field;
	ProgramListField programs_field;
	ProgramSelectionField default_program_field;
	PlatformProgramSettingsMapField program_settings_field;
	
}
