using YamlDB;
using Gee;

namespace yayafe.Tests
{
	public class EnumerableTests : TestSet
	{
		string[] testNames = { "main" };
		public override string[] TestNames { get { return testNames; } }

		protected override TestMethod? GetTestMethod(string testName) {
			switch(testName) {
				case "main":
					return main;
				default:
					return null;
			}
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

		void main() {
			var list = new ArrayList<Foo>();
			list.add(new Foo(1, "One"));
			list.add(new Foo(2, "Two"));
			list.add(new Foo(3, "Three"));
			list.add(new Foo(4, "Four"));
			list.add(new Foo(5, "Five"));
			print("list for test:\n");
			print_iterable(list);

			print("test new Enumerable<Foo>(list).where(p=>p.I%2 != 0):\n");
			var e = new Enumerable<Foo>(list)
				.where(p=>p.I%2 != 0);
			print_iterable(e);

			print("test new Enumerable<Foo>(list).where(p=>p.I%2 == 0).select<int>(p=>p.I):\n");
			var ei = new Enumerable<Foo>(list)
				.where(p=>p.I%2 == 0)
				.select<int>(p=>p.I);
			foreach(var item in ei)
				print("  (int): %d\n", item);
			print("\n");

			print("test new Enumerable<Foo>(list).size():\n  %d\n",
				new Enumerable<Foo>(list).size());
			print("test new Enumerable<Foo>(list).size_where(p=>p.I%2 == 0):\n  %d\n\n",
				new Enumerable<Foo>(list).size_where(p=>p.I%2 == 0));
			print("test new Enumerable<Foo>(list).size_where(p=>p.S.get(0) == 'O':\n  %d\n\n",
				new Enumerable<Foo>(list).size_where(p=>p.S.get(0) == 'O'));

			print("test new Enumerable<Foo>(list).first():\n  %s\n",
				new Enumerable<Foo>(list).first().to_string());
			print("test new Enumerable<Foo>(list).first_where(p=>p.S.get(0) == 'F'):\n  %s\n\n",
				new Enumerable<Foo>(list).first_where(p=>p.S.get(0) == 'F').to_string());

			print("test new Enumerable<Foo>(list).last():\n  %s\n",
				new Enumerable<Foo>(list).last().to_string());
			print("test new Enumerable<Foo>(list).last_where(p=>p.S.get(0) == 'T'):\n  %s\n\n",
				new Enumerable<Foo>(list).last_where(p=>p.S.get(0) == 'T').to_string());

			print("test new Enumerable<Foo>(list).to_list():\n");
			Gee.List<Foo> toListTest = new Enumerable<Foo>(list).to_list();
			print_iterable(toListTest);
			print("test new Enumerable<Foo>(list).to_collection():\n");
			Collection<Foo> toCollectionTest = new Enumerable<Foo>(list).to_collection();
			print_iterable(toCollectionTest);

			print("test new Enumerable<Foo>(list).to_array():\n");
			Foo[] toArrayTest = new Enumerable<Foo>(list).to_array();
			foreach(var item in toArrayTest)
				print("  %s\n", item.to_string());
			print("\n");
		}
		static void print_iterable(Iterable<Foo> items)
		{
			foreach(var item in items)
				print("  %s\n", item.to_string());
			print("\n");
		}
	}
}
