using Gee;
using Catapult;

namespace Data.GameList
{
	public abstract class GameListProvider
	{
		const string CUSTOM_COMMAND_SCRIPT_PATH = "pandafe-custom-run.sh";
		const string CUSTOM_PNDRUN_PATH = "scripts/pnd_run_nomount.sh";
		const string TMP_PATH = "/tmp/pandafe";

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
			string appdata_dirname = (app != null) ? app.appdata_dirname : null;
			string command = (app != null) ? app.exec_command : program.command;
			string startdir = (app != null) ? app.startdir : null;
			uint clockspeed = program.clockspeed;
			if (clockspeed == 0 && app != null)
				clockspeed = app.clockspeed;
			string args = game_args ?? program.arguments;
			if ((args == null || args == "") && app != null)
				args = app.exec_arguments;

			string game_path_link = null;
			if (game_path != null) {
				if (game_path.index_of(" ") != -1)
					// if game path contains spaces, use a temp symlink without spaces to workaround libpnd issues
					game_path_link = get_game_symlink_path(game_path);
				if (args != null && args.index_of("%g") != -1)
					args = args.replace("%g", game_path_link ?? game_path);
				else
					args = "%s %s".printf((args ?? ""), game_path_link ?? game_path);
				debug("args: %s", args);
			}

			bool has_custom_command = (program.custom_command != null && program.custom_command != "");
			if (has_custom_command == false && (command == null || command == "")) {
				debug("No command specified for '%s' program '%s'.", platform.name, program.name);
				return -1;
			}

			if (has_custom_command == false && premount == false) // run the pnd without premount
				return Pandora.Apps.execute_app(pnd.get_fullpath(), appdata_dirname ?? unique_id, command, startdir, args, clockspeed, Pandora.Apps.ExecOption.BLOCK);

			// mount the pnd
			var mountset = Data.pnd_mountset();
			bool already_mounted = mountset.is_mounted(unique_id);
			if (already_mounted == false && mountset.mount(unique_id) == false) {
				debug("Unable to mount pnd for id '%s'.", unique_id);
				return -1;
			}
			string mount_id = mountset.get_mount_id(unique_id);

			// ensure custom_command script, if specified
			if (has_custom_command == true) {
				command = CUSTOM_COMMAND_SCRIPT_PATH;
				string appdata_path = mountset.get_appdata_path(unique_id);
				if (appdata_path == null) {
					debug("appdata path not found for '%s'", mount_id);
					return -1;
				} else if (FileUtils.test(appdata_path, FileTest.EXISTS) == false) {
					debug("appdata path does not exist: %s", appdata_path);
					return -1;
				}
				string custom_path = appdata_path + CUSTOM_COMMAND_SCRIPT_PATH;
				if (already_mounted == false || FileUtils.test(custom_path, FileTest.EXISTS) == false) {
					try {
						if (FileUtils.set_contents(custom_path, program.custom_command) == true)
							FileUtils.chmod(custom_path, 0775);
					}
					catch(FileError e) {
						debug("Unable to save %s: %s", custom_path, e.message);
						return -1;
					}
				}
			}
			// run the pnd
			if (game_path_link != null) {
				if (create_game_symlink(game_path_link, game_path) == false) {
					return -1;
				}
			}
			var runpath = Path.build_filename(Config.PACKAGE_DATADIR, CUSTOM_PNDRUN_PATH);
			if (FileUtils.test(runpath, FileTest.EXISTS) == false)
				runpath = CUSTOM_PNDRUN_PATH;
			Pandora.Apps.set_pndrun_path(runpath);
			var result = Pandora.Apps.execute_app(pnd.get_fullpath(), mount_id, command, startdir, args, clockspeed, Pandora.Apps.ExecOption.BLOCK);
			Pandora.Apps.unset_pndrun_path();
			if (game_path_link != null) {
				delete_game_symlink(game_path_link);
			}
			return result;
		}

		string? get_game_symlink_path(string game_path) {
			return "%s%c%s".printf(TMP_PATH, Path.DIR_SEPARATOR, File.new_for_path(game_path).get_basename().replace(" ", "_"));
		}
		bool create_game_symlink(string linkpath, string game_path) {
			try {
				if (FileUtils.test(TMP_PATH, FileTest.EXISTS) == false) {
					if (File.new_for_path(TMP_PATH).make_directory_with_parents() == false) {
						debug("unable to create directory '%s'", TMP_PATH);
						return false;
					}
				}
				var linkfile = File.new_for_path(linkpath);
				if (FileUtils.test(linkpath, FileTest.EXISTS) == true)
					linkfile.delete();

				if (linkfile.make_symbolic_link(game_path) == false) {
					debug("unable to create symbolic link '%s' => '%s'", linkpath, game_path);
					return false;
				}
				return true;
			}
			catch (Error e) {
				debug("unable to create symbolic link '%s' => '%s': %s", linkpath, game_path, e.message);
			}
			return false;
		}
		bool delete_game_symlink(string linkpath) {
			try {
				return File.new_for_path(linkpath).delete();
			} catch(Error e) {
				debug("unable to delete symbolic link '%s': %s", linkpath, e.message);
			}
			return false;
		}
	}
}
