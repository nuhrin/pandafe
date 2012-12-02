/* GameListProvider.vala
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
using Data.Platforms;
using Data.Programs;

namespace Data.GameList
{
	public abstract class GameListProvider
	{
		protected GameListProvider(Platform platform) {
			this.platform = platform;
		}
		public weak Platform platform { get; private set; }

		public GameFolder root_folder {
			get {
				if (_root == null)
					_root = create_root_folder();
				return _root;
			}
		}
		GameFolder _root;

		public abstract SpawningResult run_game(GameItem game);
		public abstract Program? get_program_for_game(GameItem game);
		public abstract string get_unique_name(IGameListNode node);
		public virtual string get_unique_id(IGameListNode node) { return get_unique_name(node); }


		public void rescan(owned ForEachFunc<GameFolder>? pre_scan_action=null) {
			remove_platform_gamelist_cache();
			rescan_init();
			_root = null;
			root_folder.rescan_children(true, (owned)pre_scan_action);
		}
		public void clear_cache() {
			assert_not_reached();
		}
		public bool scan_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games) {
			bool result = get_children(folder, out child_folders, out child_games);
			return result;
		}

		protected virtual void rescan_init() { }
		
		protected abstract bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games);
		protected abstract GameFolder create_root_folder();

//~ 		protected SpawningResult run_program(Program program, ProgramSettings? program_settings=null, string? game_path=null) {
//~ 			return Spawning.spawn_program(program, false, program_settings, game_path);
//~ 		}
//~ 		protected SpawningResult run_program_with_premount(Program program, ProgramSettings? program_settings=null, string? game_path=null) {
//~ 			return Spawning.spawn_program(program, true, program_settings, game_path);
//~ 		}
//~ 		protected SpawningResult run_platform_program(RomPlatform platform, Program program, ProgramSettings? program_settings=null, string? game_path=null) {
//~ 			return Spawning.spawn_platform_program(platform, program, false, program_settings, game_path);
//~ 		}
//~ 		protected SpawningResult run_platform_program_with_premount(RomPlatform platform, Program program, ProgramSettings? program_settings=null, string? game_path=null) {
//~ 			return Spawning.spawn_platform_program(platform, program, true, program_settings, game_path);
//~ 		}		

		void remove_platform_gamelist_cache() {
			if (platform.id == null)
				return;
			string gamelistcache_path = Path.build_filename(Build.LOCAL_CONFIG_DIR, Data.GameList.GameFolder.YAML_FOLDER_ROOT, platform.id);
			if (FileUtils.test(gamelistcache_path, FileTest.IS_DIR) == true) {
				try {
					var directory = File.new_for_path(gamelistcache_path);
					Utility.remove_directory_recursive(directory);
				} catch(GLib.Error e) {
					warning("error remove platform '%s' gamelist cache: %s", platform.id, e.message);
				}
			}
		}
	}
}
