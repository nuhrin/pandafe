using Gee;
using YamlDB;
using YamlDB.Gui;
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
//		if (options.Testset != null) {
//		TestRunner.run_requested_tests(options);
//		return 0;
//		}

		yayafe.libpndtest.test_search();
		return 0;

		Gtk.init(ref args);

		try {
			DataInterface db = new DataInterface("DialogTest");
			//create_emu_entities(db);
//~ 			foreach(var person in db.load_all<Person>())
//~ 				EntityDialog.edit<Person>(db, person);
//~ 			Person p = EntityDialog.create<Person>(db);
//~ 			if (p != null)
//~ 				EntityDialog.edit<Person>(db, p);
			EntityDialog.create<Program>(db);
		}
		catch (Error e) {
			print("Fatal: %s\n", e.message);
		}

		return 0;
	}

	static void create_emu_entities(DataInterface db) {
//~ 		var emus = new ArrayList<Emulator>();
//~ 		emus.add(new Emulator() { Name = "Mednafen", exe_path="/usr/bin/mednafen" });
//~ 		emus.add(new Emulator() { Name = "Xmess", exe_path="/usr/bin/Xmess" });
//~ 		var nes = new System() { Name="Nes", primary_emu = emus[0], emulators = emus};
//~ 		foreach(var emu in nes.emulators) {
//~ 			//emu.date = Date();
//~ 			db.save(emu);
//~ 		}
//~ 		db.save(nes);
	}
}
