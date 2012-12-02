/* GameBrowserState.vala
 * 
 * Copyright (C) 2012 nuhrin
 * 
 * This file is part of Pandafe.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *      nuhrin <nuhrin@oceanic.to>
 */

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
			} else {
				all_games.view_type = view.view_type;			
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
		public GameBrowserViewData get_view() {
			return new GameBrowserViewData(view_type);
		}
	}
	public class GameBrowserPlatformState : Object {
		public string folder_id { get; set; }
		public int item_index { get; set; }
		public string? filter { get; set; }
	}
}
