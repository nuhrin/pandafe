/* GameFolderCache.vala
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

namespace Data.GameList
{
	public class GameFolderCache : Entity
	{
		public const string YAML_ID = "children";

		construct {
			subfolders = new ArrayList<string>();
			games = new ArrayList<GameItem>();
		}

		public ArrayList<string> subfolders { get; set; }
		public ArrayList<GameItem> games { get; set; }

		protected override string generate_id() { return YAML_ID; }


	}
}
