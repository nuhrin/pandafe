using Gee;

namespace Data.GameList
{
	public class RomList : GameListProvider
	{
		PatternSpecSet patterns;
		string root_folder_name;
		string root_folder_path;

		public RomList(Platform platform, string name, string root_folder_path, string filespec) {
			base(platform);
			root_folder_name = name;
			this.root_folder_path = root_folder_path;
			patterns = new PatternSpecSet(filespec);
		}

		public override uint run_game(GameItem game) {
			var program = platform.default_program;
			if (program == null) {
				debug("No program found to run '%s'.", game.name);
				return -1;
			}

			return run_program_with_premount(program, null, get_full_path(game));
		}

		public override string get_unique_id(GameListNode node) {
			return get_relative_path(node);
		}

		public override bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games) {
			var folder_list = new ArrayList<GameFolder>();
			var game_list = new ArrayList<GameItem>();
			try {
				var directory = File.new_for_path(get_full_path(folder));
				var enumerator = directory.enumerate_children("standard::*", FileQueryInfoFlags.NONE);
				FileInfo file_info;
				while ((file_info = enumerator.next_file ()) != null) {
					var type = file_info.get_file_type();
					var name = file_info.get_name();
					if (type == FileType.REGULAR && patterns.match_string(name)) {
						var game = new GameItem(name, this, folder);
						game_list.add(game);
					} else if (type == FileType.DIRECTORY) {
						var subfolder = new GameFolder(name, this, folder);
						folder_list.add(subfolder);
					}
				}
				child_folders = folder_list;
				child_games = game_list;
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

		string get_relative_path(GameListNode node) {
			if (node.parent == null)
				return "";
			return get_relative_path_sb(node).str;
		}
		string get_full_path(GameListNode node) {
			if (node.parent == null)
				return root_folder_path;
			var path = get_relative_path_sb(node);
			path.prepend_c(Path.DIR_SEPARATOR).prepend(root_folder_path);
			return path.str;
		}
		StringBuilder get_relative_path_sb(GameListNode node) {
			var path = new StringBuilder(node.id);
			GameListNode current = node.parent;
			while (current.parent != null) {
				path.prepend_c(Path.DIR_SEPARATOR).prepend(current.id);
				current = current.parent;
			}
			return path;
		}

		class PatternSpecSet
		{
			PatternSpec[] patterns;
			public PatternSpecSet(string spec) {
				var spec_set = spec.split_set(";, ");
				patterns = new PatternSpec[spec_set.length];
				for(int index=0;index<spec_set.length;index++) {
					patterns[index] = new PatternSpec(spec_set[index]);
				}
			}
//~ 			public bool match (uint string_length, string str, string? str_reversed)
//~ 			{
//~ 				for(int index=0;index<patterns.length;index++) {
//~ 					if (patterns[index].match(string_length, str, str_reversed) == true)
//~ 						return true;
//~ 				}
//~ 				return false;
//~ 			}
			public bool match_string (string str) {
				for(int index=0;index<patterns.length;index++) {
					if (patterns[index].match_string(str) == true)
						return true;
				}
				return false;
			}
		}
	}
}
