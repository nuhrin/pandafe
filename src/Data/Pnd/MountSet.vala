/* MountSet.vala
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

using Gee;
using Catapult;

namespace Data.Pnd
{
	const string UNION_MOUNT_PATH="/mnt/utmp/";
	const string PND_MOUNT_PATH="/mnt/pnd/";
	const int MAX_CONCURRENT_MOUNTS = 3;
	
	public class MountSet
	{
		ArrayList<string> mounted_ids;
		HashMap<string, string> mounted_pnd_path_hash;
		HashMap<string, string> mounted_appdata_path_hash;
		public MountSet() {
			mounted_ids = new ArrayList<string>();
			mounted_pnd_path_hash = new HashMap<string, string>();
			mounted_appdata_path_hash = new HashMap<string, string>();
		}
		~MountSet() {
			unmount_all();
		}

		public signal void app_mounting(string mount_id);
		public signal void app_mounted(string mount_id);
		public signal void app_unmounting(string mount_id);

		public bool has_mounted { get { return (mounted_ids.size > 0); } }

		public bool is_mounted(AppItem app) {
			return is_app_mounted(app);
		}
		public string? get_mounted_path(AppItem app) {
			if (is_app_mounted(app) == false)
				return null;

			return UNION_MOUNT_PATH + app.mount_id;
		}
		public string? get_mounted_appdata_path(AppItem app) {
			if (is_app_mounted(app) == false)
				return null;
			
			if (mounted_appdata_path_hash.has_key(app.mount_id) == true)
				return mounted_appdata_path_hash[app.mount_id];

			string path = Pandora.Apps.get_appdata_path(app.get_fullpath(), app.mount_id);
			if (path != null) {
				mounted_appdata_path_hash[app.mount_id] = path;
				return path;
			}

			return null;
		}

		public bool mount(AppItem app) {
			if (is_app_mounted(app) == true)
				return true;

			while (mounted_ids.size >= MAX_CONCURRENT_MOUNTS) {
				if (unmount_by_id(mounted_ids[0]) == false)
					break;
			}

			app_mounting(app.mount_id);

			if (Pandora.Apps.mount_pnd(app.get_fullpath(), app.mount_id) == false)
				return false;
			
			mounted_ids.add(app.mount_id);
			mounted_pnd_path_hash[app.mount_id] = app.get_fullpath();

			app_mounted(app.mount_id);
			
			return true;
		}

		public bool unmount(AppItem app, owned ForEachFunc<string>? pre_unmount_action=null) {
			return unmount_by_id(app.mount_id);
		}
		public bool unmount_all(owned ForEachFunc<string>? pre_unmount_action=null) {
			bool error = false;
			while(mounted_ids.size > 0) {
				if (unmount_by_id(mounted_ids[0], (owned)pre_unmount_action) == false)
					error = true;
			}
			
			return (error == false);
		}
		bool unmount_by_id(string mount_id, owned ForEachFunc<string>? pre_unmount_action=null) {
			if (mounted_ids.contains(mount_id) == false)
				return true;
				
			app_unmounting(mount_id);
			if (pre_unmount_action != null)
				pre_unmount_action(mount_id);
			
			if (Pandora.Apps.unmount_pnd(mounted_pnd_path_hash[mount_id], mount_id) == false)
				return false;

			mounted_pnd_path_hash.unset(mount_id);
			if (mounted_appdata_path_hash.has_key(mount_id) == true)
				mounted_appdata_path_hash.unset(mount_id);
			int index_of_key = mounted_ids.index_of(mount_id);
			if (index_of_key != -1)
				mounted_ids.remove_at(index_of_key);
				
			return true;
		}
		

		bool is_app_mounted(AppItem app) {
			return mounted_ids.contains(app.mount_id);
		}
	}
}
