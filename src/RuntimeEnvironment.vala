/* RuntimeEnvironment.vala
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

public class RuntimeEnvironment {
	const string DEV_MODE_TEST_FILE = "DEVMODE";
	const string DEV_MODE_DATA_DIR	= "data";
	
	public static unowned string system_data_dir() {
		if (dev_mode)
			return DEV_MODE_DATA_DIR;
		return Build.PACKAGE_DATADIR;
	}
	public static unowned string user_config_dir() {
		ensure_data();
		return _user_config_dir;
	}
	
	public static bool is_pnd { get { return Build.IS_PND; } }	
	public static bool dev_mode {
		get {
			ensure_data();
			return _dev_mode;
		}
	}
	
	static void ensure_data() {
		if (checked)
			return;
		
		if (FileUtils.test(DEV_MODE_TEST_FILE, FileTest.EXISTS))
			_dev_mode = true;
			
		if (Build.IS_PND)
			_user_config_dir = ".";
		else if (_dev_mode)
			_user_config_dir = "." + Build.PND_APP_ID;
		else
			_user_config_dir = Path.build_filename(Environment.get_user_config_dir(), Build.PND_APP_ID);			
	}	
	static bool checked;
	static bool _dev_mode;
	static string _user_config_dir;
}
