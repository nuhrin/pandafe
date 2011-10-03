using Gee;
using Data.Pnd;

namespace Data.GameList
{
	public class PndList : GameListProvider
	{
		ArrayList<string> main_categories;
		HashMap<string, NativePlatformCategory> platform_category_hash;
		PndData pnddata;
		public PndList() {
			base(Data.native_platform());
			pnddata = Data.pnd_data();
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

		public override uint run_game(GameItem game) {
			var ids = game.id.split("|");
			var pnd = pnddata.get_pnd(ids[0]);
			if (pnd != null) {
				var app = pnd.apps.first_where(a=>a.id == ids[1]);
				if (app != null) {
					return app.execute();
				}
			}
			debug("Unable to run pnd '%s' (%s).", game.name, game.id);
			return -1;
		}

		public override string get_unique_id(GameListNode node) {
			if (node is GameItem || node.parent == null || node.parent.id == "")
				return node.id;
			return "%s/%s".printf(node.parent.id, node.id);
		}

		public override bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games) {
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
				return new GameFolder.root(main_categories[0], this, main_categories[0]);

			return new GameFolder.root(platform.name, this, "");
		}

		void add_subfolders(GameFolder folder, ArrayList<GameFolder> folder_list) {
			if (folder.id == "") {
				foreach(var category in main_categories)
					folder_list.add(new GameFolder(category, this, root_folder));
			} else if (folder.parent == null || folder.parent.id == "") {
				var category = pnddata.get_category(folder.id);
				if (category != null) {
					foreach(var subcategory in category.subcategories)
						folder_list.add(new GameFolder(subcategory.name, this, folder));
				}
			}
			folder_list.sort((CompareFunc?)GameListNode.compare);
		}
		void add_games(GameFolder folder, ArrayList<GameItem> game_list) {
			if (folder.id == "")
				return;

			CategoryBase category = null;
			if (folder.parent == null || folder.parent.id == "") {
				category = pnddata.get_category(folder.id);
			} else {
				var main_category = pnddata.get_category(folder.parent.id);
				if (main_category != null)
					category = main_category.get_subcategory(folder.id);
			}

			if (category != null) {
				var title_game_hash = new HashMap<string, GameItem?>();
				var title_packageid_hash = new HashMap<string, string>();
				foreach(var app in category.apps) {
					GameItem game = new GameItem(app.title, this, folder, "%s|%s".printf(app.package_id, app.id));
					if (title_game_hash.has_key(app.title) == true) {
						var old_game_item = title_game_hash[app.title];
						if (old_game_item != null) {
							old_game_item.full_name = "%s (%s)".printf(app.title, title_packageid_hash[app.title]);
							title_game_hash[app.title] = null;
						}
						game.full_name = "%s (%s)".printf(app.title, app.package_id);
					} else {
						title_game_hash[app.title] = game;
						title_packageid_hash[app.title] = app.package_id;
					}
					game_list.add(game);
				}
				game_list.sort((CompareFunc?)GameListNode.compare);
			}
		}
	}
}