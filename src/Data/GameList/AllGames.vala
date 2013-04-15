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
		public Enumerable<GameItem> load() {
			Gee.List<GameItem> games;
			if (load_from_cache(out games) == true)
				return new Enumerable<GameItem>(games);
				
			return rebuild();
		}
		
		public signal void cache_updated();
		public void update_cache_for_folder(GameFolder folder) {
			if (folder == null || folder.platform.id == "pandora")
				return;
			
			var cache = load_cache();
			if (cache == null)
				return;
			
			AllGamesCache.PlatformNode platform_node = null;
			foreach(var platform in cache.platforms) {
				if (platform.id == folder.platform.id) {
					platform_node = platform;
					break;
				}				
			}
			if (platform_node == null) {
				platform_node = new AllGamesCache.PlatformNode() { id = folder.platform.id };
				cache.platforms.add(platform_node);
			}
			
			
			var folder_node = get_cache_folder_node_for_folder(folder, platform_node);
			populate_folder_node_with_folder(folder_node, folder);
						
			save_cache(cache);
		}
		AllGamesCache.FolderNodeBase get_cache_folder_node_for_folder(GameFolder folder, AllGamesCache.PlatformNode platform_node) {
			var folder_names = new ArrayList<string>();
			var folder_root = folder;
			while(folder_root.parent != null) {
				folder_names.insert(0, folder_root.name);
				folder_root = folder_root.parent;
			}
			
			if (folder_names.size == 0)
				return platform_node;
			
			AllGamesCache.FolderNodeBase source = platform_node;
			foreach(var folder_name in folder_names) {
				AllGamesCache.FolderNode result = null;
				foreach(var child_node in source.subfolders) {
					if (child_node.name == folder_name) {
						result = child_node;
						break;
					}
				}
				if (result == null) {
					result = new AllGamesCache.FolderNode() { name = folder_name };
					source.subfolders.add(result);
				}
				source = result;
			}
			
			return source;
		}
		void populate_folder_node_with_folder(AllGamesCache.FolderNodeBase folder_node, GameFolder folder) {
			folder_node.games = folder.child_games().to_list();
			foreach(var child in folder.child_folders()) {
				AllGamesCache.FolderNode found_node = null;
				foreach(var child_node in folder_node.subfolders) {
					if (child_node.name == child.name) {
						found_node = child_node;
						break;
					}
				}
				if (found_node == null) {
					found_node = new AllGamesCache.FolderNode() { name = child.name };
					folder_node.subfolders.add(found_node);
				}
				populate_folder_node_with_folder(found_node, child);
			}
		}
		
		Enumerable<GameItem> rebuild() {
			var games = new ArrayList<GameItem>();
			var cache = new AllGamesCache();
			
			// get platforms
			var folder_data = Data.platforms().get_platform_folder_data();
			var platforms = (folder_data.folders.size > 0)
				? folder_data.get_all_platforms()
				: Data.platforms().get_all_platforms();
			
			// populate games and cache
			foreach(var platform in platforms) {
				var platform_node = new AllGamesCache.PlatformNode() { id = platform.id };
				cache.platforms.add(platform_node);
				if (platform.id == "pandora") {
					var pnd_games = Data.platforms().get_native_platform().get_root_folder().all_games().to_list();
					games.add_all(pnd_games);
					continue;
				}
				var root_folder = platform.get_root_folder();
				foreach(var game in root_folder.child_games()) {
					platform_node.games.add(game);
					games.add(game);
				}
				foreach(var subfolder in root_folder.child_folders()) {
					var subfolder_node = new AllGamesCache.FolderNode() { name = subfolder.name };
					platform_node.subfolders.add(subfolder_node);
					rebuild_folder(subfolder, subfolder_node, games);
				}
			}
			save_cache(cache);
			
			return new Enumerable<GameItem>(games);
		}
		void rebuild_folder(GameFolder folder, AllGamesCache.FolderNode folder_node, ArrayList<GameItem> games) {
			foreach(var game in folder.child_games()) {
				folder_node.games.add(game);
				games.add(game);
			}
			foreach(var subfolder in folder.child_folders()) {
				var subfolder_node = new AllGamesCache.FolderNode() { name = subfolder.name };
				folder_node.subfolders.add(subfolder_node);
				rebuild_folder(subfolder, subfolder_node, games);
			}
		}
		
		bool load_from_cache(out Gee.List<GameItem> games) {
			games = null;
			AllGamesCache cache = load_cache();
			if (cache == null)
				return false;

			games = new ArrayList<GameItem>();
			foreach(var platform_node in cache.platforms) {
				if (platform_node.id == "pandora") {
					var pnd_games = Data.platforms().get_native_platform().get_root_folder().all_games().to_list();
					games.add_all(pnd_games);
					continue;
				}
				var platform = Data.platforms().get_platform(platform_node.id);
				if (platform == null)
					continue;
				var root_folder = platform.get_root_folder();
				foreach(var game in platform_node.games) {
					GameItem.set_platform(game, platform);
					GameItem.set_parent(game, root_folder);
				}
				games.add_all(platform_node.games);
				foreach(var subfolder in platform_node.subfolders)
					load_games_from_folder_node(subfolder, root_folder, games);				
			}
			return true;
		}
		void load_games_from_folder_node(AllGamesCache.FolderNode folder_node, GameFolder parent, Gee.List<GameItem> games) {
			var folder = new GameFolder(folder_node.name, parent.platform, parent);
			foreach(var game in folder_node.games) {
				GameItem.set_platform(game, folder.platform);
				GameItem.set_parent(game, folder);
			}
			games.add_all(folder_node.games);
			foreach(var subfolder in folder_node.subfolders)
				load_games_from_folder_node(subfolder, folder, games);
		}
		
		AllGamesCache? load_cache() {
			AllGamesCache cache = null;			
			try {
				cache = Data.data_interface().load<AllGamesCache>(AllGamesCache.YAML_ID, GameFolder.YAML_FOLDER_ROOT);
			} catch(Error e) {
				//warning("Error loading cache for folder '%s': %s", folder_path, e.message);
			}
			return cache;
		}
		void save_cache(AllGamesCache cache) {
			// attempt to save
			try {
				Data.data_interface().save(cache, AllGamesCache.YAML_ID, GameFolder.YAML_FOLDER_ROOT);
				cache_updated();
			} catch(Error e) {
				warning("Error saving all games cache: %s", e.message);
			}
		}
	}
}
