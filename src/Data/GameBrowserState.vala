using Gee;
using Catapult;

namespace Data
{
	public class GameBrowserState : Entity
	{
		internal const string ENTITY_ID = "browser_state";
		protected override string generate_id() { return ENTITY_ID; }

		construct {
			platform_state = new HashMap<string, GameBrowserPlatformState>();
			all_games = new AllGamesState();
		}

		public string? current_platform_folder { get; set; } 
		public int platform_folder_item_index { get; set; }
		public string? current_platform { get; set; }
		protected Map<string, GameBrowserPlatformState> platform_state { get; set; }
		public AllGamesState all_games { get; set; }
		public void apply_platform_state(Platform platform, string? folder_id, int item_index, string? filter) {
			var ps = new GameBrowserPlatformState();
			if (folder_id != null)
				ps.folder_id = folder_id;
			ps.item_index = item_index;
			if (filter != null)
				ps.filter = filter;
			platform_state[platform.id] = ps;
		}
		public void apply_all_games_state(bool active, int item_index, string? filter, GameBrowserViewData? view) {
			if (all_games == null)
				all_games = new AllGamesState();
			all_games.active = active;
			all_games.item_index = item_index;
			all_games.filter = filter;
			if (view == null) {
				all_games.view_type = GameBrowserViewType.ALL_GAMES;
				all_games.view_platform_folder = null;
			} else {
				all_games.view_type = view.view_type;			
				all_games.view_platform_folder = (view.platform_folder != null) ? view.platform_folder.path() : null;
			}
		}
		public string? get_current_platform_folder_id() {
			if (current_platform == null || platform_state.has_key(current_platform) == false)
				return null;
			return platform_state[current_platform].folder_id;
		}
		public int get_current_platform_item_index() {
			if (current_platform == null || platform_state.has_key(current_platform) == false)
				return -1;
			return platform_state[current_platform].item_index;
		}
		public string? get_current_platform_filter() {
			if (current_platform == null || platform_state.has_key(current_platform) == false)
				return null;
			return platform_state[current_platform].filter;
		}
	}
	public class AllGamesState : Object {
		public bool active { get; set; }
		public int item_index { get; set; }
		public string? filter { get; set; }
		public GameBrowserViewType view_type { get; set; }
		public string? view_platform_folder { get; set; }
		public GameBrowserViewData get_view() {
			if (view_type == GameBrowserViewType.PLATFORM_FOLDER_GAMES) {
				if (view_platform_folder != null) {
					var folder = Data.platforms().get_platform_folder_data().get_folder(view_platform_folder);
					if (folder != null)
						return new GameBrowserViewData.folder(folder);
				}
				return new GameBrowserViewData(GameBrowserViewType.BROWSER);
			}
			return new GameBrowserViewData(view_type);
		}
	}
	public class GameBrowserPlatformState : Object {
		public string folder_id { get; set; }
		public int item_index { get; set; }
		public string? filter { get; set; }
	}
}
