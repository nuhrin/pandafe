using Gee;
using Catapult;
using Pandora.Apps;

namespace Data.Pnd
{
	public class PndCache : Entity
	{
		public PndCache() {
			pnd_list = Enumerable.empty<PndItem>();
		}
		public PndCache.from_pnds(Gee.List<Pandora.Apps.Pnd> pnds) {
			var items = new ArrayList<PndItem>();
			foreach(var pnd in pnds) {
				var item = new PndItem.from_pnd(pnd);
				items.add(item);
			}
			pnd_list = new Enumerable<PndItem>(items);
		}

		protected override string generate_id() { return PndData.CACHED_DATA_ID; }

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
}
