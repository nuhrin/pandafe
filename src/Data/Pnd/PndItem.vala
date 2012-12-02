/* PndItem.vala
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

namespace Data.Pnd
{
	public class PndItem : YamlObject, Comparable<PndItem>
	{
		public PndItem() {
			apps = Enumerable.empty<AppItem>();
		}
		public PndItem.from_pnd(Pandora.Apps.Pnd pnd) {
			pnd_id = pnd.id;
			filename = pnd.filename;
			path = pnd.path;

			var items = new ArrayList<AppItem>();
			foreach(var app in pnd.apps) {
				var item = new AppItem.from_app(app);
				item.set_pnd(this);
				items.add(item);
			}
			apps = new Enumerable<AppItem>(items);
		}
		public string pnd_id { get; set; }
		public string filename { get; set; }
		public string path { get; set; }
		public string get_fullpath() { return path + filename; }

		public Enumerable<AppItem> apps { get; private set; }
		public AppItem? get_app(string id) {
			foreach(var app in apps) {
				if (app.id == id)
					return app;
			}
			return null;
		}

		public int compare_to(PndItem other) { return strcmp(pnd_id, other.pnd_id); }

		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var map = new Yaml.MappingNode();
			builder.add_item_to_mapping("pnd_id", pnd_id, map);
			builder.add_item_to_mapping("filename", filename, map);
			builder.add_item_to_mapping("path", path, map);
			var apps_node = new Yaml.SequenceNode();
			foreach(var app in apps) {
				var app_node = builder.build_yaml_object(app);
				apps_node.add(app_node);
			}
			var appsKey = builder.build_value("apps");
			map[appsKey] = apps_node;
			return map;
		}
		protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var map = node as Yaml.MappingNode;
			foreach(var key in map.scalar_keys()) {
				if (key.value == "apps") {
					var app_list = new ArrayList<AppItem>();
					var apps_node = map[key] as Yaml.SequenceNode;
					foreach(var app_node in apps_node.items()) {
						var item = (AppItem)parser.parse_value_of_type(app_node, typeof(AppItem));
						if (item != null) {
							item.set_pnd(this);
							app_list.add(item);
						}
					}
					apps = new Enumerable<AppItem>(app_list);
				}
				else
					parser.set_object_property(this, key.value, map[key]);
			}
		}
	}
}
