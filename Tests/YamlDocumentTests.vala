using YamlDB;
using YamlDB.Yaml;

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
			MappingNode node = new MappingNode();
			OrderedMappingSet set = node.Mappings;
			set.ScalarKeyCompareFunc = (a,b)=> {
				if (a.Value == "Name")
					return -1;
				else if (b.Value == "Name")
					return 1;
				else
					return 0;
			};
			add_mapping(set, "Z", "zzz");
			add_mapping(set, "kupo?", "kupo!");
			add_mapping(set, "a", "aaa");
			add_mapping(set, "Name", "aaa");

			foreach(var item in set.scalar_keys())
				print("key: %s\n", item.Value);
			print("\nYaml:\n");
			print(get_yaml(node));
		}

		static void add_mapping(OrderedMappingSet mapping, string key, string value) {
			YamlDB.Yaml.Node keyNode = new ScalarNode(null, null, key);
			YamlDB.Yaml.Node valueNode = new ScalarNode(null, null, value);
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