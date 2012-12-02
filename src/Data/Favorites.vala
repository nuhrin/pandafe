/* Favorites.vala
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
	public class Favorites : Entity
	{		
		internal const string ENTITY_ID = "favorites";		

		HashSet<string> _favorite_game_ids;
		
		public signal void changed();
		
		public void add(GameItem game) {
			ensure_hashset();
			_favorite_game_ids.add(game.id);
			changed();
		}
		public void remove(GameItem game) {
			if (_favorite_game_ids == null || _favorite_game_ids.contains(game.id) == false)
				return;
			_favorite_game_ids.remove(game.id);
			changed();
		}
		public bool contains(GameItem game) {
			if (_favorite_game_ids == null)
				return false;
			return _favorite_game_ids.contains(game.id);
		}
		public bool is_empty() { return (_favorite_game_ids == null || _favorite_game_ids.size == 0); }
		
		void ensure_hashset() {
			if (_favorite_game_ids == null)
				_favorite_game_ids = new HashSet<string>();			
		}
		
		// yaml
		protected override string generate_id() { return ENTITY_ID; }

		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var sequence = new Yaml.SequenceNode();
			if (_favorite_game_ids != null) {
				foreach(var id in _favorite_game_ids)
					sequence.add(builder.build_value(id));				
			}
			return sequence;
		}
		protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var sequence = node as Yaml.SequenceNode;
			if (sequence == null)
				return;
				
			if (sequence.item_count() > 0) {
				ensure_hashset();
				foreach(var id_node in sequence.scalars())
					_favorite_game_ids.add(id_node.value);
			}
		}
	}
}
