using yayafe.Tests;
using Gee;

public static class TestRunner {

	static HashMap<string, TestSet> _testsetHash;
	static HashMap<string, TestSet>	TestsetHash {
		get {
			if (_testsetHash == null) {
				_testsetHash = new HashMap<string, TestSet>();
				_testsetHash["DataInterface"] = new DataInterfaceTests();
				_testsetHash["Enumerable"] = new EnumerableTests();
				_testsetHash["IndirectGenerics"] = new IndirectGenericsTests();
				_testsetHash["TypeRuntime"] = new TypeRuntimeTests();
				_testsetHash["YamlDocument"] = new YamlDocumentTests();
			}
			return _testsetHash;
		}
	}

	static TestSet? get_testset(string testset) {
		foreach(string key in TestsetHash.keys) {
			if (key.up() == testset.up())
				return TestsetHash[key];
		}
		return null;
	}

	public static void run_all_tests(string testset) {
		var ts = get_testset(testset);
		if (ts == null) {
			print("TestSet not found: %s\n", testset);
			print_testsets();
			return;
		}
		ts.run_all();
	}
	public static void run_test(string testset, string test) {
		var ts = get_testset(testset);
		if (ts == null) {
			print("TestSet not found: %s\n", testset);
			print_testsets();
			return;
		}
		foreach(var valid in ts.TestNames) {
			if (valid.up() == test.up()) {
				ts.run_test(valid);
				return;
			}
		}
		print("Test not found in %s: %s\n", testset, test);
		print_tests(ts);
	}

	public static void run_requested_tests(Options options) {
		if (options == null || options.Testset == null)
			return;
		var ts = get_testset(options.Testset);
		if (ts == null) {
			print("TestSet not found: %s\n", options.Testset);
			print_testsets();
			return;
		}
		if (options.TestsToRun.length == 0) {
			print("No %s test specified.\n", options.Testset);
			print_tests(ts);
			return;
		}

		foreach(var test in options.TestsToRun)
		{
			if (test == "all") {
				run_all_tests(options.Testset);
				return;
			}
		}
		string invalidTests = null;
		foreach(string test in options.TestsToRun) {
			if (ts.has_test(test) == false)
				invalidTests = (invalidTests == null) ? test : invalidTests + " " + test;
		}
		if (invalidTests != null) {
			print("Test not found in %s: %s\n", options.Testset, invalidTests);
			print_tests(ts);
			return;
		}
		foreach(string test in options.TestsToRun)
			ts.run_test(test);
	}

	static void print_testsets()
	{
		print("Valid sets: ");
		foreach(string key in TestsetHash.keys)
			print("%s ", key);
		print("\n");
	}
	static void print_tests(TestSet testset)
	{
		print("Valid tests: all ");
		foreach(string test in testset.TestNames)
			print("%s ", test);
		print("\n");
	}

}

