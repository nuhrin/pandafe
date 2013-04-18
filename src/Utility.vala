/* Utility.vala
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

public delegate void ForEachFunc<G> (owned G g);
public delegate ulong SignalConnect<G> (G g);

public class Utility
{
	public static CompareFunc<string> strcasecmp { get { return _strcasecmp; } }	
	static int _strcasecmp(string a, string b) {
		return a.casefold().collate(b.casefold());
	}
	
	public static bool remove_directory_recursive(File directory) throws GLib.Error
	{
		var enumerator = directory.enumerate_children("standard::*", FileQueryInfoFlags.NONE);
		FileInfo file_info;
		while ((file_info = enumerator.next_file ()) != null) {
			var type = file_info.get_file_type();
			var name = file_info.get_name();
			if (name.has_prefix(".") == true)
				continue;
			File child = File.new_for_path(Path.build_filename(directory.get_path(), name));
			bool child_delete_result = false;
			if (type == FileType.DIRECTORY) {
				child_delete_result = remove_directory_recursive(child);					
			} else {
				child_delete_result = child.delete();
			}
			if (child_delete_result == false)
				return false;
		}
		return directory.delete();
	}
}
