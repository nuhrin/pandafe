/* GameItem.vala
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

using Catapult;
using Data.Platforms;
using Data.Programs;

namespace Data.GameList
{
	public class GameItem : YamlObject, Gee.Comparable<IGameListNode>, IGameListNode
	{
		string _name;
		GameListProvider _provider;
		GameFolder _parent;
		string? _id;
		string? _full_name;

		public static GameItem create(string name, GameListProvider provider, GameFolder parent, string? id=null, string? full_name=null) {
			GameItem game = new GameItem();
			game._name = name;
			game._provider = provider;
			game._parent = parent;
			game._id = id;
			game._full_name = full_name;
			return game;
		}
		public static void set_provider(GameItem game, GameListProvider provider) { game._provider = provider; }
		public static void set_parent(GameItem game, GameFolder parent) { game._parent = parent; }
		public static void set_full_name(GameItem game, string full_name) { game._full_name = full_name; }

		protected GameListProvider provider { get { return _provider; } }
		public GameFolder? parent { get { return _parent; } }

		public string id { get { return (_id != null) ? _id : _name; } }
		public string name { get { return _name; } }
		public string full_name { get { return (_full_name != null) ? _full_name : _name; } }

		public bool is_favorite 
		{
			get { return Data.favorites().contains(this); }
			set {
				var favorites = Data.favorites();
				if (value == false) {
					if (favorites.contains(this) == false)
						return;
					favorites.remove(this);
				} else {
					favorites.add(this);
				}
				Data.save_favorites();
			}
		}

		public SpawningResult run() { return provider.run_game(this); }
		public Program? get_program() { return provider.get_program_for_game(this); }

		// yaml
		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var mapping = new Yaml.MappingNode();
			if (_id != null)
				builder.add_item_to_mapping("id", _id, mapping);
			builder.add_item_to_mapping("name", _name, mapping);
			if (_full_name != null)
				builder.add_item_to_mapping("full-name", _full_name, mapping);

			return mapping;
		}
		protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return;

 			var keys = mapping.scalar_keys();
			foreach(var key_node in keys) {
				var value_node = mapping[key_node] as Yaml.ScalarNode;
				if (value_node != null) {
					switch(key_node.value) {
						case "id":
							_id = value_node.value;
							break;
						case "name":
							_name = value_node.value;
							break;
						case "full-name":
							_full_name = value_node.value;
							break;
						default:
							break;
					}
				}
			}
		}


		public int compare_to(IGameListNode other) {
			return Utility.strcasecmp(this.name, other.name);
		}
	}
}
