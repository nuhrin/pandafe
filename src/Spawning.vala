using Catapult.Helpers;
using Data.Pnd;
using Data.Platforms;
using Data.Programs;

public class Spawning
{
	const string CUSTOM_COMMAND_SCRIPT_FORMAT = "pandafe-custom-run_%s.sh";
	const string CPUSPEED_WRAPPER_SCRIPT_PATH = "scripts/cpuspeed_change_exec_wrapper.sh";
	const string TMP_PATH = "/tmp/pandafe";
	static unowned RegexHelper invalid_file_chars { 
		get { 
			if (_invalid_file_chars == null)
				_invalid_file_chars = new RegexHelper("""[ '"]+""");
			return _invalid_file_chars;
		}
	}				
	static RegexHelper _invalid_file_chars = null;

	public static string get_custom_command_script_name(AppItem app) {
		return CUSTOM_COMMAND_SCRIPT_FORMAT.printf(app.id);
	}
	
	public static SpawningResult spawn_app(AppItem app, bool treat_non_zero_exit_code_as_error=true) {
		var mountset = Data.pnd_mountset();
		bool already_mounted = mountset.is_mounted(app.package_id);
		if (already_mounted == false)
			return spawn_app_wrapper(app.get_fullpath(), app.appdata_dirname ?? app.id, app.exec_command, app.startdir, app.exec_arguments, app.clockspeed, treat_non_zero_exit_code_as_error);
		
		var working_directory = mountset.get_mounted_path(app.package_id);
		if (app.startdir != null && app.startdir.strip() != "")
			working_directory = Path.build_filename(working_directory, app.startdir);
			
		return spawn_app_wrapper_direct(working_directory, app.exec_command, app.exec_arguments, app.clockspeed, treat_non_zero_exit_code_as_error);
			
	}
	public static SpawningResult spawn_program(Program program, bool premount, ProgramSettings? program_settings=null, string? game_path=null,
		string? custom_command=null, string? custom_command_script=null) {
		return spawn_program_internal(program, premount, program_settings, game_path, null, custom_command, custom_command_script);
	}
	public static SpawningResult spawn_platform_program(RomPlatform platform, Program program, bool premount, ProgramSettings? program_settings=null, string? game_path=null) {
		return spawn_program_internal(program, premount, program_settings, game_path, platform);
	}
	static SpawningResult spawn_program_internal(Program program, bool premount, ProgramSettings? program_settings=null, string? game_path=null, RomPlatform? platform=null,
		string? custom_command=null, string? custom_command_script=null) {
		if (platform != null && platform.get_program(program.app_id) != program)
			return new SpawningResult.error("Program '%s' not found on platform '%s'.".printf(program.name, platform.name));			
		
		Data.Pnd.AppItem app = program.get_app();
		if (app == null)
			return new SpawningResult.error("No pnd app found for program '%s'.".printf(program.name));		
		
		string unique_id = app.id;
		string appdata_dirname = app.appdata_dirname;
		string command = app.exec_command;
		string startdir = app.startdir;
		uint clockspeed = (platform != null)
			? platform.get_program_clockspeed(program, program_settings)
			: program.get_clockspeed(program_settings);			
		string args = (platform != null)
			? platform.get_program_arguments(program, program_settings)
			: program.get_arguments(program_settings); 
		if (args == null || args == "")
			args = app.exec_arguments;

		string game_path_link = null;
		if (game_path != null) {
			if (invalid_file_chars.match(game_path) == true)
				// if game path contains spaces, use a temp symlink without spaces to workaround libpnd issues
				game_path_link = get_game_symlink_path(game_path);
			if (args != null && args.index_of("%g") != -1)
				args = args.replace("%g", game_path_link ?? game_path);
			else
				args = "%s %s".printf((args ?? ""), game_path_link ?? game_path);
			//debug("args: %s", args);
		}

		bool has_custom_command = ((custom_command != null && custom_command_script != null) || (program.custom_command != null && program.custom_command != ""));
		if (has_custom_command == false && (command == null || command == ""))			
			return new SpawningResult.error("No command specified for program '%s'.".printf(program.name));

		if (has_custom_command == false && premount == false) // run the pnd without premount
			return spawn_app_wrapper(app.get_fullpath(), appdata_dirname ?? unique_id, command, startdir, args, clockspeed);

		// mount the pnd
		var mountset = Data.pnd_mountset();
		bool already_mounted = mountset.is_mounted(app.package_id);
		if (already_mounted == false && mountset.mount(unique_id, app.package_id) == false)
			return new SpawningResult.error("Unable to mount pnd for id '%s'.".printf(unique_id));
		string mount_id = mountset.get_mount_id(app.package_id);

		// ensure custom_command script, if specified
		if (has_custom_command == true) {
			command = custom_command ?? get_custom_command_script_name(app);
			string appdata_path = mountset.get_appdata_path(app.package_id);
			if (appdata_path == null)
				return new SpawningResult.error("appdata path not found for '%s'".printf(mount_id));
			else if (FileUtils.test(appdata_path, FileTest.EXISTS) == false)
				return new SpawningResult.error("appdata path does not exist: %s".printf(appdata_path));
			
			string custom_path = appdata_path + command;
			if (already_mounted == false || FileUtils.test(custom_path, FileTest.EXISTS) == false) {
				try {
					if (FileUtils.set_contents(custom_path, custom_command_script ?? program.custom_command) == true)
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
		//Pandora.Apps.set_pndrun_path(get_custom_pndrun_path());
		//var result = spawn_app_wrapper(app.get_fullpath(), mount_id, command, startdir, args, clockspeed, Pandora.Apps.ExecOption.BLOCK);
		//Pandora.Apps.unset_pndrun_path();
		var working_directory = mountset.get_mounted_path(app.package_id);
		if (has_custom_command == false && startdir != null && startdir.strip() != "")
			working_directory = Path.build_filename(working_directory, startdir);
		var result = spawn_app_wrapper_direct(working_directory, command, args, clockspeed);
		if (game_path_link != null)
			delete_game_symlink(game_path_link);
		
		return result;
	}

	static string? get_game_symlink_path(string game_path) {
		return "%s%c%s".printf(TMP_PATH, Path.DIR_SEPARATOR, invalid_file_chars.replace(File.new_for_path(game_path).get_basename(), "_"));
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
			warning("unable to delete symbolic link '%s': %s", linkpath, e.message);
		}
		return false;
	}
	
	static SpawningResult spawn_app_wrapper(string fullpath, string unique_id, string command, string? startdir=null, string? args=null, uint clockspeed=0, bool treat_non_zero_exit_code_as_error=true) {
		if (FileUtils.test(fullpath, FileTest.EXISTS) == false)
			return new SpawningResult.error("pnd not found: " + fullpath);
		string command_line;
		if (clockspeed == 0) {
			command_line = Pandora.Apps.get_app_runline(fullpath, unique_id, command, startdir, args, clockspeed);
		} else {	
			command_line = "%s %u %s".printf(get_cpuspeed_wrapper_script_path(), clockspeed,
				Pandora.Apps.get_app_runline(fullpath, unique_id, command, startdir, args, 0));
		}
		
		try {
			int exit_status = -1;
			string standard_output;
			string standard_error;		
			bool success = Process.spawn_command_line_sync(command_line, out standard_output, out standard_error, out exit_status);
			if (success == true && exit_status > 0 && treat_non_zero_exit_code_as_error == true)
				success = false;
			return new SpawningResult(success, command_line, standard_output, standard_error, exit_status);
		} catch(SpawnError e) {
			return new SpawningResult.error_with_command_line(e.message, command_line);
		}
	}
	static SpawningResult spawn_app_wrapper_direct(string working_directory, string command, string? args=null, uint clockspeed=0, bool treat_non_zero_exit_code_as_error=true) {
		int exit_status = -1;
		string standard_output;
		string standard_error;
		bool success;
		string command_line = (args != null) ? "%s %s".printf(command, args) : command;
		try {			
			if (clockspeed != 0) {			
				var modified_commandline = "%s %u %s%c%s".printf(get_cpuspeed_wrapper_script_path(), clockspeed, working_directory, Path.DIR_SEPARATOR, command_line);
				success = Process.spawn_command_line_sync(modified_commandline, out standard_output, out standard_error, out exit_status);				
			} else {
				string[] argv;
				Shell.parse_argv(command_line, out argv);
				success = Process.spawn_sync(working_directory, argv, null, 0, null, out standard_output, out standard_error, out exit_status);
			}
			if (success == true && exit_status > 0 && treat_non_zero_exit_code_as_error == true)
				success = false;
			return new SpawningResult(success, command_line, standard_output, standard_error, exit_status);
		} catch(Error e) {
			return new SpawningResult.error_with_command_line(e.message, command_line);
		}
	}	
	
	static unowned string get_cpuspeed_wrapper_script_path() {
		if (_cpuspeed_wrapper_script_path == null) {				
			_cpuspeed_wrapper_script_path = Path.build_filename(Build.PACKAGE_DATADIR, CPUSPEED_WRAPPER_SCRIPT_PATH);
			if (FileUtils.test(_cpuspeed_wrapper_script_path, FileTest.EXISTS) == false)
				_cpuspeed_wrapper_script_path = CPUSPEED_WRAPPER_SCRIPT_PATH;
		}
		return _cpuspeed_wrapper_script_path;
	}
	static string? _cpuspeed_wrapper_script_path;	
}
