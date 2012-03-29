using Gee;
using Data.Pnd;
using Data.Platforms;

namespace Data.GameList
{
	public class PndList : GameListProvider
	{
		ArrayList<string> main_categories;
		HashMap<string, NativePlatformCategory> platform_category_hash;
		PndData pnddata;
		
		public PndList() {
			base(Data.platforms().get_native_platform());
			pnddata = Data.pnd_data();
			init_categories();
		}
		void init_categories() {					
			main_categories = new ArrayList<string>();
			platform_category_hash = new HashMap<string, NativePlatformCategory>();
			var native_platform = platform as NativePlatform;
			foreach(var category in native_platform.categories) {
				if (pnddata.get_category(category.name) != null) {
					main_categories.add(category.name);
					platform_category_hash[category.name] = category;
				}
			}
			if (main_categories.size == 0)
				main_categories.add_all(pnddata.get_main_category_names().to_list());
		}
		
		public override SpawningResult run_game(GameItem game) {
			var ids = game.id.split("|");
			var pnd = pnddata.get_pnd(ids[0]);
			if (pnd != null) {
				var app = pnd.apps.where(a=>a.id == ids[1]).first();
				if (app != null)
					return Spawning.spawn_app(app);				
			}
			return new SpawningResult.error("Unable to run pnd '%s' (%s).".printf(game.name, game.id));
		}
		
		public override string get_unique_name(IGameListNode node) {
			if (node is GameItem || node.parent == null || node.parent.name == "")
				return node.name;
			return "%s/%s".printf(node.parent.name, node.name);
		}
		public override string get_unique_id(IGameListNode node) {
			if (node is GameItem || node.parent == null || node.parent.id == "")
				return node.id;
			return "%s/%s".printf(node.parent.id, node.id);
		}
		protected override void rescan_init() {
			init_categories();
		}


		protected override bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games) {
			var folder_list = new ArrayList<GameFolder>();
			var game_list = new ArrayList<GameItem>();
			add_subfolders(folder, folder_list);
			child_folders = folder_list;
			add_games(folder, game_list);
			child_games = game_list;
			return true;
		}

		protected override GameFolder create_root_folder() {
			if (main_categories.size == 1)
				return new GameFolder.root("", this, main_categories[0]);

			return new GameFolder.root(platform.name, this, "");
		}

		void add_subfolders(GameFolder folder, ArrayList<GameFolder> folder_list) {
			if (folder.id == "") {
				foreach(var category in main_categories)
					folder_list.add(new GameFolder(category, this, root_folder));
			} else if (folder.parent == null || folder.parent.id == "") {
				var native_category = platform_category_hash[folder.id];
				var excluded_hash = new HashSet<string>();
				excluded_hash.add_all(native_category.excluded_subcategories);
				var category = pnddata.get_category(folder.id);
				if (category != null) {
					foreach(var subcategory in category.subcategories) {
						if (excluded_hash.contains(subcategory.name) == false)
							folder_list.add(new GameFolder(subcategory.name, this, folder));
					}
				}
			}
			folder_list.sort();
		}
		void add_games(GameFolder folder, ArrayList<GameItem> game_list) {
			if (folder.id == "")
				return;

			CategoryBase category = null;
			NativePlatformCategory native_category = null;
			if (folder.parent == null || folder.parent.id == "") {
				category = pnddata.get_category(folder.id);
				if (category != null)
					native_category = platform_category_hash[category.name];
			} else {
				var main_category = pnddata.get_category(folder.parent.id);
				if (main_category != null) {
					native_category = platform_category_hash[main_category.name];
					category = main_category.get_subcategory(folder.id);
				}
			}

			if (category != null) {
				var excluded_hash = new HashSet<string>();
				excluded_hash.add(Config.PND_APP_ID);
				if (native_category != null)
					excluded_hash.add_all(native_category.excluded_apps);				
				var title_game_hash = new HashMap<string, GameItem?>();
				var title_packageid_hash = new HashMap<string, string>();
				foreach(var app in category.apps) {
					if (excluded_hash.contains(app.id) == true)
						continue;
					GameItem game = GameItem.create(app.title, this, folder, "%s|%s".printf(app.package_id, app.id));
					if (title_game_hash.has_key(app.title) == true) {
						var old_game_item = title_game_hash[app.title];
						if (old_game_item != null) {
							GameItem.set_full_name(old_game_item, "%s (%s)".printf(app.title, title_packageid_hash[app.title]));
							title_game_hash[app.title] = null;
						}
						GameItem.set_full_name(game, "%s (%s)".printf(app.title, app.package_id));
					} else {
						title_game_hash[app.title] = game;
						title_packageid_hash[app.title] = app.package_id;
					}
					game_list.add(game);
				}
				game_list.sort();
			}
		}
	}
}
