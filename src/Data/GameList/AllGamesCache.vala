/* AllGamesCache.vala
 * 
 * Copyright (C) 2013 nuhrin
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
	public class AllGamesCache : Entity
	{
		public const string YAML_ID = "everything";

		construct {
			platforms = new ArrayList<PlatformNode>();
		}

		public Gee.List<PlatformNode> platforms { get; set; }
		
		protected override string generate_id() { return YAML_ID; }
		
		public class PlatformNode : FolderNodeBase
		{
			construct {
				subfolders = new ArrayList<FolderNode>();
				games = new ArrayList<GameItem>();
			}
			public string id { get; set; }

			protected override void add_additional_properties(Yaml.MappingNode mapping, Yaml.NodeBuilder builder) {
				builder.add_object_property_to_mapping(this, "id", mapping);
			}
		}
		public class FolderNode : FolderNodeBase
		{
			construct {
				subfolders = new ArrayList<FolderNode>();
				games = new ArrayList<GameItem>();
			}
			public string name { get; set; }
			
			protected override void add_additional_properties(Yaml.MappingNode mapping, Yaml.NodeBuilder builder) {
				builder.add_object_property_to_mapping(this, "name", mapping);
			}
		}
		public abstract class FolderNodeBase : YamlObject
		{
			public Gee.List<GameItem> games { get; set; }
			public Gee.List<FolderNode> subfolders { get; set; }
						
			protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
				var mapping = new Yaml.MappingNode();
				add_additional_properties(mapping, builder);
				builder.add_object_property_to_mapping(this, "games", mapping);
				builder.add_object_property_to_mapping(this, "subfolders", mapping);
				return mapping;
			}
			protected abstract void add_additional_properties(Yaml.MappingNode mapping, Yaml.NodeBuilder builder);
		}
	}	
}
