using Gee;
using Catapult;

namespace Data.Pnd
{
	const string UNION_MOUNT_PATH="/mnt/utmp/";
	const string PND_MOUNT_PATH="/mnt/pnd/";

	public class MountSet
	{
		PndData data;
		string mount_prefix;
		HashMap<string, string> mounted_pnd_name_hash;
		HashMap<string, string> pnd_appdata_path_hash;
		public MountSet(string? prefix=null) {
			mount_prefix = prefix;
			mounted_pnd_name_hash = new HashMap<string, string>();
			pnd_appdata_path_hash = new HashMap<string, string>();
			data = Data.pnd_data();
		}
		~MountSet() {
			unmount_all();
		}

		public bool has_mounted { get { return (mounted_pnd_name_hash.size > 0); } }

		public bool is_mounted(string unique_id) {
			return is_pnd_mounted(get_pnd_id(unique_id));
		}
		public string? get_mount_id(string unique_id) {
			unowned string pnd_id = get_pnd_id(unique_id);
			if (is_pnd_mounted(pnd_id) == false)
				return null;

			return mounted_pnd_name_hash[pnd_id];
		}
		public string? get_mounted_path(string unique_id) {
			unowned string pnd_id = get_pnd_id(unique_id);
			if (is_pnd_mounted(pnd_id) == false)
				return null;

			return UNION_MOUNT_PATH + mounted_pnd_name_hash[pnd_id];
		}
		public string? get_appdata_path(string unique_id) {
			var pnd = data.get_pnd(unique_id);
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

		public bool mount(string unique_id) {
			var pnd = data.get_pnd(unique_id);
			if (pnd == null)
				return false;
			if(is_pnd_mounted(pnd.pnd_id) == true)
				return true;

			var name =  unique_id;
			var app = data.get_app(unique_id);
			if (app != null && app.appdata_dirname != null)
				name = app.appdata_dirname;
			if (mount_prefix != null)
				name = mount_prefix + name;

			if (Pandora.Apps.mount_pnd(pnd.get_fullpath(), name) == false)
				return false;
			mounted_pnd_name_hash[pnd.pnd_id] = name;

			return true;
		}

		public bool unmount(string unique_id) {
			var pnd = data.get_pnd(unique_id);
			if (pnd == null)
				return false;
			if(is_pnd_mounted(pnd.pnd_id) == false)
				return true;

			if (Pandora.Apps.unmount_pnd(pnd.get_fullpath(), mounted_pnd_name_hash[pnd.pnd_id]) == false)
				return false;

			mounted_pnd_name_hash.unset(pnd.pnd_id);
			return true;
		}
		public bool unmount_all() {
			var keys = mounted_pnd_name_hash.keys.to_array();
			foreach(string pnd_id in keys) {
				debug("unmounting %s...", mounted_pnd_name_hash[pnd_id]);
				if (unmount(pnd_id) == false)
					return false;
			}
			return true;
		}

		bool is_pnd_mounted(string? pnd_id) {
			if (pnd_id == null)
				return false;
			return mounted_pnd_name_hash.has_key(pnd_id);
		}
		unowned string? get_pnd_id(string unique_id) {
			var pnd = data.get_pnd(unique_id);
			if (pnd != null)
				return pnd.pnd_id;
			return null;
		}

	}
}
