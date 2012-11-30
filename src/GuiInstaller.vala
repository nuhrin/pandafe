
public class GuiInstaller
{
	public static bool is_pandafe_gui_installed() {
		return run_temp_script("check-pandafe-gui.sh", check_pandafe_gui_sh, false).success;		
	}
	public static SpawningResult install_pandafe_gui(string pndpath) {
		string error;
		string pandafe_start_contents = pandafe_start_format.printf(pndpath);
		var pandafe_start_file = create_temp_script("pandafe-start", pandafe_start_contents, out error);
		if (pandafe_start_file == null)
			return new SpawningResult.error(error);
		
		var result = run_temp_script("install-pandafe-gui.sh", install_pandafe_gui_sh, true);
		FileUtils.remove(pandafe_start_file);
		return result;
	}
	public static SpawningResult uninstall_pandafe_gui() {
		return run_temp_script("uninstall-pandafe-gui.sh", uninstall_pandafe_gui_sh, true);
	}

	static SpawningResult run_temp_script(string filename, string contents, bool as_root) {
		string error;
		var path = create_temp_script(filename, contents, out error);
		if (path == null)
			return new SpawningResult.error(error);
		
		string command = (as_root) ? "gksudo " + path : path;
		int exit_status = -1;
		string standard_output;
		string standard_error;
		bool success;
		try {			
			success = Process.spawn_command_line_sync(command, out standard_output, out standard_error, out exit_status);			
			if (success == true && exit_status > 0)
				success = false;
			FileUtils.remove(path);
			return new SpawningResult(success, command, standard_output, standard_error, exit_status);
		} catch(Error e) {
			FileUtils.remove(path);
			return new SpawningResult.error_with_command_line(e.message, command);
		}
	}
	
	static string? create_temp_script(string filename, string contents, out string error) {
		error = "";
		var path = Path.build_filename("/tmp", filename);
		try {
			if (FileUtils.set_contents(path, contents) == false) {
				error = @"Unable to write '$path'.";
				return null;
			}
		} catch(FileError e) {
			error = e.message;
			return null;
		}
		if (Posix.chmod(path, Posix.S_IRUSR | Posix.S_IWUSR | Posix.S_IXUSR | Posix.S_IRGRP | Posix.S_IXGRP | Posix.S_IROTH | Posix.S_IXOTH) == -1) {
			FileUtils.remove(path);
			error = @"Unable to make '$path' executable.";
			return null;
		}
		return path;
	}
		
	const string pandafe_start_format = """#!/bin/bash
# start window manager, for decorating gtk windows
xfwm4 &

# run pandafe via mount->run->unmount, to avoid pandora key kill (which is unhelpful in this context)
/usr/pandora/scripts/pnd_run.sh -m -p "%s" -b "pandafe"
cd /mnt/utmp/pandafe
bin/pandafe --as-gui
cd
/usr/pandora/scripts/pnd_run.sh -u -p "%s" -b "pandafe"

# shudown window manager
killall -2 xfwm4
""";

const string check_pandafe_gui_sh = """#!/bin/bash
GUICONF="/etc/pandora/conf/gui.conf"
NAME="Pandafe"
grep "$NAME;" $GUICONF >/dev/null 2>&1
""";

	const string install_pandafe_gui_sh = """#!/bin/bash
GUICONF="/etc/pandora/conf/gui.conf"
NAME="Pandafe"
DESC="frontin'"
START="pandafe-start"
STOP="true"

cp /tmp/pandafe-start /usr/bin

if grep "$NAME;" $GUICONF >/dev/null 2>&1; then
	echo already installed.
	exit
fi

sed -i -e "s|^\(.*\)NOSWITCH$|$NAME;$DESC;$START;$STOP\n\1NOSWITCH|" $GUICONF
""";

	const string uninstall_pandafe_gui_sh = """#!/bin/bash
GUICONF="/etc/pandora/conf/gui.conf"
NAME="Pandafe"

rm -f /usr/bin/pandafe-start

if ! grep "$NAME;" $GUICONF >/dev/null 2>&1; then
    echo not installed.
    exit
fi

OUTPUT=$(grep -v "$NAME;" $GUICONF)
echo "$OUTPUT" > $GUICONF
""";

}
