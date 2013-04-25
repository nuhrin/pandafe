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
		
		// game launching
		public override SpawningResult run_game(GameItem game) {
			var game_settings = Data.get_game_settings(game);
			
			var program = get_program_from_game_settings(game_settings);
			if (program == null)				
				return new SpawningResult.error("No program found to run '%s'.".printf(game.name));			
			
			ProgramSettings? settings = null;
			if (game_settings != null && game_settings.program_settings.has_key(program.app_id) == true)
				settings = game_settings.program_settings[program.app_id];						
			
			return Spawning.spawn_program(program, true, settings, get_full_path(game));
		}
		public override Program? get_program_for_game(GameItem game) {
			return get_program_from_game_settings(Data.get_game_settings(game));
		}
		Program? get_program_from_game_settings(GameSettings? game_settings) {
			Program? program = null;
			if (game_settings != null && game_settings.selected_program_id != null) {
				program = get_program(game_settings.selected_program_id) ?? default_program;
			} else {
				program = default_program;
			}
			return program;
		}
		public override Program? get_program(string? program_id=null) {
			if (program_id == null || (default_program != null && default_program.app_id == program_id))
				return default_program;
				
			foreach(var program in programs) {
				if (program.app_id == program_id)
					return program;
			}
			
			return null;
		}
		public override bool supports_game_settings { get { return (programs.size > 0); } }
		
		// runtime data
		protected override void initialize_runtime_data() {
			regex_file_extensions = get_file_extensions_regex(rom_file_extensions);
		}		
		Regex? get_file_extensions_regex(string file_extensions) {
			var parts = file_extensions.split_set(" .;,");
			var exts = new ArrayList<string>();
			foreach(var part in parts) {
				part = part.strip();
				if (part != "")
					exts.add(part);
			}
			if (exts.size == 0)
				return null;

			try {
				if (exts.size == 1)
					return new Regex("\\.%s$".printf(exts[0]), REGEX_COMPILE_FLAGS, REGEX_MATCH_FLAGS);

				var sb = new StringBuilder("\\.(");
				bool have_first = false;
				foreach(var ext in exts) {
					if (have_first == true) {
						sb.append("|");
						sb.append(ext);
					} else {
						sb.append(ext);
						have_first = true;
					}
				}
				sb.append(")$");
				return new Regex(sb.str, REGEX_COMPILE_FLAGS, REGEX_MATCH_FLAGS);
			} catch(RegexError e) {
				warning("Error creating file extension regex: %s", e.message);
			}
			return null;
		}
		Regex regex_file_extensions;
		const RegexMatchFlags REGEX_MATCH_FLAGS = RegexMatchFlags.NEWLINE_LF;		
		const RegexCompileFlags REGEX_COMPILE_FLAGS = RegexCompileFlags.OPTIMIZE | RegexCompileFlags.CASELESS |
													  RegexCompileFlags.MULTILINE | RegexCompileFlags.NEWLINE_LF;
		
		
		// game list
		public override GameFolder get_root_folder() { return new GameFolder.root(this.name, this, rom_folder_root); }
		public override string get_nearest_folder_path(string folder_path) {
			if (folder_path == null || rom_folder_root == null)
				return "";
			var checked_path = folder_path.strip();
			while(checked_path != "" && FileUtils.test(Path.build_filename(rom_folder_root, checked_path), FileTest.IS_DIR) == false) {
				int last_separator_index = folder_path.last_index_of(Path.DIR_SEPARATOR_S);
				if (last_separator_index == -1) {
					folder_path = "";
					continue;
				}
				checked_path = checked_path.substring(0, last_separator_index);
			}
			return checked_path;			
		}
		public override GameFolder? get_folder(string unique_name) {
			if (unique_name == null || unique_name == "" || FileUtils.test(Path.build_filename(rom_folder_root, unique_name), FileTest.IS_DIR) == false)
				return null;
			
			string[] parts = unique_name.strip().split("/");
			if (parts.length == 0)
				return null;
		
			var folder = get_root_folder();
			foreach(var part in parts)
				folder = new GameFolder(part, this, folder);
				
			return folder;			
		}		
		public override string get_unique_node_name(IGameListNode node) { return get_relative_path(node); }
		public override string get_unique_node_id(IGameListNode node) { return get_full_path(node); }
		public override string get_folder_display_name(GameFolder folder) { return folder.name.replace("_", " "); }
		public override string get_unique_folder_display_name(GameFolder folder) { return get_unique_node_name(folder).replace("_", " "); }
		public override string get_folder_display_path(string? folder_path) { 
			if (folder_path == null)
				return "";
			return folder_path.replace("_", " "); 
		}
		
		protected override bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games) {
			ensure_runtime_data();
			child_folders = null;
			child_games = null;
			if (folder.parent == null) {
				if (rom_folder_root == null || FileUtils.test(rom_folder_root, FileTest.IS_DIR) == false)
					return false; // avoid scanning platforms that have not specified rom path
			}
			var folder_list = new ArrayList<GameFolder>();
			var file_names = new ArrayList<string>();
			try {
				var directory = File.new_for_path(get_full_path(folder));
				var enumerator = directory.enumerate_children("standard::*", FileQueryInfoFlags.NONE);
				FileInfo file_info;
				while ((file_info = enumerator.next_file ()) != null) {
					var type = file_info.get_file_type();
					var name = file_info.get_name();
					if (name.has_prefix(".") == true)
						continue;
					if (type == FileType.REGULAR) {
						file_names.add(name);
					} else if (type == FileType.DIRECTORY) {
						var subfolder = new GameFolder(name, this, folder);
						folder_list.add(subfolder);
					}
				}
				folder_list.sort(IGameListNode.compare);
				child_folders = folder_list;
				child_games = get_game_items(folder, file_names);
				return true;
			}
			catch(Error e)
			{
				//warning("Error while getting children of '%s': %s", get_full_path(folder), e.message);
			}
			return false;
		}

		string get_relative_path(IGameListNode node) {
			if (node.parent == null)
				return "";
			return get_relative_path_sb(node).str;
		}
		string get_full_path(IGameListNode node) {
			if (node.parent == null)
				return rom_folder_root;
			var path = get_relative_path_sb(node);
			path.prepend_c(Path.DIR_SEPARATOR).prepend(rom_folder_root);
			return path.str;
		}
		StringBuilder get_relative_path_sb(IGameListNode node) {
			var path = new StringBuilder(node.id);
			IGameListNode current = node.parent;
			while (current.parent != null) {
				path.prepend_c(Path.DIR_SEPARATOR).prepend(current.id);
				current = current.parent;
			}
			return path;
		}

		ArrayList<GameItem> get_game_items(GameFolder folder, ArrayList<string> file_names) {
			if (regex_file_extensions == null)
				return get_matched_game_items(folder, file_names);

			var sb = new StringBuilder();
			var item_positions = new int[file_names.size];
			for(int index=0; index<file_names.size; index++) {
				item_positions[index] = (int)sb.len;
				sb.append("%s\n".printf(file_names[index]));
			}
			var items_str = sb.str;
			var matched_names = new ArrayList<string>();

			int matched_item_index = 0;
			int last_item_index = file_names.size - 1;
			MatchInfo match_info;
			regex_file_extensions.match(items_str, 0, out match_info);
			while((matched_item_index < file_names.size) && match_info.matches()) {
				int match_position;
				if (match_info.fetch_pos(0, out match_position, null) == true) {
					if (match_position >= item_positions[matched_item_index]) {
						while(match_position >= item_positions[matched_item_index + 1] && (matched_item_index < last_item_index))
							matched_item_index++;

						matched_names.add(file_names[matched_item_index]);
						matched_item_index++;
					}
				}
				try {
					match_info.next();
				} catch(RegexError e) {
					warning("Error during file extension matching: %s", e.message);
					break;
				}
			}

			return get_matched_game_items(folder, matched_names);
		}
		ArrayList<GameItem> get_matched_game_items(GameFolder folder, ArrayList<string> file_names) {
			var games = new ArrayList<GameItem>();
			var displayname_game_hash = new HashMap<string, GameItem?>();
			foreach(var name in file_names) {
				GameItem game = null;
				var display_name = get_rom_display_name(name);
				if (display_name == "")
					continue;
				if (displayname_game_hash.has_key(display_name) == true) {
					var old_game_item = displayname_game_hash[display_name];
					if (old_game_item != null) {
						GameItem.set_full_name(old_game_item, get_rom_full_name(old_game_item.id));
						displayname_game_hash[display_name] = null;
					}
					game = GameItem.create(display_name, this, folder, name, get_rom_full_name(name));
				} else {
					game = GameItem.create(display_name, this, folder, name);
					displayname_game_hash[display_name] = game;
				}
				games.add(game);
			}
			games.sort(IGameListNode.compare);
			return games;
		}

		string get_rom_display_name(string filename) {
			// strips "GoodRom" decorations as well as extension
			try {
				if (_regex_rom_display_name == null)
					_regex_rom_display_name = new Regex("""(^\d* ?- ?)|(\([\w \.]*\)|\[.*\]| *?)*\.\w*$""", RegexCompileFlags.OPTIMIZE);
				return _regex_rom_display_name.replace(filename.replace("_", " "), -1, 0, "");
			} catch (RegexError e) {
				warning("Regex error while generating rom display name: %s", e.message);
			}
			return filename.replace("_", " ");
		}
		string get_rom_full_name(string filename) {
			// strips just extension
			try {
				if (_regex_rom_full_name == null)
					_regex_rom_full_name = new Regex(""" *?\.\w*$""", RegexCompileFlags.OPTIMIZE);
				return _regex_rom_full_name.replace(filename.replace("_", " "), -1, 0, "");
			} catch (RegexError e) {
				warning("Regex error while generating rom display name: %s", e.message);
			}
			return filename.replace("_", " ");
		}
		static Regex _regex_rom_display_name;
		static Regex _regex_rom_full_name;


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
