using Gee;
using Catapult;
using Catapult.Gui;
using Catapult.Gui.Fields;
using Catapult.Gui.Fieldsets;

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

		public string current_platform { get; set; }
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
		public void apply_all_games_state(bool active, int item_index, string? filter) {
			if (all_games == null)
				all_games = new AllGamesState();
			all_games.active = active;
			all_games.item_index = item_index;
			all_games.filter = filter;
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
	}
	public class GameBrowserPlatformState : Object {
		public string folder_id { get; set; }
		public int item_index { get; set; }
		public string? filter { get; set; }
	}
}
