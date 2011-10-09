using Gee;
using Catapult;
using Catapult.Gui;
using Catapult.Gui.Fields;
using Catapult.Gui.Fieldsets;
using Fields;
using Data;
using Data.GameList;

public enum PlatformType {
	ROM,
	CUSTOM,
	NATIVE
}
public class Platform : NamedEntity, GuiEntity
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

	public GameFolder get_root_folder() {
		ensure_provider();
		return _provider.root_folder;
	}

	public GameFolder? get_folder(string unique_id) {
		if (unique_id == null || unique_id == "")
			return null;

		var root = get_root_folder();
		foreach(var subfolder in root.all_subfolders()) {
			if (subfolder.unique_id() == unique_id)
				return subfolder;
		}
		return null;
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
			mapping.Mappings.set_scalar("default-program", new Yaml.ScalarNode(null, null, default_program_name));
		}
		return mapping;
	}
	protected override bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
		var mapping = node as Yaml.MappingNode;
		if (mapping != null) {
			Yaml.ScalarNode default_program_key_node = null;
			foreach(var key_node in mapping.Mappings.scalar_keys()) {
				if (key_node.Value != "default-program")
					parser.populate_object_property(mapping, key_node, this);
				else
					default_program_key_node = key_node;
			}
			if (default_program_key_node != null) {
				var default_program_value_node = mapping.Mappings[default_program_key_node] as Yaml.ScalarNode;
				if (default_program_value_node != null) {
					foreach(var program in programs) {
						if (program.name == default_program_value_node.Value) {
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

	// gui
	protected virtual void populate_field_container(FieldContainer container) {
		// add Platform frame
		var platform_frame = new FrameFieldset("PlatformFrame", "Platform");
		platform_frame.add_string("name", "_Name", this.name);
		platform_frame.add_enum("platform_type", "_Type", this.platform_type);
		rom_folder_root_field = new FolderField("rom_folder_root", "_Rom Folder Root", this.rom_folder_root);
		platform_frame.add_field(rom_folder_root_field);
		rom_filespec_field = platform_frame.add_string("rom_file_extensions", "Rom _File Extensions", this.rom_file_extensions);

		container.add_field(platform_frame);

		// add Programs frame
		var programs_frame = new FrameFieldset("ProgramsFrame", "Programs");
		programs_frame.data_interface = container.data_interface;

		programs_field = new ProgramListField(container.data_interface, "programs", null, programs);
		programs_frame.add_field(programs_field);

		default_program_field = new DefaultProgramField("default_program", "_Default Program", programs, default_program);
		programs_frame.add_field(default_program_field);

		container.add_field(programs_frame);

		initialize_fields();
	}
	void initialize_fields() {
		programs_field.changed.connect(() => default_program_field.set_programs(programs_field.get_items()));
	}

	ProgramListField programs_field;
	FolderField rom_folder_root_field;
	StringField rom_filespec_field;
	DefaultProgramField default_program_field;
}
