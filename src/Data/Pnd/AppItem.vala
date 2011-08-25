using Catapult;

namespace Data.Pnd
{
	public class AppItem : YamlObject
	{
		public AppItem() { }
		public AppItem.from_app(Pandora.Apps.App app) {
			id = app.id;
			title = app.title;
			description = app.description;
			clockspeed = app.clockspeed;
			exec_command = app.exec_command ?? "";
			exec_arguments = app.exec_arguments ?? "";
			startdir = app.startdir ?? "";
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
		public uint clockspeed { get; set; }
		public string exec_command { get; set; }
		public string exec_arguments { get; set; }
		public string startdir { get; set; }
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
}
