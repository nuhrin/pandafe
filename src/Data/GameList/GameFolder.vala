/* GameFolder.vala
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

namespace Data.GameList
{
	public class GameFolder : GameListNode, IGameListNode
	{
		public const string CACHE_FOLDER_ROOT = "GameListCache";
		const string CACHE_FILENAME = "children";
		
		string? _id;
		string _name;
		Platform _platform;
		GameFolder? _parent;
		ArrayList<GameFolder> _child_folders;
		ArrayList<GameItem> _child_games;
		bool children_loaded = false;

		public GameFolder(string name, Platform platform, GameFolder? parent) {
			_name = name;
			_platform = platform;
			_parent = parent;
		}
		public GameFolder.root(string name, Platform platform, string? id=null) {
			_name = name;
			_platform = platform;
			_id = id;
		}

		protected Platform platform { get { return _platform; } }
		public GameFolder? parent { get { return _parent; } }

		public string id { get { return (_id != null) ? _id : _name; } }
		public string name { get { return _name; } }
		public string full_name { get { return _name; } }
		
		public string display_name() { return platform.get_folder_display_name(this); }
		public string unique_display_name() { return platform.get_unique_folder_display_name(this); }

		public int child_count() {
			ensure_children();
			return ((_child_folders != null) ? _child_folders.size : 0) + ((_child_games != null) ? _child_games.size : 0);
		}

		public int index_of(IGameListNode child_node) {
			ensure_children();
			int index=0;
			if (_child_folders != null || _child_folders.size > 0) {
				if (child_node is GameFolder) {				
					foreach(var folder in _child_folders) {
						if (folder.id == child_node.id)
							return index;
						index++;
					}
					return -1;
				} else {
					index = _child_folders.size;
				}
			}
			if (child_node is GameItem && _child_games != null && _child_games.size > 0) {
				foreach(var game in _child_games) {
					if (game.id  == child_node.id)
						return index;
					index++;
				}				
			}
			return -1;
		}

		public Enumerable<IGameListNode> children() {
			return child_folders().concat(child_games());
		}

		public Enumerable<GameFolder> child_folders() {
			ensure_children();
			if (_child_folders == null)
				return Enumerable.empty<GameFolder>();
			return new Enumerable<GameFolder>(_child_folders);
		}
		public Enumerable<GameItem> child_games() {
			ensure_children();
			if (_child_games == null)
				return Enumerable.empty<GameItem>();
			return new Enumerable<GameItem>(_child_games);
		}

		public Enumerable<GameFolder> all_subfolders() {
			var all = child_folders();

			foreach(var folder in child_folders())
				all = all.concat(folder.all_subfolders());

			return all;
		}
		public GameFolder? get_descendant_folder(string unique_name) {
			foreach(var folder in all_subfolders()) {
				if (folder.unique_name() == unique_name)
					return folder;
			}
			return null;
		}
		public GameFolder? get_descendant_folder_by_id(string unique_id) {
			foreach(var folder in all_subfolders()) {
				if (folder.unique_id() == unique_id)
					return folder;
			}
			return null;
		}

		public Enumerable<GameItem> all_games() {
			var all = Enumerable.empty<GameItem>();

			foreach(var folder in child_folders())
				all = all.concat(folder.all_games());

			return all.concat(child_games());
		}

		public signal void rescanned();
		public void rescan_children(owned ForEachFunc<GameFolder>? pre_scan_action=null) {
			scan_children(true, (owned)pre_scan_action);
			Data.all_games().update_cache_for_folder(this);
		}
		public void update_cache() {
			// attempt to save
			try {
				var sb = new StringBuilder();
				
				if (_child_folders != null) {
					foreach(var subfolder in _child_folders)
						sb.append("f||%s\n".printf(subfolder.name));
				}
				if (_child_games != null) {
					foreach(var game in _child_games)
						game.add_cache_line(sb, null);
				}

				string folder_path = Path.build_filename(RuntimeEnvironment.user_config_dir(), get_cache_folder());
				if (FileUtils.test(folder_path, FileTest.IS_DIR) == false) {
					if (File.new_for_path(folder_path).make_directory_with_parents() == false)
						throw new FileError.FAILED("unable to create cache folder");
				}
				if (FileUtils.set_contents(Path.build_filename(folder_path, CACHE_FILENAME), sb.str) == false)
					throw new FileError.FAILED("unspecified error");
			} catch(Error e) {
				warning("Error saving cache for folder '%s': %s", get_cache_folder(), e.message);
			}
		}

		void ensure_children() {
			if (children_loaded == true)
				return;
			
			if (load_children_cache() == false)
				scan_children(false);
		}
		bool load_children_cache() {
			var folder_path = get_cache_folder();
			try {
				string contents;
				if (FileUtils.get_contents(Path.build_filename(RuntimeEnvironment.user_config_dir(), folder_path, CACHE_FILENAME), out contents) == false)
					throw new FileError.FAILED("unspecified error");
					
				var lines = contents.strip().split("\n");

				var subfolders = new ArrayList<GameFolder>();
				var games = new ArrayList<GameItem>();
				
				foreach(var line in lines) {
					var parts = line.split("||");
					if (parts.length < 2 || parts[0].length != 1)
						throw new FileError.FAILED("invalid cache file format: %s".printf(line));
					var name = parts[1];
					if (parts[0] == "f") {
						// folder
						subfolders.add(new GameFolder(name, platform, this));
						continue;
					}
					
					if (parts[0] != "g" || parts.length != 4)
						throw new FileError.FAILED("invalid game format");					
					
					// game
					var id = parts[2];
					var full_name = parts[3];
					if (id == "")
						id = null;
					if (full_name == "")
						full_name = null;
					games.add(GameItem.create(name, platform, this, id, full_name));
				}
							
				_child_folders =  subfolders;				
				_child_games = games;
				
				children_loaded = true;
				return true;
			} catch(Error e) {
				//warning("Error loading cache for folder '%s': %s", folder_path, e.message);
				return false;
			}
		}
		void scan_children(bool recursive, owned ForEachFunc<GameFolder>? pre_scan_action=null) {
			if (pre_scan_action != null)
				pre_scan_action(this);
			platform.folder_scanned(this);
			
			ArrayList<GameItem> games = null;
			platform.get_children(this, out _child_folders, out games);

			// note: any transient GameItem settings (only in cache) need to be remapped here to the newly scanned items
			_child_games = games;

			update_cache();
			children_loaded = true;
			rescanned();
			
			if (recursive == true && _child_folders != null) {
				foreach(var subfolder in _child_folders)
					subfolder.scan_children(true, (owned)pre_scan_action);
			}
		}

		string get_cache_folder() {
			if (_cache_folder == null) {
				_cache_folder = (_parent == null)
					? Path.build_filename(CACHE_FOLDER_ROOT, platform.id)
					: Path.build_filename(_parent.get_cache_folder(), name);
			}
			return _cache_folder;
		}
		string _cache_folder;
	}
}
