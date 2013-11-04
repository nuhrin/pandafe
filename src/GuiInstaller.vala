/* GuiInstaller.vala
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

public class GuiInstaller
{
	public static bool is_pandafe_gui_installed() {
		return Spawning.run_temp_script("check-pandafe-gui.sh", check_pandafe_gui_sh, false).success;		
	}
	public static SpawningResult install_pandafe_gui(string pndpath) {
		string error;
		string pandafe_start_contents = pandafe_start_format.printf(pndpath, Build.PND_APP_ID);
		var pandafe_start_file = Spawning.create_temp_script("pandafe-start", pandafe_start_contents, out error);
		if (pandafe_start_file == null)
			return new SpawningResult.error(error);
		
		var result = Spawning.run_temp_script("install-pandafe-gui.sh", install_pandafe_gui_sh, true);
		FileUtils.remove(pandafe_start_file);
		return result;
	}
	public static SpawningResult uninstall_pandafe_gui() {
		return Spawning.run_temp_script("uninstall-pandafe-gui.sh", uninstall_pandafe_gui_sh, true);
	}
		
	const string pandafe_start_format = """#!/bin/bash
PND="%s"
APP_ID="%s"

NOT_FOUND_TEXT=$(cat <<TEXTEND
Pandafe was not found where expected:
        <i>$PND</i>

possible causes:
* the sd card containing the pnd is not inserted
* the sd card is in a different slot than at install time
* the pnd has been moved to a different path

possible solutions:
* insert the sd card into the expected slot
* re-run Pandafe from a different gui, then
  uninstall and reinstall this gui
TEXTEND
)

function pnd_not_found_dialog() {
        zenity --question --title "Pandafe GUI: PND NOT FOUND" --cancel-label="Switch GUI" --ok-label="Retry" --text="$NOT_FOUND_TEXT" --width=520 
}

function run_pandafe() {
        if [[ ! -f "$PND" ]]; then
                pnd_not_found_dialog   
                if [[ $? ==  "0" ]]; then
                        run_pandafe
                else
                        /usr/pandora/scripts/op_switchgui.sh
                fi
                return
        fi

	# run pandafe via mount->run->unmount, to avoid pandora key kill (which is unhelpful in this context)
	/usr/pandora/scripts/pnd_run.sh -m -p "$PND" -b "${APP_ID}"
	cd /mnt/utmp/${APP_ID}
	./pandafe.sh --as-gui
	cd
	/usr/pandora/scripts/pnd_run.sh -u -p "$PND" -b "${APP_ID}"
}

# start window manager, for decorating gtk windows
xfwm4 &

run_pandafe

# shudown window manager
killall -2 xfwm4""";

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
