
namespace yayafe.Tests
{
	public class TypeRuntimeTests : TestSet
	{
		string[] testNames = { "properties", "array" };
		public override string[] TestNames { get { return testNames; } }

		protected override TestMethod? GetTestMethod(string testName) {
			switch(testName) {
				case "properties":
					return test_properties;
				case "array":
					return test_array;
				default:
					return null;
			}
		}


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
	}
}