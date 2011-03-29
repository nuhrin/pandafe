using YamlDB;
using YamlDB.Helpers;
using Gee;

namespace yayafe.Tests
{
	public class IndirectGenericsTests : TestSet
	{
		string[] testNames = { "map" };
		public override string[] TestNames { get { return testNames; } }

		protected override TestMethod? GetTestMethod(string testName) {
			switch(testName) {
				case "map":
					return test_map;
				default:
					return null;
			}
		}

		void test_map() {
			var map = new HashMap<string,Foo>();
			Type key_type = IndirectGenericsHelper.Gee.Map.key_type(map);
			Type value_type = IndirectGenericsHelper.Gee.Map.value_type(map);

			var indirect_map = IndirectGenericsHelper.Gee.Map.indirect(key_type, value_type);
			indirect_map.set(map, "Hello", new Foo(42, "World!"));
			string kin = "Hello";
			Value vout = indirect_map.get(map, kin);
			Foo f = ValueHelper.extract_value<Foo>(vout);
			stdout.printf("%s, %s\n", kin, f.S);
		}

		class Foo : Object
		{
			public Foo(int i, string s)
			{
				I = i;
				S = s;
			}
			public int I { get; private set; }
			public string S { get; private set; }
			public string to_string() {
				return "Foo: " + I.to_string() + ", " + S;
			}
		}
	}
}