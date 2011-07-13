using Catapult;
using Catapult.Yaml;

namespace yayafe.Tests
{
	public class YamlDocumentTests : TestSet
	{
		string[] testNames = { "OrderedMappingSet" };
		public override string[] TestNames { get { return testNames; } }

		protected override TestMethod? GetTestMethod(string testName) {
			switch(testName) {
				case "OrderedMappingSet":
					return test_orderedmappingset;
				default:
					return null;
			}
		}

		static void test_orderedmappingset() {
			MappingNode node = new MappingNode(null, null, false, MappingStyle.FLOW);
			OrderedMappingSet set = node.Mappings;
			set.ScalarKeyCompareFunc = (a,b)=> {
				if (a.Value == "Name")
					return -1;
				else if (b.Value == "Name")
					return 1;
				else
					return 0;
			};
			var seq = new SequenceNode(null, null, false);
			seq.Items.add(new ScalarNode(null, null, "1"));
			seq.Items.add(new ScalarNode(null, null, "2"));
			seq.Items.add(new ScalarNode(null, null, "3"));

			add_mapping(set, "Z", "zzz");
			add_mapping(set, "kupo?", "kupo!");
			node.Mappings[seq] = new ScalarNode(null, null, "123");
			add_mapping(set, "a", "aaa");
			add_mapping(set, "Name", "aaa");

			var last = set.sorted_keys().last();
			print("last ");
			print_keynode(last);
			var last_scalar = set.sorted_keys().last_where(p=>p.Type == NodeType.SCALAR);
			print("last scalar ");
			print_keynode(last_scalar);

			foreach(var item in set.sorted_keys())
				print_keynode(item);

			print("\nYaml:\n");
			print(get_yaml(node));
		}
		static void print_keynode(Yaml.Node key) {
			switch(key.Type) {
				case NodeType.SCALAR:
					print("key: %s\n", (key as ScalarNode).Value);
					break;
				case NodeType.MAPPING:
					print("key: (mapping)\n");
					break;
				case NodeType.SEQUENCE:
					print("key: (sequence)\n");
					break;
				default:
					break;
			}
		}

		static void add_mapping(OrderedMappingSet mapping, string key, string value) {
			Catapult.Yaml.Node keyNode = new ScalarNode(null, null, key);
			Catapult.Yaml.Node valueNode = new ScalarNode(null, null, value);
			mapping[keyNode] = valueNode;

		}
		static string get_yaml(MappingNode mapping) throws YamlError
		{
			StringBuilder sb = new StringBuilder();
			var writer = new Yaml.DocumentWriter.to_string_builder(sb);
			var document = new Yaml.Document(mapping);
			writer.write_document(document);
			writer.flush();
			return sb.str;
		}

	}
}