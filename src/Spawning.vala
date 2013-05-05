/* Spawning.vala
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
	
	public static SpawningResult spawn_command(string command_line, string working_directory) {
		int exit_status = -1;
		string standard_output;
		string standard_error;
		bool success;
		try {			
			string[] argv;
			Shell.parse_argv(command_line, out argv);
			success = Process.spawn_sync(working_directory, argv, null, 0, null, out standard_output, out standard_error, out exit_status);
			return new SpawningResult(success, command_line, standard_output, standard_error, exit_status);
		} catch(Error e) {
			return new SpawningResult.error_with_command_line(e.message, command_line);
		}
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
		return spawn_program_internal(program, premount, program_settings, game_path, custom_command, custom_command_script);
	}
	static SpawningResult spawn_program_internal(Program program, bool premount, ProgramSettings? program_settings=null, string? game_path=null,
		string? custom_command=null, string? custom_command_script=null) {		
		Data.Pnd.AppItem app = program.get_app();
		if (app == null)
			return new SpawningResult.error("No pnd app found for program '%s'.".printf(program.name));		
		
		string unique_id = app.id;
		string appdata_dirname = app.appdata_dirname;
		string command = app.exec_command;
		string startdir = app.startdir;
		uint clockspeed = program.get_clockspeed(program_settings);			
		string args = program.get_arguments(program_settings); 
		if (args == null || args == "")
			args = app.exec_arguments;

		if (game_path != null) {
			if (args != null && args.index_of("%g") != -1)
				args = args.replace("%g", "\"%s\"".printf(game_path));
			else
				args = "%s \"%s\"".printf((args ?? ""), game_path);
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
		var working_directory = mountset.get_mounted_path(app.package_id);
		if (has_custom_command == false && startdir != null && startdir.strip() != "")
			working_directory = Path.build_filename(working_directory, startdir);
		
		return spawn_app_wrapper_direct(working_directory, command, args, clockspeed);		
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
			_cpuspeed_wrapper_script_path = Path.build_filename(RuntimeEnvironment.system_data_dir(), CPUSPEED_WRAPPER_SCRIPT_PATH);
			if (FileUtils.test(_cpuspeed_wrapper_script_path, FileTest.EXISTS) == false)
				_cpuspeed_wrapper_script_path = CPUSPEED_WRAPPER_SCRIPT_PATH;
		}
		return _cpuspeed_wrapper_script_path;
	}
	static string? _cpuspeed_wrapper_script_path;	
}
