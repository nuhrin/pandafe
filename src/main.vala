using Gee;
using YamlDB;
using YamlDB.Yaml.Events;
using YamlDB.Helpers;

public enum FavoriteColor {
	NONE,
	RED,
	ORANGE,
	PERSIMON,
	YELLOW,
	GREEN,
	BLUE,
	INDIGO,
	VIOLET
}
public class Person : Entity 
{
	protected override string generate_id()
	{
		string id = last_name + "_" + first_name;
		return RegexHelper.NonWordCharacters.replace(id, "")	;
	}
	[Description(nick="First Name")]
	public string first_name { get; set; }
	[Description(nick="Last Name")]
	public string last_name { get; set; }
	[Description(nick="Age")]
	public int age { get; set; }
	[Description(nick="Favorite _Color")]
	public FavoriteColor favorite_color { get; set; }
	[Description(nick="Has _Wonder")]
	public bool has_wonder { get; set; }
	[Description(nick="Sho_e Size")]
	public double shoe_size { get; set; }
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
//		if (options.Testset != null) {
//		TestRunner.run_requested_tests(options);
//		return 0;
//		}


		Gtk.init(ref args);

		try {
			DataInterface db = new DataInterface("DialogTest");
	//		foreach(var person in db.load_all<Person>())
	//			EntityDialog.edit<Person>(db, person);
			Person p = EntityDialog.create<Person>(db);
			if (p != null)
				EntityDialog.edit<Person>(db, p);
		}
		catch (Error e) {
			print("Fatal: %s\n", e.message);
		}

		return 0;
	}
}
