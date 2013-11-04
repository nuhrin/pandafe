/* GamesRunList.vala
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
using Data.GameList;

namespace Data
{
	public class GamesRunList : Entity
	{
		internal const string ENTITY_ID = "games_runlist";
		protected override string generate_id() { return ENTITY_ID; }

		construct {
			games_list = new LinkedList<Entry>();
			games_run = games_list;
		}
		
		LinkedList<Entry> games_list;
		public Gee.Queue<Entry> games_run { get; set; }
		
		public void increment_run_count(GameItem game) {
			string game_id = game.unique_id();
			int index = index_of_game(game_id);
			Entry entry;
			if (index == -1) {
				entry = new Entry() { 
					id = game_id, 
					run_count = 1
				};
			} else {
				entry = games_list.remove_at(index);
				entry.run_count++;
				
			}
			games_list.insert(0, entry);
		}
		
		public Enumerable<GameItem> get_most_recently_played(Iterable<GameItem> games) {
			var id_map = create_game_id_hash(games);
			return new Enumerable<Entry>(games_list)
				.where(e=>id_map.has_key(e.id))
				.select<GameItem>(e=>id_map[e.id]);
		}
		public Enumerable<GameItem> get_most_frequently_played(Iterable<GameItem> games) {
			var id_map = create_game_id_hash(games);
			return new Enumerable<Entry>(games_list)
				.where(e=>id_map.has_key(e.id))
				.sort((a,b) => (int)b.run_count - (int)a.run_count)
				.select<GameItem>(e=>id_map[e.id]);
		}

		public bool change_id(string old_id, string new_id) {
			bool success = false;
			var matching = new Enumerable<Entry>(games_list)
				.where(e=>e.id == old_id);
			foreach(var entry in matching) {
				entry.id = new_id;
				success = true;
			}
			return success;
		}
		
		int index_of_game(string game_id) {
			int index = 0;
			foreach(var entry in games_list) {
				if (entry.id == game_id)
					return index;
				index++;
			}
			return -1;
		}
		
		Map<string, GameItem> create_game_id_hash(Iterable<GameItem> games) {
			var map = new HashMap<string, GameItem>();
			foreach(var game in games)
				map[game.unique_id()] = game;
			return map;
		}
		
		public class Entry : Object {
			public string id { get; set; }
			public uint run_count { get; set; }
		}
	}
}
