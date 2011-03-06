using Gee;
using YamlDB;
using YamlDB.Entity;
using YamlDB.Yaml.Events;
using YamlDB.Helpers;

public class MainClass: Object {
	static Options options;
	public static int main (string[] args)
	{
		try {
			options = Options.parse(ref args);
		} catch(OptionError e) {
			print("%s\n", e.message);
			return 1;
		}
		if (options.Testset != null)
			TestRunner.run_requested_tests(options);



		return 0;
	}
}
