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
		ArrayList<string> main_category_name_list;
		HashMap<string, Category> category_name_hash;

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
			main_category_name_list = null;
			category_name_hash = null;

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

		public Enumerable<string> get_main_category_names() {
			ensure_category_data();
			return new Enumerable<string>(main_category_name_list);
		}
		public Enumerable<Category> get_main_categories() {
			return get_main_category_names().select<Category>(name=> category_name_hash[name]);
		}
		public Category? get_category(string main_category_name) {
			ensure_category_data();
			if (category_name_hash.has_key(main_category_name) == true)
				return category_name_hash[main_category_name];
			return null;
		}

		void ensure_category_data() {
			if (main_category_name_list != null)
				return;

			main_category_name_list = new ArrayList<string>();
			category_name_hash = new HashMap<string, Category>();

			foreach(var pnd in pnd_list) {
				foreach(var app in pnd.apps) {
					string main_category = app.main_category;
					Category category = null;
					if (category_name_hash.has_key(main_category) == false) {
						main_category_name_list.add(main_category);
						category = new Category(main_category);
						category_name_hash[main_category] = category;
					} else {
						category = category_name_hash[main_category];
					}
					string subcategory1 = app.subcategory1;
					string subcategory2 = app.subcategory2;
					bool has_subcategory = (subcategory1 != "" || subcategory2 != "");
					if (has_subcategory == false) {
						category.add_app(app);
					} else {
						if (subcategory1 != "") {
							var sub1 = category.ensure_subcategory(subcategory1);
							sub1.add_app(app);
						}
						if (subcategory2 != "") {
							var sub2 = category.ensure_subcategory(subcategory2);
							sub2.add_app(app);
						}
					}
				}
			}
		}
	}
}
