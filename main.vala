using Gee;
using YamlDB;
using YamlDB.Yaml.Events;
using YamlDB.Helpers;

public class Person : Entity 
{
	protected override string generate_id()
		{
			string id = LastName + "_" + FirstName;
			return RegexHelper.NonWordCharacters.replace(id, "")	;
		}
	public string FirstName { get; set; }
	public string LastName { get; set; }
	public uint Age { get; set; }
	public string FavoriteColor { get; set; }
}


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
		if (options.Testset != null) {
			TestRunner.run_requested_tests(options);
			return 0;
		}


		Gtk.init(ref args);
		
		DataInterface db = new DataInterface("DialogTest");				
		var dialog = new EntityDialog<Person>(db);
		dialog.destroy.connect (Gtk.main_quit);
		dialog.show ();
		//dialog.run();
		Gtk.main ();
		return 0;
	}
}
