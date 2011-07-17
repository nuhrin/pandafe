using Gee;
using Catapult;
using Pandora.Apps;

public class PndAppItem : YamlObject
{
	public PndAppItem() { }
	public PndAppItem.from_app(App app) {
		id = app.id;
		title = app.title;
		description = app.description;
		clockspeed = app.clockspeed;
		exec_command = app.exec_command ?? "";
		exec_arguments = app.exec_arguments ?? "";
		main_category = app.main_category ?? "";
		main_category1 = app.main_category1 ?? "";
		main_category2 = app.main_category2 ?? "";
		alt_category = app.alt_category ?? "";
		alt_category1 = app.alt_category1 ?? "";
		alt_category2 = app.alt_category2 ?? "";
	}
	public string id { get; set; }
	public string title { get; set; }
	public string description { get; set; }
	public int clockspeed { get; set; }
	public string exec_command { get; set; }
	public string exec_arguments { get; set; }
	public string main_category { get; set; }
	public string main_category1 { get; set; }
	public string main_category2 { get; set; }
	public string alt_category { get; set; }
	public string alt_category1 { get; set; }
	public string alt_category2 { get; set; }

	protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
		return builder.build_object_mapping(this);
	}
	protected override bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
		parser.populate_object(node as Yaml.MappingNode, this);
		return true;
	}
}
public class PndItem : YamlObject
{
	public PndItem() {
		apps = Enumerable.empty<PndAppItem>();
	}
	public PndItem.from_pnd(Pnd pnd) {
		pnd_id = pnd.id;
		filename = pnd.filename;
		path = pnd.path;

		var items = new ArrayList<PndAppItem>();
		foreach(var app in pnd.apps) {
			var item = new PndAppItem.from_app(app);
			items.add(item);
		}
		apps = new Enumerable<PndAppItem>(items);
	}
	public string pnd_id { get; set; }
	public string filename { get; set; }
	public string path { get; set; }
	public string fullpath() { return path + filename; }

	public Enumerable<PndAppItem> apps { get; private set; }

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
				var app_list = new ArrayList<PndAppItem>();
				var apps_node = map.Mappings[key] as Yaml.SequenceNode;
				foreach(var app_node in apps_node.Items) {
					var item = (PndAppItem)parser.parse_value_of_type(app_node, typeof(PndAppItem), null);
					if (item != null)
						app_list.add(item);
				}
				apps = new Enumerable<PndAppItem>(app_list);
			}
			else
				parser.populate_object_property(map, key, this);
		}
		return true;
	}
}
public class PndData : Entity
{
	const string DATA_ID = "pnd_data";
	const string DATA_FOLDER = "";

	public static Enumerable<PndItem> get_pnds(DataInterface data_interface) {
		PndData data = null;
		try {
			data = data_interface.load<PndData>(DATA_ID, DATA_FOLDER);
		}
		catch (Error e) {
			debug("Error while retrieving pnd data: %s", e.message);
		}

		return (data == null) ? Enumerable.empty<PndItem>() : new Enumerable<PndItem>(data.pnd_list);
	}
	public static Enumerable<PndItem> rescan_pnds(DataInterface data_interface, string? overrides_path=null) {
		Pandora.Apps.scan_pnds(overrides_path);
		var data = new PndData.from_pnds(Pandora.Apps.get_all_pnds());
		data_interface.save(data, DATA_ID, DATA_FOLDER);
		Pandora.Apps.clear_pnd_cache();
		return data.pnd_list;
	}

	public PndData() {
		pnd_list = Enumerable.empty<PndItem>();
	}
	public PndData.from_pnds(Gee.List<Pnd> pnds) {
		var items = new ArrayList<PndItem>();
		foreach(var pnd in pnds) {
			var item = new PndItem.from_pnd(pnd);
			items.add(item);
		}
		pnd_list = new Enumerable<PndItem>(items);
	}

	protected override string generate_id() { return DATA_ID; }

	public Enumerable<PndItem> pnd_list { get; private set; }

	protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
		var sequence = new Yaml.SequenceNode();
		foreach(var pnd in pnd_list) {
			var pnd_node = builder.build_yaml_object(pnd);
			sequence.Items.add(pnd_node);
		}
		return sequence;
	}
	protected override bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
		var sequence = node as Yaml.SequenceNode;
		var list = new ArrayList<PndItem>();
		foreach(var childNode in sequence.Items) {
			var item = (PndItem)parser.parse_value_of_type(childNode, typeof(PndItem), null);
			if (item != null)
				list.add(item);
		}
		pnd_list = new Enumerable<PndItem>(list);
		return true;
	}
}
