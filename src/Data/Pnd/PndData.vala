using Gee;
using Catapult;

namespace Data.Pnd
{
	public class PndData
	{
		internal const string CACHED_DATA_ID = "pnd_cache";
		internal const string CACHED_DATA_FOLDER = "";

		DataInterface data_interface;
		ArrayList<PndItem> pnd_list;
		HashMap<string, PndItem> pnd_id_hash;
		HashMap<string, AppItem> app_id_hash;
		HashMap<string, PndItem> app_id_pnd_hash;
		public PndData(DataInterface data_interface, PndCache? cache=null) {
			this.data_interface = data_interface;
			if (cache != null)
				reload_from_cache(cache);
		}

		public void rescan() {
			Pandora.Apps.scan_pnds();
			var cache = new PndCache.from_pnds(Pandora.Apps.get_all_pnds());

			try {
				data_interface.save(cache, CACHED_DATA_ID, CACHED_DATA_FOLDER);
			} catch (Error e) {
				debug("Error while saving pnd data cache: %s", e.message);
			}
			Pandora.Apps.clear_pnd_cache();
			reload_from_cache(cache);
		}
		void reload_from_cache(PndCache cache) {
			pnd_list = new ArrayList<PndItem>();
			pnd_id_hash = new HashMap<string, PndItem>();
			app_id_hash = new HashMap<string, AppItem>();
			app_id_pnd_hash = new HashMap<string, PndItem>();

			foreach(var pnd in cache.pnd_list) {
				pnd_list.add(pnd);
				pnd_id_hash[pnd.pnd_id] = pnd;
				foreach(var app in pnd.apps) {
					app_id_hash[app.id] = app;
					app_id_pnd_hash[app.id] = pnd;
				}
			}
		}

		public Enumerable<PndItem> get_all_pnds() {
			return new Enumerable<PndItem>(pnd_list);
		}
		public PndItem? get_pnd(string id) {
			if (app_id_pnd_hash.has_key(id) == true)
				return app_id_pnd_hash[id];
			if (pnd_id_hash.has_key(id) == true)
				return pnd_id_hash[id];

			return null;
		}
		public Enumerable<AppItem> get_pnd_apps(string pnd_id) {
			var pnd = get_pnd(pnd_id);
			if (pnd != null)
				return new Enumerable<AppItem>(pnd.apps);
			return Enumerable.empty<AppItem>();
		}
		public AppItem? get_app(string id) {
			if (app_id_hash.has_key(id) == true)
				return app_id_hash[id];
			return null;
		}
	}
}
