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
	public interface IGameListNode : Object, Gee.Comparable<IGameListNode>
	{
		protected abstract GameListProvider provider { get; }
		public abstract GameFolder? parent { get; }

		public abstract string id { get; }
		public abstract string name { get; }
		public abstract string full_name { get; }

		public string unique_name() { return provider.get_unique_name(this); }
		public string unique_id() { return provider.get_unique_id(this); }
		public Platform platform() { return provider.platform; }
	}
}
