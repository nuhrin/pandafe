
namespace pandafe.Tests
{
	public class TypeRuntimeTests : TestSet
	{
		string[] testNames = { "properties", "array", "value", "cast" };
		public override string[] TestNames { get { return testNames; } }

		protected override TestMethod? GetTestMethod(string testName) {
			switch(testName) {
				case "properties":
					return test_properties;
				case "array":
					return test_array;
				case "value":
					return test_value;
				case "cast":
					return test_cast;
				default:
					return null;
			}
		}

		static void test_value()
		{
			print("Value.type() tests:\n");
			int i = 5;
			test_value_type(i, "int i = 5");
			var objIn = new ArrayTest(5);
			Value v = objIn;
			test_value_type(v, "new ArrayTest(5)");
			var subObjIn = new SubClass(10);
			test_value_type(subObjIn, "new SubClass(10)");
			print("typeof(SubClass).is_classed()): %s\n", typeof(SubClass).is_classed().to_string());
			var nonObjIn = new NonObjectClass();
			test_value_type(nonObjIn, "new NonObjectClass()");
			var subNonObjIn = new NonObjectSubClass();
			test_value_type(subNonObjIn, "new NonObjectSubClass()");
			print("typeof(NonObjectSubClass).is_a(typeof(NonObjectClass)): %s\n", typeof(NonObjectSubClass).is_a(typeof(NonObjectClass)).to_string());
			print("typeof(NonObjectSubClass).parent()): %s\n", typeof(NonObjectSubClass).parent().name());
			print("typeof(NonObjectSubClass).is_classed()): %s\n", typeof(NonObjectSubClass).is_classed().to_string());
			var struc = Struct();
			test_value_type(struc, "Struct()");
			var subStruc = SubStruct();
			test_value_type(struc, "Struct()");
			test_value_type(subStruc, "SubStruct()");
			print("typeof(SubStruct).is_a(typeof(Struct)): %s\n", typeof(SubStruct).is_a(typeof(Struct)).to_string());
			print("typeof(SubStruct).parent()): %s\n", typeof(SubStruct).parent().name());
			print("typeof(SubStruct).is_classed()): %s\n", typeof(SubStruct).is_classed().to_string());

			print("footype.is_a(typeof(Value))\n");
			print("  int: %s\n", (typeof(int).is_a(typeof(Value))).to_string());
		}
		static void test_value_type(Value v, string desc) {
			print("%s: \n  type().name(): %s\n", desc, v.type().name());
		}
		class NonObjectClass {
		}
		class NonObjectSubClass : NonObjectClass {
		}
		class SubClass : ArrayTest {
			public SubClass(int i) { base(i); }
		}
		struct Struct { public string Foo; }
		struct SubStruct : Struct { }

		static void test_array()
		{
			ArrayTest test = new ArrayTest(5);
			for(int index=0;index<test.Squares.length;index++) {
				print("square[%d]: %d\n", index, test.Squares[index]);
			}
			int[] slice = test.Squares[1:test.Squares.length];
			for(int index=0;index<slice.length;index++) {
				print("slice[%d]: %d\n", index, slice[index]);
			}
			unowned ObjectClass klass = test.get_class();
		    var properties = klass.list_properties();
		    foreach(var prop in properties)
		    {
			    print("property %s type: %s\n", prop.name, prop.value_type.name() );
		    }
			//Type t = test.get_type();
			//if (t == Type.INVALID)
			//	message("Type is invalid.");
			//foreach(var ct in t.children())
			//	print("%s\n", ct.name());
			//Value f = Value(t);
			//print("%s\n", f.type_name());

	//		if (t.is_array())
	//			print("array\n");
		}
		public class ArrayTest : Object {
			public ArrayTest(int num) {
				Squares = new int[num];
				for(int index=0;index<num;index++)
					Squares[index]=index*index;
			}
			public int[] Squares { get; set; }
			public int Integer { get; set; }
			public string[] Strings { get; set; }
			public ArrayTest[] Children { get; set; }
		}

		static void test_properties()
		{
			var test = new Test();
			test.Foo = "lalala";
			test.IFoo = "I'm internal!";
			test.print_properties();
		}
		class Test : Object
		{
		  public Test()
		  {
		    PFoo = "I'm private!";
		  }
		  public string Foo { get;set; }
		  internal string IFoo { get; set; }
		  private string PFoo { get; set; }

		  public void print_properties()
		  {
		    unowned ObjectClass klass = this.get_class();
		    var properties = klass.list_properties();
		    foreach(var prop in properties)
		    {
			    if ((prop.flags & ParamFlags.READWRITE) == ParamFlags.READWRITE)
			    	print("%s\n", prop.get_name());
		    }
		  }

		}

		static void test_cast()
		{
			Foo foo = new Foo();
			Bar bar = new Bar();
			try {
				Foo test = (Foo)bar;
			} catch(Error e) {
			}
		}
		class Foo { }
		class Bar { }
	}
}