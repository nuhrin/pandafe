using Gee;
using Catapult;

namespace Data.Pnd
{
	public class PndItem : YamlObject
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

		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var map = new Yaml.MappingNode();
			builder.add_mapping(map, "pnd_id", pnd_id);
			builder.add_mapping(map, "filename", filename);
			builder.add_mapping(map, "path", path);
			var apps_node = new Yaml.SequenceNode();
			foreach(var app in apps) {
				var app_node = builder.build_yaml_object(app);
				apps_node.Items.add(app_node);
			}
			var appsKey = builder.build_value("apps");
			map.Mappings[appsKey] = apps_node;
			return map;
		}
		protected override bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var map = node as Yaml.MappingNode;
			foreach(var key in map.Mappings.scalar_keys()) {
				if (key.Value == "apps") {
					var app_list = new ArrayList<AppItem>();
					var apps_node = map.Mappings[key] as Yaml.SequenceNode;
					foreach(var app_node in apps_node.Items) {
						var item = (AppItem)parser.parse_value_of_type(app_node, typeof(AppItem), null);
						if (item != null) {
							item.set_pnd(this);
							app_list.add(item);
						}
					}
					apps = new Enumerable<AppItem>(app_list);
				}
				else
					parser.populate_object_property(map, key, this);
			}
			return true;
		}
	}
}
