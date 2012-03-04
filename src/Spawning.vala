using Data.Pnd;
using Data.Programs;

public class Spawning
{
	const string CUSTOM_COMMAND_SCRIPT_PATH = "pandafe-custom-run.sh";
	const string CUSTOM_PNDRUN_PATH = "scripts/pnd_run_nomount.sh";
	const string CPUSPEED_WRAPPER_SCRIPT_PATH = "scripts/cpuspeed_change_exec_wrapper.sh";
	const string TMP_PATH = "/tmp/pandafe";
		
	public static SpawningResult spawn_app(AppItem app) {
		return spawn_app_wrapper(app.get_fullpath(), app.appdata_dirname ?? app.id, app.exec_command, app.startdir, app.exec_arguments, app.clockspeed);
	}
	public static SpawningResult spawn_program(Program program, bool premount, ProgramSettings? program_settings=null, string? game_path=null) {			
		Data.Pnd.AppItem app = program.get_app();
		if (app == null)
			return new SpawningResult.error("No pnd app specified for program '%s'.".printf(program.name));		
		
		string unique_id = app.id;
		string appdata_dirname = app.appdata_dirname;
		string command = app.exec_command;
		string startdir = app.startdir;
		uint clockspeed = program.get_clockspeed(program_settings);			
		string args = program.get_arguments(program_settings); //game_args;// ?? program.arguments;
		if (args == null || args == "")
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
			//debug("args: %s", args);
		}

		bool has_custom_command = (program.custom_command != null && program.custom_command != "");
		if (has_custom_command == false && (command == null || command == ""))			
			return new SpawningResult.error("No command specified for program '%s'.".printf(program.name));

		if (has_custom_command == false && premount == false) // run the pnd without premount
			return spawn_app_wrapper(app.get_fullpath(), appdata_dirname ?? unique_id, command, startdir, args, clockspeed, Pandora.Apps.ExecOption.BLOCK);

		// mount the pnd
		var mountset = Data.pnd_mountset();
		bool already_mounted = mountset.is_mounted(app.package_id);
		if (already_mounted == false && mountset.mount(unique_id, app.package_id) == false)
			return new SpawningResult.error("Unable to mount pnd for id '%s'.".printf(unique_id));
		string mount_id = mountset.get_mount_id(app.package_id);

		// ensure custom_command script, if specified
		if (has_custom_command == true) {
			command = CUSTOM_COMMAND_SCRIPT_PATH;
			string appdata_path = mountset.get_appdata_path(app.package_id);
			if (appdata_path == null)
				return new SpawningResult.error("appdata path not found for '%s'".printf(mount_id));
			else if (FileUtils.test(appdata_path, FileTest.EXISTS) == false)
				return new SpawningResult.error("appdata path does not exist: %s".printf(appdata_path));
			
			string custom_path = appdata_path + CUSTOM_COMMAND_SCRIPT_PATH;
			if (already_mounted == false || FileUtils.test(custom_path, FileTest.EXISTS) == false) {
				try {
					if (FileUtils.set_contents(custom_path, program.custom_command) == true)
						FileUtils.chmod(custom_path, 0775);
				}
				catch(FileError e) {
					return new SpawningResult.error("Unable to save %s: %s".printf(custom_path, e.message));
				}
			}
		}
		// run the pnd
		if (game_path_link != null) {
			string? symlink_error;
			if (create_game_symlink(game_path_link, game_path, out symlink_error) == false)
				return new SpawningResult.error("game setup: " + symlink_error);			
		}
		Pandora.Apps.set_pndrun_path(get_custom_pndrun_path());
		var result = spawn_app_wrapper(app.get_fullpath(), mount_id, command, startdir, args, clockspeed, Pandora.Apps.ExecOption.BLOCK);
		Pandora.Apps.unset_pndrun_path();
		if (game_path_link != null)
			delete_game_symlink(game_path_link);
		
		return result;
	}

	static string? get_game_symlink_path(string game_path) {
		return "%s%c%s".printf(TMP_PATH, Path.DIR_SEPARATOR, File.new_for_path(game_path).get_basename().replace(" ", "_"));
	}
	static bool create_game_symlink(string linkpath, string game_path, out string? error) {
		error = null;
		try {
			if (FileUtils.test(TMP_PATH, FileTest.EXISTS) == false) {
				if (File.new_for_path(TMP_PATH).make_directory_with_parents() == false) {
					error = "unable to create directory '%s'".printf(TMP_PATH);
					return false;
				}
			}
			var linkfile = File.new_for_path(linkpath);
			if (FileUtils.test(linkpath, FileTest.EXISTS) == true)
				linkfile.delete();

			if (linkfile.make_symbolic_link(game_path) == false) {
				error = "unable to create symbolic link '%s' => '%s'".printf(linkpath, game_path);
				return false;
			}
			return true;
		}
		catch (Error e) {
			error = "unable to create symbolic link '%s' => '%s': %s".printf(linkpath, game_path, e.message);
		}
		return false;
	}
	static bool delete_game_symlink(string linkpath) {
		try {
			return File.new_for_path(linkpath).delete();
		} catch(Error e) {
			debug("unable to delete symbolic link '%s': %s", linkpath, e.message);
		}
		return false;
	}
	
	static SpawningResult spawn_app_wrapper(string fullpath, string unique_id, string command, string? startdir=null, string? args=null, uint clockspeed=0, Pandora.Apps.ExecOption options=Pandora.Apps.ExecOption.NONE) {
		string command_line;
		if (clockspeed == 0) {
			command_line = Pandora.Apps.get_app_runline(fullpath, unique_id, command, startdir, args, clockspeed, options);
		} else {	
			command_line = "%s %u %s".printf(get_cpuspeed_wrapper_script_path(), clockspeed,
				Pandora.Apps.get_app_runline(fullpath, unique_id, command, startdir, args, 0, options));
		}
		
		try {
			int exit_status = -1;
			string standard_output;
			string standard_error;		
			bool success = Process.spawn_command_line_sync(command_line, out standard_output, out standard_error, out exit_status);
			if (success == true && exit_status > 0)
				success = false;
			return new SpawningResult(success, command_line, standard_output, standard_error, exit_status);
		} catch(SpawnError e) {
			return new SpawningResult.error_with_command_line(e.message, command_line);
		}
	}
	
	static unowned string get_custom_pndrun_path() {
		if (_custom_pndrun_path == null) {				
			_custom_pndrun_path = Path.build_filename(Config.PACKAGE_DATADIR, CUSTOM_PNDRUN_PATH);
			if (FileUtils.test(_custom_pndrun_path, FileTest.EXISTS) == false)
				_custom_pndrun_path = CUSTOM_PNDRUN_PATH;
		}
		return _custom_pndrun_path;
	}
	static string? _custom_pndrun_path;
	static unowned string get_cpuspeed_wrapper_script_path() {
		if (_cpuspeed_wrapper_script_path == null) {				
			_cpuspeed_wrapper_script_path = Path.build_filename(Config.PACKAGE_DATADIR, CPUSPEED_WRAPPER_SCRIPT_PATH);
			if (FileUtils.test(_cpuspeed_wrapper_script_path, FileTest.EXISTS) == false)
				_cpuspeed_wrapper_script_path = CPUSPEED_WRAPPER_SCRIPT_PATH;
		}
		return _cpuspeed_wrapper_script_path;
	}
	static string? _cpuspeed_wrapper_script_path;	
}