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
