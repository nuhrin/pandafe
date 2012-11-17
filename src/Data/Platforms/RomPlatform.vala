using Gee;
using Catapult;
using Data.GameList;
using Data.Programs;
using Fields;
using Menus;
using Menus.Fields;

namespace Data.Platforms
{
	public class RomPlatform : Platform
	{
		public RomPlatform() {
			base(PlatformType.ROM);
			programs = new ArrayList<Program>();
			program_settings = new PlatformProgramSettingsMap();
		}
		
		public string rom_folder_root { get; set; }
		public string rom_file_extensions { get; set; }

		public Gee.List<Program> programs { get; set; }
		public Program default_program { get; set; }
		public PlatformProgramSettingsMap program_settings { get; set; }
		
		public override bool supports_game_settings { get { return (programs.size > 0); } }
		public override Program? get_program(string? program_id=null) {
			if (program_id == null || (default_program != null && default_program.app_id == program_id))
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

		protected override GameListProvider create_provider() {
			return new RomList(this, name, rom_folder_root ?? "", rom_file_extensions);
		}

		// yaml		
		protected override bool yaml_use_default_for_property(string property) {
			return (property != "default-program");
		}
		protected override void build_yaml_additional(Yaml.MappingNode mapping, Yaml.NodeBuilder builder) { 
			if (programs.size > 1) {
				string default_program_id = (default_program != null) ? default_program.app_id : null;
				mapping.set_scalar("default-program", new Yaml.ScalarNode(default_program_id));
			}
		}
		protected override void apply_yaml_additional(Yaml.MappingNode mapping, Yaml.NodeParser parser) { 
			var default_program_node = mapping.get_scalar("default-program") as Yaml.ScalarNode;
			if (default_program_node != null) {
				foreach(var program in programs) {
					if (program.app_id == default_program_node.value) {
						default_program = program;
					}
				}
			}
			if (default_program == null && programs.size > 0)
				default_program = programs[0];
		}
		
		// menu
		protected override void build_menu(MenuBuilder builder) {
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
		protected override void release_fields() {
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
}
