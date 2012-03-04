using Gee;
using Catapult;
namespace Data
{
	public class Preferences : Entity
	{		
		internal const string ENTITY_ID = "preferences";		

		public GameBrowserAppearance appearance { get; set; }
		
		// yaml
		protected override string generate_id() { return ENTITY_ID; }

		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			if (appearance == null)
				appearance = new GameBrowserAppearance.default();
			
			return base.build_yaml_node(builder);
		}
		protected override bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			bool result = base.apply_yaml_node(node, parser);
			if (appearance == null)
				appearance = new GameBrowserAppearance.default();
			return result;
		}
	}
}
