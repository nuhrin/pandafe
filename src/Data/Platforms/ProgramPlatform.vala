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
		
		public override bool supports_game_settings { get { return (program != null); } }
		public override Program? get_program(string? program_id=null) { return program; }		
		
		protected override GameListProvider create_provider() {
			return new ProgramGameList(this);
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
