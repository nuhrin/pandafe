using Gee;
using Data.Programs;

namespace Data.GameList
{
	public class RomList : GameListProvider
	{
		const RegexCompileFlags REGEX_COMPILE_FLAGS = RegexCompileFlags.OPTIMIZE | RegexCompileFlags.CASELESS |
													  RegexCompileFlags.MULTILINE | RegexCompileFlags.NEWLINE_LF;
		const RegexMatchFlags REGEX_MATCH_FLAGS = RegexMatchFlags.NEWLINE_LF;
		string root_folder_name;
		string root_folder_path;
		Regex regex_file_extensions;

		public RomList(Platform platform, string name, string root_folder_path, string file_extensions) {
			base(platform);
			root_folder_name = name;
			this.root_folder_path = root_folder_path;
			regex_file_extensions = get_file_extensions_regex(file_extensions);
		}

		public override uint run_game(GameItem game) {			
			ProgramSettings? settings = null;
			var program = game.get_program(out settings);			

			if (program == null) {
				debug("No program found to run '%s'.", game.name);
				return -1;
			}

			return run_program_with_premount(program, settings, get_full_path(game));
		}

		public override string get_unique_id(IGameListNode node) {
			return get_relative_path(node);
		}

		protected override bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games) {
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
						var subfolder = new GameFolder(name.replace("_", " "), this, folder);
						folder_list.add(subfolder);
					}
				}
				folder_list.sort();
				child_folders = folder_list;
				child_games = get_game_items(folder, file_names);
				return true;
			}
			catch(Error e)
			{
				debug("Error while getting children of '%s': %s", get_full_path(folder), e.message);
			}
			child_folders = null;
			child_games = null;
			return false;
		}

		protected override GameFolder create_root_folder() { return new GameFolder.root(root_folder_name, this, root_folder_path); }


		string get_rom_display_name(string filename) {
			// strips "GoodRom" decorations as well as extension
			try {
				if (_regex_rom_display_name == null)
					_regex_rom_display_name = new Regex("""(^\d* ?- ?)|(\([\w \.]*\)|\[.*\]| *?)*\.\w*$""", RegexCompileFlags.OPTIMIZE);
				return _regex_rom_display_name.replace(filename.replace("_", " "), -1, 0, "");
			} catch (RegexError e) {
				debug("Regex error while generating rom display name: %s", e.message);
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
				debug("Regex error while generating rom display name: %s", e.message);
			}
			return filename.replace("_", " ");
		}
		static Regex _regex_rom_display_name;
		static Regex _regex_rom_full_name;

		string get_relative_path(IGameListNode node) {
			if (node.parent == null)
				return "";
			return get_relative_path_sb(node).str;
		}
		string get_full_path(IGameListNode node) {
			if (node.parent == null)
				return root_folder_path;
			var path = get_relative_path_sb(node);
			path.prepend_c(Path.DIR_SEPARATOR).prepend(root_folder_path);
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
					debug("Error during file extension matching: %s", e.message);
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
			games.sort();
			return games;
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
				debug("Error creating file extension regex: %s", e.message);
			}
			return null;
		}
	}
}
