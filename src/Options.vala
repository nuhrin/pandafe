
public class Options
{
	static string testset;
	static const OptionEntry[] options = {
		{ "run-test", 't', 0, OptionArg.STRING, ref testset, "Run a test", "TESTSET TEST (TEST2 ...)" },
		{ null }
	};

	public static Options parse (ref unowned string[] args) throws OptionError
	{
		OptionContext context = new OptionContext("");
		context.set_help_enabled(true);
		context.set_ignore_unknown_options(true);
		context.add_main_entries(options, null);
		context.parse(ref args);

		var options = new Options();

		if (testset != null) {
			options.Testset = testset;
			testset = null;
			options.TestsToRun = (args.length > 1) ? args[1:args.length] : new string[0];
		}

		return options;
	}

	public string Testset { get; private set; }
	public string[] TestsToRun { get; private set; }
}