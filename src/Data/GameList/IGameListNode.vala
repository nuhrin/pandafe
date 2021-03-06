/* IGameListNode.vala
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

namespace Data.GameList
{
	public interface IGameListNode : GameListNode
	{
		public abstract Platform platform { get; }
		public abstract GameFolder? parent { get; }

		public abstract unowned string id { get; }
		public abstract unowned string name { get; }
		public abstract unowned string full_name { get; }

		public string unique_name() { return platform.get_unique_node_name(this); }
		public string unique_id() { return platform.get_unique_node_id(this); }
		
		public static int compare(IGameListNode a, IGameListNode b) {
			return Utility.strcasecmp(a.name, b.name);
		}
	}
	public abstract class GameListNode { }
}
