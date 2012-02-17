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
		HashMap<string, ArrayList<PndItem>> app_id_pnd_list_hash;
		ArrayList<string> main_category_name_list;
		HashMap<string, Category> category_name_hash;
		ArrayList<AppItem> categoryless_app_list;

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
			app_id_pnd_list_hash = new HashMap<string, ArrayList<PndItem>>();
			main_category_name_list = null;
			category_name_hash = null;
			categoryless_app_list = null;

			foreach(var pnd in cache.pnd_list) {
				pnd_list.add(pnd);
				pnd_id_hash[pnd.pnd_id] = pnd;
				foreach(var app in pnd.apps) {
					if (app_id_pnd_list_hash.has_key(app.id) == false)
						app_id_pnd_list_hash[app.id] = new ArrayList<PndItem>();
					app_id_pnd_list_hash[app.id].add(pnd);
				}
			}
			foreach(var app_id in app_id_pnd_list_hash.keys)
				app_id_hash[app_id] = app_id_pnd_list_hash[app_id].get(0).get_app(app_id);			
		}

		public Enumerable<PndItem> get_all_pnds() {
			return new Enumerable<PndItem>(pnd_list);
		}
		public PndItem? get_pnd(string id) {
			if (pnd_id_hash.has_key(id) == true)
				return pnd_id_hash[id];

			return null;
		}
		public Enumerable<AppItem> get_pnd_apps(string pnd_id) {
			var pnd = get_pnd(pnd_id);
			if (pnd != null)
				return pnd.apps;
			return Enumerable.empty<AppItem>();
		}
		public AppItem? get_app(string id, string? pnd_id=null, AppIdType id_type=AppIdType.EXACT) {
			if (id == "")
				return null;
			PndItem? pnd = null;
			if (pnd_id != null)
				pnd = get_pnd(pnd_id);
				
			if (id_type == AppIdType.EXACT) {
				if (pnd != null)
					return pnd.get_app(id);
				if (app_id_hash.has_key(id) == true)
					return app_id_hash[id];
				return null;
			}
						
			Regex regex = null;
			if (id_type == AppIdType.REGEX) {
				try {
					regex = new Regex(id);
				} catch(RegexError e) {
					return null;
				}
			}
			
			Enumerable<AppItem> apps = (pnd != null)
				? pnd.apps
				: new Enumerable<AppItem>(app_id_hash.values);
									
			foreach(var app in apps) {
				if (regex != null) {
					if (regex.match(app.id) == true)
						return app;
				} else if (id_type == AppIdType.PREFIX) {
					if (app.id.has_prefix(id) == true)
						return app;
				} else if (id_type == AppIdType.SUFFIX) {
					if (app.id.has_suffix(id) == true)
						return app;
				}
			}
			
			return null;
		}
		public Enumerable<AppItem> get_matching_apps(string id, AppIdType id_type=AppIdType.EXACT) {
			if (id == "")
				return Enumerable.empty<AppItem>();
			
			var list = new ArrayList<AppItem>();
			
			if (id_type == AppIdType.EXACT) {
				if (app_id_hash.has_key(id) == true) {
					list.add(app_id_hash[id]);
					return new Enumerable<AppItem>(list);
				}
				return Enumerable.empty<AppItem>();
			}
			
			Regex regex = null;
			if (id_type == AppIdType.REGEX) {
				try {
					regex = new Regex(id);
				} catch(RegexError e) {
					return Enumerable.empty<AppItem>();
				}
			}
			
			var apps = new Enumerable<AppItem>(app_id_hash.values)
				.sort((a,b) => {
					int retval = strcmp(a.title, b.title);
					if (retval == 0)
						retval = b.id.length - a.id.length;
					return retval;
				});
									
			foreach(var app in apps) {
				if (regex != null) {
					if (regex.match(app.id) == true)
						list.add(app);
				} else if (id_type == AppIdType.PREFIX) {
					if (app.id.has_prefix(id) == true)
						list.add(app);
				} else if (id_type == AppIdType.SUFFIX) {
					if (app.id.has_suffix(id) == true)
						list.add(app);
				}
			}
			
			return new Enumerable<AppItem>(list);			
		}
		
		public Enumerable<PndItem> get_app_pnds(string app_id) {
			if (app_id_pnd_list_hash.has_key(app_id) == true)
				return new Enumerable<PndItem>(app_id_pnd_list_hash[app_id]);
			return Enumerable.empty<PndItem>();
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
		public CategoryBase? get_category_from_path(string path) {
			string[] parts = path.split("/");
			if (parts.length > 0) {
				var main = get_category(parts[0]);
				if (main != null) {
					if (parts.length == 1)
						return main;
					else if (parts.length == 2)
						return main.get_subcategory(parts[1]);
				}					
			}
			return null;
		}
		
		public CategoryBase? get_app_category(AppItem app) {				
			var maincat = get_category(app.main_category);
			if (maincat == null)
				return null;
				
			if (app.subcategory1 != "") {
				var sub1 = maincat.get_subcategory(app.subcategory1);
				if (sub1 != null)
					return sub1;
			}
			if (app.subcategory1 != "") {
				var sub2 = maincat.get_subcategory(app.subcategory2);
				if (sub2 == null)
					return sub2;
			}
			
			return maincat;
		}

		void ensure_category_data() {
			if (main_category_name_list != null)
				return;

			main_category_name_list = new ArrayList<string>();
			category_name_hash = new HashMap<string, Category>();
			categoryless_app_list = new ArrayList<AppItem>();
			
			foreach(var pnd in pnd_list) {
				foreach(var app in pnd.apps) {
					string main_category = app.main_category;
					if (main_category == "") {
						categoryless_app_list.add(app);
						continue;
					}
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
