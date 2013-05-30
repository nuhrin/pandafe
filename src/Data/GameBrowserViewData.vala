/* GameBrowserViewData.vala
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

using Data.Platforms;

namespace Data
{
	public enum GameBrowserViewType {
		ALL_GAMES,
		FAVORITES,
		MOST_RECENT,
		MOST_PLAYED,
		CATEGORY,
		PLATFORM,
		PLATFORM_LIST,
		PLATFORM_FOLDER
	}
	public class GameBrowserViewData {
		string _name;
		string _help;
		bool _involves_everything;
		public GameBrowserViewData(GameBrowserViewType view_type) {
			this.view_type = view_type;
			switch(view_type) {
				case GameBrowserViewType.ALL_GAMES:
					_name = "All Games";
					_help = "Show all games";
					_involves_everything = true;
					break;
				case GameBrowserViewType.FAVORITES:
					_name = "Favorites";
					_help = "Show games marked as favorites";
					_involves_everything = true;
					break;
				case GameBrowserViewType.MOST_RECENT:
					_name = "Most Recent";
					_help = "Show games played, ordered by when last played";
					_involves_everything = true;
					break;
				case GameBrowserViewType.MOST_PLAYED:
					_name = "Most Played";
					_help = "Show games played, ordered by play count";
					_involves_everything = true;
					break;
				case GameBrowserViewType.CATEGORY:
					_name = "Category";
					_help = "Show games for the current category";
					break;
				case GameBrowserViewType.PLATFORM:
					_name = "Platform";
					_help = "Show games for the current platform";
					break;
				case GameBrowserViewType.PLATFORM_LIST:
					_name = "Platform List";
					_help = "Show list of all (enabled) platforms";
					break;
				case GameBrowserViewType.PLATFORM_FOLDER:
					_name = "Platform Folders";
					_help = "Show grouped list of platforms";
					break;
				default:
					GLib.error("Unsupported GameBrowserViewType");
			}
		}
		public GameBrowserViewType view_type { get; private set; }
		public unowned string name { get { return _name; } }
		public unowned string help { get { return _help; } }
		public bool involves_everything { get { return _involves_everything; } }
		
		public bool equals(GameBrowserViewData? other) {
			if (other == null)
				return false;
			return (view_type == other.view_type);			
		}
	}
}
