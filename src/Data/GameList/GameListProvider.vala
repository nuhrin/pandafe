using Gee;
using Catapult;

namespace Data.GameList
{
	public abstract class GameListProvider
	{
		const string CUSTOM_COMMAND_SCRIPT_PATH = "pandafe-custom-run.sh";
		const string CUSTOM_PNDRUN_PATH = "scripts/pnd_run.sh";

		protected GameListProvider(Platform platform) {
			this.platform = platform;
		}
		protected weak Platform platform { get; private set; }

		public GameFolder root_folder {
			get {
				if (_root == null)
					_root = create_root_folder();
				return _root;
			}
		}
		GameFolder _root;

		public abstract uint run_game(GameItem game);

		public abstract bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games);
		public abstract string get_unique_id(GameListNode node);

		protected abstract GameFolder create_root_folder();

		protected uint run_program(Program program, string? game_args=null, string? game_path=null) {
			return run_program_internal(program, false, game_args, game_path);
		}
		protected uint run_program_with_premount(Program program, string? game_args=null, string? game_path=null) {
			return run_program_internal(program, true, game_args, game_path);
		}

		uint run_program_internal(Program program, bool premount, string? game_args=null, string? game_path=null) {
			if (program.pnd_id == null || program.pnd_id == "") {
				debug("No pnd specified for '%s' program '%s'.", platform.name, program.name);
				return -1;
			}

			var data = Data.pnd_data();
			var pnd = data.get_pnd(program.pnd_id);
			if (pnd == null) {
				debug("Pnd '%s' not found.", program.pnd_id);
				return -1;
			}

			Data.Pnd.AppItem app = null;
			if (program.pnd_app_id != null)
				app = data.get_app(program.pnd_app_id);

			string unique_id = (app != null) ? app.id : pnd.pnd_id;
			string startdir = (app != null) ? app.startdir : null;
			uint clockspeed = program.clockspeed;
			if (clockspeed == 0 && app != null)
				clockspeed = app.clockspeed;
			string args = game_args ?? program.arguments;
			if ((args == null || args == "") && app != null)
				args = app.exec_arguments;
			if (game_path != null) {
				if (args != null && args.index_of("%g") != -1)
					args = args.replace("%g", game_path);
				else
					args = "%s %s".printf((args ?? ""), game_path);
			}

			bool has_custom_command = (program.custom_command != null && program.custom_command != "");
			string command = (app != null) ? app.exec_command : program.command;
			if (has_custom_command == false) {
				if (command == null || command == "") {
					debug("No command specified for '%s' program '%s'.", platform.name, program.name);
					return -1;
				}
			}

			// run the pnd without premount
			if (has_custom_command == false && premount == false)
				return Pandora.Apps.execute_app(pnd.get_fullpath(), unique_id, command, startdir, args, clockspeed, Pandora.Apps.ExecOption.BLOCK);

			bool already_mounted = false;
			// mount the pnd
			var mountset = Data.pnd_mountset();
			already_mounted = mountset.is_mounted(pnd.pnd_id);
			if (mountset.mount(pnd.pnd_id, unique_id) == false) {
				debug("Unable to mount pnd '%s'.", pnd.pnd_id);
				return -1;
			}
			string mount_id = mountset.get_mount_id(pnd.pnd_id);

			// ensure custom_command script, if specified
			if (has_custom_command == true) {
				string appdata_path = mountset.get_appdata_path(pnd.pnd_id);
				if (appdata_path == null) {
					debug("appdata path for not found for '%s'", mount_id);
				} else if (FileUtils.test(appdata_path, FileTest.EXISTS) == false) {
					debug("appdata path does not exist: %s", appdata_path);
				} else {
					string custom_path = appdata_path + CUSTOM_COMMAND_SCRIPT_PATH;
					if (already_mounted == false || FileUtils.test(custom_path, FileTest.EXISTS) == false) {
						try {
							if (FileUtils.set_contents(custom_path, program.custom_command) == true
							 && FileUtils.chmod(custom_path, 0775) == 0) {
								command = CUSTOM_COMMAND_SCRIPT_PATH;
							}
						}
						catch(FileError e) {
							debug("Unable to save %s: %s", custom_path, e.message);
						}
					} else {
						command = CUSTOM_COMMAND_SCRIPT_PATH;
					}
				}
			}
			// run the pnd
			Pandora.Apps.set_pndrun_path(CUSTOM_PNDRUN_PATH);
			var result = Pandora.Apps.execute_app(pnd.get_fullpath(), mount_id, command, startdir, args, clockspeed, Pandora.Apps.ExecOption.BLOCK);
			Pandora.Apps.unset_pndrun_path();
			return result;
		}

	}
}
