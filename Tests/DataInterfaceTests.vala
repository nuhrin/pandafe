using YamlDB;
using Gee;

namespace yayafe.Tests
{
	public class DataInterfaceTests : TestSet
	{
		string[] testNames = { "write", "read" };
		public override string[] TestNames { get { return testNames; } }
		protected override TestMethod? GetTestMethod(string testName) {
			switch(testName) {
				case "write":
					return write;
				case "read":
					return read;
				default:
					return null;
			}
		}

		class Emulator : NamedEntity
		{
			public override string get_yaml_tag() { return "Emulator"; }
			public string ExePath { get; set; }
			public DateTime Date { get; set; }
		}
		class System : NamedEntity
		{
			construct {
				Emulators = new ArrayList<Emulator>();
			}
			public DateTime Date { get; set; }
			public Emulator PrimaryEmu { get; set; }
			public Gee.List<Emulator> Emulators { get; set; }
		//	public HashMap<Emulator,int> EmuHash { get; set; }
		}

		void read()
		{
	//		var emus = new ArrayList<Emulator>();
	//		emus.add(new Emulator() { Name = "mednafen", ExePath="/usr/bin/mednafen" });
	//		emus.add(new Emulator() { Name = "xmess", ExePath="/usr/bin/Xmess" });
	//		var foo = new System() { Name="Nes", PrimaryEmu = emus[0], Emulators = new Enumerable<Emulator>(emus)};
	//
	//		print("%d\n", foo.Emulators.count());
			//string config_folder = Environment.get_user_config_dir();
			//string data_folder = Path.build_filename(config_folder, "yayafe");
			string data_folder = "DataInterfaceTest";
			DataInterface db = new DataInterface(data_folder);
			//var emus = db.load_all<Emulator>();
			//foreach(var e in emus)
			//	print("Emu: %s\n", e.Name);
			var systems = db.load_all<System>();
			foreach(var s in systems) {
				print("System: Name: %s\n", s.Name);
				print("        Date: %s\n", s.Date.to_string());
				print("  PrimaryEmu: %s\n", s.PrimaryEmu.Name);
				print("   Emulators:\n");
				foreach(var e in s.Emulators)
				{
					print("   -    Name: %s\n", e.Name);
					print("     ExePath: %s\n", e.ExePath);
				}
			}
		}

		void write()
		{
			//string config_folder = Environment.get_user_config_dir();
			//string data_folder = Path.build_filename(config_folder, "yayafe");
			string data_folder = "DataInterfaceTest";
			DataInterface db = new DataInterface(data_folder);
			var emus = db.load_all<Emulator>();
			System nes = new System() { Name="Nes", PrimaryEmu = emus.first(), Emulators = emus.to_list() };
			var emuHash = new HashMap<Emulator,int>();
			var index = 0;
			foreach(var emu in emus) {
				emuHash[emu] = index;
				index++;

			}
	//		nes.EmuHash = emuHash;
			//nes.Date = new DateTime.now_local();
			nes.Date = new DateTime.now_local();
			foreach(var emu in emus) {
				emu.Date = new DateTime.now_local();
				db.save(emu);
			}
			db.save(nes);

		}
	}
}
