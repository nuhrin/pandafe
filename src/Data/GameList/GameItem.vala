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
	public class GameItem : GameListNode, IGameListNode
	{
		string _name;
		Platform _platform;
		GameFolder _parent;
		string? _id;
		string? _full_name;

		public static GameItem create(string name, Platform platform, GameFolder parent, string? id=null, string? full_name=null) {
			GameItem game = new GameItem();
			game._name = name;
			game._platform = platform;
			game._parent = parent;
			game._id = id;
			game._full_name = full_name;
			return game;
		}
		public static void set_platform(GameItem game, Platform platform) { game._platform = platform; }
		public static void set_parent(GameItem game, GameFolder parent) { game._parent = parent; }
		public static void set_full_name(GameItem game, string full_name) { game._full_name = full_name; }

		public Platform platform { get { return _platform; } }
		public GameFolder? parent { get { return _parent; } }

		public unowned string id { get { if (_id != null) return _id; return _name; } }
		public unowned string name { get { return _name; } }
		public unowned string full_name { get { if (_full_name != null) return _full_name; return _name; } }

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

		public SpawningResult run() { return platform.run_game(this); }
		public Program? get_program() { return platform.get_program_for_game(this); }

		// yaml
		public Yaml.Node to_yaml_node(Yaml.NodeBuilder builder, string id_key="id") {
			var mapping = new Yaml.MappingNode();
			if (_id != null)
				builder.add_item_to_mapping(id_key, _id, mapping);
			builder.add_item_to_mapping("name", _name, mapping);
			if (_full_name != null)
				builder.add_item_to_mapping("full-name", _full_name, mapping);

			return mapping;
		}
		public unowned StringBuilder add_cache_line(StringBuilder sb, string? parent_id) {
			if (parent_id == null)
				return sb.append("g||%s||%s||%s\n".printf(_name, _id ?? "", _full_name ?? ""));
			return sb.append("g||%s||%s||%s||%s\n".printf(parent_id, _name, _id ?? "", _full_name ?? ""));
		}
		public static GameItem? from_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return null;

			var item = new GameItem();
 			var keys = mapping.scalar_keys();
			foreach(var key_node in keys) {
				var value_node = mapping[key_node] as Yaml.ScalarNode;
				if (value_node != null) {
					switch(key_node.value) {
						case "id":
							item._id = value_node.value;
							break;
						case "name":
							item._name = value_node.value;
							break;
						case "full-name":
							item._full_name = value_node.value;
							break;
						default:
							break;
					}
				}
			}			
			if (item._name == null)
				return null;
				
			return item;
		}
	}
}
