using Catapult;

namespace pandafe.Tests
{
	public delegate void TestMethod();
	public abstract class TestSet : Object
	{
		public void run_all()
		{
			foreach(var testName in TestNames)
				run_test(testName);
		}
		public void run_test(string test)
		{
			string type = this.get_type().name();
			string msg = @"Running $type test \"$test\":";
			print("%s\n", msg);
			print("%s\n", string.nfill(msg.length, '*'));
			TestMethod method = GetTestMethod(test);
			if (method == null)
				print("[Test method not found.]\n");
			else
				method();
			print("\n");
		}
		public bool has_test(string test)
		{
			foreach(string valid in TestNames) {
				if (valid.up() == test.up())
					return true;
			}
			return false;
		}
		public abstract string[] TestNames { get; }
		protected abstract TestMethod? GetTestMethod(string testName);
	}

}