using Gee;
using Catapult;

namespace Data.Pnd
{
	const string UNION_MOUNT_PATH="/mnt/utmp/";
	const string PND_MOUNT_PATH="/mnt/pnd/";
	const int MAX_CONCURRENT_MOUNTS = 3;
	
	public class MountSet
	{
		PndData data;
		string mount_prefix;
		ArrayList<string> mounted_pnd_ids;
		HashMap<string, string> mounted_pnd_name_hash;
		HashMap<string, string> pnd_appdata_path_hash;
		public MountSet(string? prefix=null) {
			mount_prefix = prefix;
			mounted_pnd_ids = new ArrayList<string>();
			mounted_pnd_name_hash = new HashMap<string, string>();
			pnd_appdata_path_hash = new HashMap<string, string>();
			data = Data.pnd_data();
		}
		~MountSet() {
			unmount_all();
		}

		public signal void pnd_mounting(string name);
		public signal void pnd_mounted(string name);
		public signal void pnd_unmounting(string name);

		public bool has_mounted { get { return (mounted_pnd_name_hash.size > 0); } }

		public bool is_mounted(string pnd_id) {
			return is_pnd_mounted(pnd_id);
		}
		public string? get_mount_id(string pnd_id) {
			if (is_pnd_mounted(pnd_id) == false)
				return null;

			return mounted_pnd_name_hash[pnd_id];
		}
		public string? get_mounted_path(string pnd_id) {
			if (is_pnd_mounted(pnd_id) == false)
				return null;

			return UNION_MOUNT_PATH + mounted_pnd_name_hash[pnd_id];
		}
		public string? get_appdata_path(string pnd_id) {
			var pnd = data.get_pnd(pnd_id);
			if (pnd == null || is_pnd_mounted(pnd.pnd_id) == false)
				return null;

			if (pnd_appdata_path_hash.has_key(pnd.pnd_id) == true)
				return pnd_appdata_path_hash[pnd.pnd_id];

			string path = Pandora.Apps.get_appdata_path(pnd.get_fullpath(), mounted_pnd_name_hash[pnd.pnd_id]);
			if (path != null) {
				pnd_appdata_path_hash[pnd.pnd_id] = path;
				return path;
			}

			return null;
		}

		public bool mount(string unique_id, string pnd_id) {
			var pnd = data.get_pnd(pnd_id);
			if (pnd == null)
				return false;
			if(is_pnd_mounted(pnd.pnd_id) == true)
				return true;

			var name =  unique_id;
			var app = data.get_app(unique_id, pnd_id);
			if (app != null && app.appdata_dirname != null)
				name = app.appdata_dirname;
			if (mount_prefix != null)
				name = mount_prefix + name;

			while (mounted_pnd_ids.size >= MAX_CONCURRENT_MOUNTS) {
				if (unmount(mounted_pnd_ids[0]) == false)
					break;
			}

			pnd_mounting(name);

			if (Pandora.Apps.mount_pnd(pnd.get_fullpath(), name) == false)
				return false;
			
			mounted_pnd_name_hash[pnd.pnd_id] = name;
			mounted_pnd_ids.add(pnd.pnd_id);			

			pnd_mounted(name);
			
			return true;
		}

		public bool unmount(string pnd_id, owned ForallFunc<string>? pre_unmount_action=null) {
			var pnd = data.get_pnd(pnd_id);
			if (pnd == null)
				return false;
			if(is_pnd_mounted(pnd.pnd_id) == false)
				return true;

			var name = mounted_pnd_name_hash[pnd.pnd_id];
			pnd_unmounting(name ?? pnd.pnd_id);
			if (pre_unmount_action != null)
				pre_unmount_action(name);
			
			if (Pandora.Apps.unmount_pnd(pnd.get_fullpath(), mounted_pnd_name_hash[pnd.pnd_id]) == false)
				return false;

			mounted_pnd_name_hash.unset(pnd.pnd_id);
			if (pnd_appdata_path_hash.has_key(pnd.pnd_id) == true)
				pnd_appdata_path_hash.unset(pnd.pnd_id);
			if (mounted_pnd_ids.size > 0) {
				for(int index=mounted_pnd_ids.size-1;index>=0;index--) {
					if (mounted_pnd_ids[index] == pnd.pnd_id)
						mounted_pnd_ids.remove_at(index);
				}
			}
			
			return true;
		}
		public bool unmount_all(owned ForallFunc<string>? pre_unmount_action=null) {
			bool error = false;
			while(mounted_pnd_ids.size > 0) {
				if (unmount(mounted_pnd_ids[0], (owned)pre_unmount_action) == false)
					error = true;
			}
			
			return (error == false);
		}

		bool is_pnd_mounted(string? pnd_id) {
			if (pnd_id == null)
				return false;
			return mounted_pnd_name_hash.has_key(pnd_id);
		}
	}
}
