using YamlDB;
using Gee;

namespace yayafe.Tests
{
	public class EnumerableTests : TestSet
	{
		string[] testNames = { "main", "of_type" };
		public override string[] TestNames { get { return testNames; } }

		protected override TestMethod? GetTestMethod(string testName) {
			switch(testName) {
				case "main":
					return main;
				case "of_type":
					return of_type;
				default:
					return null;
			}
		}

		class Foo
		{
			public Foo(int i, string s)
			{
				I = i;
				S = s;
			}
			public int I { get; private set; }
			public string S { get; private set; }
			public string to_string() {
				return name() + ": " + I.to_string() + ", " + S;
			}
			protected virtual string name() { return "Foo"; }
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
		}

		static void of_type()
		{
			var list = new ArrayList<Value?>();
			list.add(new Foo(1, "One"));
			list.add(new Foo(2, "Two"));
			list.add(new Bar(3, "Three"));
			list.add("kupo!");
			list.add(10);
			list.add(new Baz(4, "Four"));
			list.add(new Bar(5, "Five"));
			list.add(20);

			var foo1 = SFoo();
			var foo2 = SFoo();
			var bar1 = SBar();
			var bar2 = SBar();
			var list2 = new ArrayList<Value?>();
			list2.add(foo1);
			list2.add(foo2);
			list2.add(bar1);

			var e = new Enumerable<Value?>(list).concat(list2);

			print("all items: \n");
			print_iterable_values(e);

			print("foo items: \n");
			print_iterable_values(e.of_type<Foo>());

			print("bar items: \n");
			print_iterable_values(e.of_type<Bar>());

			print("baz items: \n");
			print_iterable_values(e.of_type<Baz>());

			print("string items: \n");
			print_iterable_values(e.of_type<string>());

			print("int items: \n");
			print_iterable_values(e.of_type<int>());

			print("SFoo items: \n");
			print_iterable_values(e.of_type<SFoo>());

			print("SBar items: \n");
			print_iterable_values(e.of_type<SBar>());
		}
		static void print_iterable_values(Iterable<Value?> items)
		{
			foreach(Value item in items) {
				if (item.holds(typeof(string)))
					print("  %s\n", (string)item);
				else if (item.holds(typeof(int)))
					print("  %d\n", (int)item);
				else if (item.holds(typeof(Foo)))
					print("  %s\n", ((Foo)item).to_string());
				else
					print("(%s)\n", type_name(item));
			}
			print("\n");
		}
		static string type_name(Value value) { return (value.type().is_object()) ? value.get_object().get_type().name() : value.type().name(); }
		class Bar : Foo
		{
			public Bar(int i, string s)
			{
				base(i, s);
			}
			protected override string name() { return "Bar"; }
		}

		class Baz : Object
		{
			public Baz(int i, string s)
			{
			}
		}
		struct SFoo
		{
			public int I { get; private set; }
			public string S { get; private set; }
		}
		struct SBar : SFoo {
		}
		struct SBaz  {
			public int B { get; private set; }
		}
	}
}
