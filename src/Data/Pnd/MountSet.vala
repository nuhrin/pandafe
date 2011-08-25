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

		public bool is_mounted(string pnd_id) {
			return (mounted_pnd_name_hash.has_key(pnd_id));
		}

		public string? get_mounted_path(string pnd_id) {
			if (is_mounted(pnd_id) == false)
				return null;

			return UNION_MOUNT_PATH + mounted_pnd_name_hash[pnd_id];
		}
		public string? get_mount_id(string pnd_id) {
			if (is_mounted(pnd_id) == false)
				return null;

			return mounted_pnd_name_hash[pnd_id];
		}

		public string? get_appdata_path(string pnd_id) {
			if (is_mounted(pnd_id) == false)
				return null;
			if (pnd_appdata_path_hash.has_key(pnd_id) == true)
				return pnd_appdata_path_hash[pnd_id];

			var pnd = data.get_pnd(pnd_id);
			if (pnd != null) {
				string path = Pandora.Apps.get_appdata_path(pnd.get_fullpath(), mounted_pnd_name_hash[pnd_id]);
				pnd_appdata_path_hash[pnd_id] = path;
				return path;
			}

			return null;
		}

		public bool mount(string pnd_id, string? mount_id=null) {
			if (is_mounted(pnd_id) == false) {
				var pnd = data.get_pnd(pnd_id);
				if (pnd == null)
					return false;
				string path = pnd.get_fullpath();
				var name = mount_id ?? File.new_for_path(path).get_basename();
				if (mount_prefix != null)
					name = mount_prefix + name;

				if (Pandora.Apps.mount_pnd(path, name) == false)
					return false;
				mounted_pnd_name_hash[pnd_id] = name;
			}
			return true;
		}

		public bool unmount(string pnd_id) {
			if (is_mounted(pnd_id) == false)
				return true;

			if (unmount_real(pnd_id) == false)
				return false;
			mounted_pnd_name_hash.unset(pnd_id);
			return true;
		}
		public bool unmount_all() {
			var keys = mounted_pnd_name_hash.keys.to_array();
			foreach(string pnd_id in keys) {
				debug("unmounting %s...", pnd_id);
				if (unmount(pnd_id) == false)
					return false;
			}
			return true;
		}

		bool unmount_real(string pnd_id) {
			var pnd = data.get_pnd(pnd_id);
			if (pnd == null)
				return false;
			string path = pnd.get_fullpath();
			var name = mounted_pnd_name_hash[pnd_id];

			return Pandora.Apps.unmount_pnd(path, name);
		}

	}
}
