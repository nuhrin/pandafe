using Gee;
using Catapult;
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
		public abstract string get_unique_id(IGameListNode node);


		public void rescan() {
			remove_platform_gamelist_cache();
			rescan_init();
			root_folder.rescan_children(true);
		}
		public void clear_cache() {
			assert_not_reached();
		}
		public bool scan_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games) {
			bool result = get_children(folder, out child_folders, out child_games);
			// todo: notify some signal of folder scan
			//debug("folder '%s' scanned.", folder.unique_id());
			return result;
		}

		protected virtual void rescan_init() { }
		protected void recreate_root_folder() { _root = create_root_folder(); }
		
		protected abstract bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games);
		protected abstract GameFolder create_root_folder();

		protected SpawningResult run_program(Program program, ProgramSettings? program_settings=null, string? game_path=null) {
			return Spawning.spawn_program(program, false, program_settings, game_path);
		}
		protected SpawningResult run_program_with_premount(Program program, ProgramSettings? program_settings=null, string? game_path=null) {
			return Spawning.spawn_program(program, true, program_settings, game_path);
		}

		void remove_platform_gamelist_cache() {
			if (platform.id == null)
				return;
			string gamelistcache_path = Path.build_filename(Config.LOCAL_CONFIG_DIR, Data.GameList.GameFolder.YAML_FOLDER_ROOT, platform.id);
			if (FileUtils.test(gamelistcache_path, FileTest.IS_DIR) == true) {
				try {
					var directory = File.new_for_path(gamelistcache_path);
					Utility.remove_directory_recursive(directory);
				} catch(GLib.Error e) {
					debug("error remove platform '%s' gamelist cache: %s", platform.id, e.message);
				}
			}
		}
	}
}
