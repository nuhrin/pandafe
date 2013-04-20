/* ProgramPlatform.vala
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
	public class ProgramPlatform : Platform
	{
		public const string GET_GAMES_SCRIPT_NAME = "pandafe_get-games.sh";
		
		public ProgramPlatform() {
			base(PlatformType.PROGRAM);
		}		
		public Program program { get; set; }		
		public string get_games_script { get; set; }
		
		// game launching
		public override SpawningResult run_game(GameItem game) {
			var game_settings = Data.get_game_settings(game);
			
			if (program == null)				
				return new SpawningResult.error("No program found to run '%s'.".printf(game.name));			
			
			ProgramSettings? settings = null;
			if (game_settings != null && game_settings.program_settings.has_key(program.app_id) == true)
				settings = game_settings.program_settings[program.app_id];
			
			return Spawning.spawn_program(program, true, settings, game.id);
		}
		public override Program? get_program_for_game(GameItem game) { return program; }
		public override Program? get_program(string? program_id=null) { return program; }				
		public override bool supports_game_settings { get { return (program != null); } }
		
		// runtime data
		protected override void initialize_runtime_data() { }
		
		// game list
		public override GameFolder get_root_folder() {
			if (program != null)
				return new GameFolder.root(program.name, this, "");
			return new GameFolder.root("unknown-program", this, "");				
		}
		public override string get_unique_node_name(IGameListNode node) { return node.id; }
		protected override bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games) {
			child_folders = null;
			child_games = null;
			if (program == null) 
				return false;
			var app = program.get_app();
			if (app == null)
				return false;
				
			// mount pnd, if necessary
			var mountset = Data.pnd_mountset();
			bool is_new_mount = (mountset.is_mounted(app.package_id) == false && 
								 mountset.mount(app.id, app.package_id) == true);
			var mounted_path = mountset.get_mounted_path(app.package_id);
			if (mounted_path == null && is_new_mount == true) {
				mountset.unmount(app.package_id);
				return false;
			}
	
			// run get games script and unmount pnd if appropriate
			var result = Spawning.spawn_program(program, false, null, null, ProgramPlatform.GET_GAMES_SCRIPT_NAME, get_games_script);
			
			// show any error
			var successful = (result.success == true || (result.exit_status != 0 && program.expected_exit_code == result.exit_status));
			if (successful == false) {
				result.show_result_dialog("Error running Get Games script for " + program.name);
				return false;
			}
			
			// parse output of script into expected sequence node
			Yaml.SequenceNode sequence = null;
			try {
				var sb = new StringBuilder();
				sb.append("---\n");
				sb.append((result.standard_output ?? "").strip());
				var reader = new Yaml.DocumentReader.from_string(sb.str);
				sequence = reader.read_document().root as Yaml.SequenceNode;
			} catch(Error e) {
				warning("Error parsing get-games script output: %s", e.message);
			}
			if (sequence == null)
				return false;
			
			// parse game items from sequence
			var parser = new Yaml.NodeParser();				
			var parsed_games = new ArrayList<GameItem>();
			foreach(var game_node in sequence.items()) {
				GameItem? parsed_game = GameItem.from_yaml_node(game_node, parser);
				if (parsed_game != null) {
					GameItem.set_platform(parsed_game, this);
					GameItem.set_parent(parsed_game, folder);
					parsed_games.add(parsed_game);
				}
			}			
			if (parsed_games.size > 0) {
				parsed_games.sort(IGameListNode.compare);
				child_games = parsed_games;
				return true;
			}
			
			return false;		
		}
		
		// menu
		protected override void build_menu(MenuBuilder builder) {
			name_field = builder.add_string("name", "Name", null, this.name);
			name_field.required = true;
			
			program_field = new ProgramField("program", "Program", null, program);
			program_field.required = true;
			builder.add_field(program_field);
			
			get_games_script_field = new CustomCommandField("get_games_script", "Get Games Script", "Shell script to retrieve game items for the program", 
				program, get_games_script, "Get Games Script for ");
			get_games_script_field.mime_type = "text/plain";
			get_games_script_field.open_file_title = "Choose text file...";
			get_games_script_field.set_script_name(GET_GAMES_SCRIPT_NAME);
			get_games_script_field.is_secondary_command = true;
			get_games_script_field.required = true;
			builder.add_field(get_games_script_field);

						
	//~ 		var appearance_field = new GameBrowserAppearanceField("appearance", "Appearance", null, name + " Appearance", appearance, Data.preferences().appearance);
	//~ 		builder.add_field(appearance_field);

			initialize_fields();
		}
		void initialize_fields() {
			program_field.changed.connect(() => {
				if (program_field.value != null) {
					var app = program_field.value.get_app();
					if (app != null) {
						get_games_script_field.app = app;
						name_field.value = app.title;
					}
				}
			});
			name_field.changed.connect(() => {
				get_games_script_field.set_program_name(name_field.value);				
			});
		}
		protected override void release_fields() {
			name_field = null;
			program_field = null;
			get_games_script_field = null;
		}
		
		Menus.Fields.StringField name_field;
		ProgramField program_field;
		CustomCommandField get_games_script_field;
	}
}
