/* RomPlatform.vala
 * 
 * Copyright (C) 2012 nuhrin
 * 
 * This file is part of Pandafe.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *      nuhrin <nuhrin@oceanic.to>
 */

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
		}
		
		public string rom_folder_root { get; set; }
		public string rom_file_extensions { get; set; }

		public Gee.List<Program> programs { get; set; }
		public Program default_program { get; set; }
		
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
			
	//~ 		var appearance_field = new GameBrowserAppearanceField("appearance", "Appearance", null, name + " Appearance", appearance, Data.preferences().appearance);
	//~ 		builder.add_field(appearance_field);

			initialize_fields();
		}
		void initialize_fields() {
			programs_field.changed.connect(() => {
				default_program_field.set_programs(programs_field.value);
			});
		}
		protected override void release_fields() {
			name_field = null;
			programs_field = null;
			default_program_field = null;
		}
		
		Menus.Fields.StringField name_field;
		ProgramListField programs_field;
		ProgramSelectionField default_program_field;
	}
}
