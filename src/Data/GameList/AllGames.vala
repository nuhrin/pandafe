/* AllGames.vala
 * 
 * Copyright (C) 2013 nuhrin
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
	public class AllGames
	{
		const string CACHE_FILENAME = "everything";
		public const string UNCATEGORIZED_CATEGORY_NAME = "(Uncategorized)";
	
		public Enumerable<GameItem> load() {
			Gee.List<GameItem> games;
			if (load_all_games_from_cache(out games) == true)
				return new Enumerable<GameItem>(games);
				
			return rebuild();
		}
		
		public Enumerable<string> get_root_category_names() {			
			if (_root_category_names != null)
				return new Enumerable<string>(_root_category_names);
				
			Gee.List<string> subcategories;
			Gee.List<GameItem> games;
			if (load_category_data(null, out subcategories, out games) == true) {
				_root_category_names = subcategories;
				return new Enumerable<string>(_root_category_names);
			}
			return Enumerable.empty<string>();
		}
		Gee.List<string> _root_category_names;
		
		public bool load_category_data(string? category_path, out Gee.List<string> subcategories, out Gee.List<GameItem> games) {
			if (load_category_from_cache(category_path, out subcategories, out games) == false) {
				rebuild();
				if (load_category_from_cache(category_path, out subcategories, out games) == false)
					return false;
			}
			return true;
		}
		
		public signal void cache_updated(string? new_selection_id);
		public void update_cache_for_folder(GameFolder folder, string? new_selection_id) {
			rebuild(new_selection_id);
		}
		
		Enumerable<GameItem> rebuild(string? new_selection_id=null) {
			var folder_data = Data.platforms().get_platform_folder_data();
			var platforms = (folder_data.folders.size > 0)
				? folder_data.get_all_platforms()
				: Data.platforms().get_all_platforms();
			
			var games = Enumerable.empty<GameItem>();
			foreach(var platform in platforms)
				games = games.concat(platform.all_games());
			
			var list = games.to_list();
			save_cache(list, new_selection_id);

			return new Enumerable<GameItem>(list);
		}
		
		bool load_all_games_from_cache(out Gee.List<GameItem> games) {
			games = null;
				
			try {
				var lines = load_cache_lines();
				if (lines.length == 0)
					return false;
				
				var hash = new HashMap<string,GameFolder>();
				var platform_provider = Data.platforms();
				games = new ArrayList<GameItem>();
				
				foreach(var line in lines) {
					var parts = line.split("||");
					if (parts.length < 3 || parts[0].length != 1)
						throw new FileError.FAILED("invalid cache file format: %s".printf(line));
					//print("%s\n", line);
					
					GameFolder folder = null;
					var key = parts[1];
					var name = parts[2];
					if (parts[0] == "f") {
						// folder
						if (key == "p") {
							var platform = (name == "pandora")
								? platform_provider.get_native_platform()
								: platform_provider.get_platform(name);
							if (platform == null)
								continue;
							folder = platform.get_root_folder();
							hash[hash.size.to_string()] = folder;
							continue;
						}
						if (hash.has_key(key) == false)
							continue; // parent folder not found (possibly not yet parsed?)
						var parent = hash[key];
						folder = new GameFolder(name, parent.platform, parent);
						hash[hash.size.to_string()] = folder;
						continue;
					}
					
					if (parts[0] != "g" || parts.length != 5)
						throw new FileError.FAILED("invalid game format");					
					if (hash.has_key(key) == false)
						continue; // folder not found for key
					
					// game
					folder = hash[key];
					var id = parts[3];
					var full_name = parts[4];
					if (id == "")
						id = null;
					if (full_name == "")
						full_name = null;
					games.add(GameItem.create(name, folder.platform, folder, id, full_name));
				}
				
				return true;
			} catch(Error e) {
				games = null;
			}
			return false;
		}
		bool load_category_from_cache(string? category_path, out Gee.List<string> subcategories, out Gee.List<GameItem> games) {
			subcategories = null;
			games = null;			
				
			try {
				var lines = load_cache_lines();
				if (lines.length == 0)
					return false;
			
				bool is_root_category = (category_path == null);
				bool is_uncategorized_category = (category_path == UNCATEGORIZED_CATEGORY_NAME);
				var folder_id_map = new HashMap<string,GameFolder>();
				var platform_provider = Data.platforms();
				var category_folder_set = new HashSet<GameFolder>();
				var subcategory_set = new HashSet<string>();
				games = new ArrayList<GameItem>();
				
				int folder_index = -1;
				foreach(var line in lines) {
					var parts = line.split("||");
					if (parts.length < 3 || parts[0].length != 1)
						throw new FileError.FAILED("invalid cache file format: %s".printf(line));
					//print("%s\n", line);
					
					GameFolder folder = null;
					var key = parts[1];
					var name = parts[2];
					if (parts[0] == "f") {
						folder_index++;	
						// folder
						if (key == "p") {
							var platform = (name == "pandora")
								? platform_provider.get_native_platform()
								: platform_provider.get_platform(name);
							if (platform == null)
								continue;
							folder = platform.get_root_folder();
							folder_id_map[folder_index.to_string()] = folder;
							if (platform.platform_type == PlatformType.PROGRAM) {
								if (is_root_category == true)
									subcategory_set.add(folder.display_name());
								else if (folder.display_name() == category_path)
									category_folder_set.add(folder);								
							} else if (is_uncategorized_category == true || is_root_category == true) {
								category_folder_set.add(folder);
							}
							continue;
						}
						if (folder_id_map.has_key(key) == false)
							continue; // parent folder not found (possibly not yet parsed?)

						if (is_uncategorized_category == true)
							continue; // just want platform folders
												
						var parent = folder_id_map[key];
						if (category_folder_set.contains(parent) == true) {
							folder = new GameFolder(name, parent.platform, parent);
							subcategory_set.add(folder.display_name());
							continue; // just want names for next folder depth
						}

						folder = new GameFolder(name, parent.platform, parent);
						folder_id_map[folder_index.to_string()] = folder;
						if (folder.unique_display_name() == category_path)
							category_folder_set.add(folder);
						continue;
					}
					if (is_root_category == true) {
						// just want top level categories...
						continue;
					}
					
					// game					
					if (parts[0] != "g" || parts.length != 5)
						throw new FileError.FAILED("invalid game format");					
					if (folder_id_map.has_key(key) == false)
						continue; // folder not found for key
					
					folder = folder_id_map[key];
					if (category_folder_set.contains(folder) == false)
						continue; // not relevant for the category path
						
					var id = parts[3];
					var full_name = parts[4];
					if (id == "")
						id = null;
					if (full_name == "")
						full_name = null;
					games.add(GameItem.create(name, folder.platform, folder, id, full_name));
				}
				
				subcategories = new ArrayList<string>();					
				if (subcategory_set.size > 0) {
					subcategories.add_all(subcategory_set);
					subcategories.sort(strcasecmp);
				}
									
				return true;
			} catch(Error e) {
				games = null;
				subcategories = null;
				return false;
			}			
		}
		static int strcasecmp(string a, string b) {
			return Utility.strcasecmp(a, b);
		}

		string[] load_cache_lines() throws GLib.FileError {
			string contents;
			if (FileUtils.get_contents(Path.build_filename(RuntimeEnvironment.user_config_dir(), GameFolder.CACHE_FOLDER_ROOT, CACHE_FILENAME), out contents) == false)
				return new string[0];
			return contents.strip().split("\n");			
		}
		
		void save_cache(Gee.List<GameItem> games, string? new_selection_id=null) {
			// attempt to save
			try {
				var sb = new StringBuilder();
				var hash = new HashMap<GameFolder,string>();
				
				foreach(var game in games) {
					ensure_folder_store(game.parent, hash, sb);
					game.add_cache_line(sb, hash[game.parent]);
				}
				if (FileUtils.set_contents(Path.build_filename(RuntimeEnvironment.user_config_dir(), GameFolder.CACHE_FOLDER_ROOT, CACHE_FILENAME), sb.str) == false)
					throw new FileError.FAILED("unspecified error");
				_root_category_names = null;
				cache_updated(new_selection_id);
			} catch(Error e) {
				warning("Error saving all games cache: %s", e.message);
			}
		}	
		void ensure_folder_store(GameFolder folder, HashMap<GameFolder,string> hash, StringBuilder sb) {
			if (hash.has_key(folder) == true)
				return;
			
			if (folder.parent == null) {
				hash[folder] = hash.size.to_string();
				add_folder_line("p", folder.platform.id, sb);
				return;
			}
			
			ensure_folder_store(folder.parent, hash, sb);
			hash[folder] = hash.size.to_string();
			add_folder_line(hash[folder.parent], folder.name, sb);
		}
		void add_folder_line(string parent_id, string name, StringBuilder sb) {
			sb.append("f||%s||%s\n".printf(parent_id, name));
		}
	}
}
