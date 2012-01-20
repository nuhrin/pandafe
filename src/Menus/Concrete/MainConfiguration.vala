using Gee;
using Catapult;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class MainConfiguration : Menu
	{
		public static void run() {
			new MenuBrowser(new MainConfiguration(), 40, 40).run();
		}
		
		MainConfiguration() { 
			base("Pandafe Configuration");
			ensure_items();
		}
				
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new GameBrowserAppearanceMenu("Appearance", new GameBrowserUI.from_preferences()));
			items.add(GetTestMenu());
			items.add(new MenuItem.cancel_item("Return"));
		}		

		Menu GetTestMenu() {
			var menu = new Menu("test");
			menu.add_item(GetTestSubMenu("Configuration"));
			menu.add_item(GetTestSubMenu("Edit Current Platform"));
			menu.add_item(GetTestSubMenu("Edit Current Program"));
			menu.add_item(new BooleanField("flag", "Flag"));
			menu.add_item(new EnumField("node_type", "NodeType", null, Catapult.Yaml.NodeType.SCALAR));
			menu.add_item(new IntegerField("integer", "Integer", null, 5, 1, 10, 2));
			menu.add_item(new ColorField("color", "Color", null, new Data.Color(0, 0, 0)));
			menu.add_item(new FolderField("folder", "Folder", null, "/home/nuhrin/Desktop"));
			menu.add_item(new FileField("font", "Item Font", null, "/usr/share/fonts/truetype/DejaVuSansMono.ttf", "ttf"));
			menu.add_item(new ObjectField("prefs", "Preferences", null, Data.preferences()));
			menu.add_item(new ObjectField("platform", "Platform", null, Data.platforms()[1]));
			
			var strlist = new ArrayList<string>();
			strlist.add("one");
			strlist.add("two");
			strlist.add("three");
			for(int i=4;i<=15;i++)
				strlist.add(i.to_string());
			menu.add_item(new StringListField("strlist", "Strings", null, strlist));
			
			menu.add_item(new PndCategoryField("category", "Category"));
			menu.add_item(new PndAppField("app_id", "App"));
			menu.add_item(new PlatformListField("platforms", "Platforms", null, Data.platforms(), Data.data_interface()));
			
			menu.add_item(new CustomCommandField("command", "Custom Command", null));
			
			menu.add_item(new MenuItem.cancel_item("Return"));
			menu.add_item(new MenuItem.quit_item());

			return menu;
		}
		Menu GetTestSubMenu(string name) {
			var menu = new Menu(name);
			menu.add_item(new BooleanField("flag", "Flag"));
			menu.add_item(new EnumField("node_type", "NodeType", null, Catapult.Yaml.NodeType.SCALAR));
	//~ 		menu.add_item(new IntegerField("integer", "Integer", null, 5, 1, 10, 2));
	//~ 		menu.add_item(new IntegerField("integer", "Integer", null, 5, 1, 10, 2));
	//~ 		menu.add_item(new IntegerField("integer", "Integer", null, 5, 1, 10, 2));
	//~ 		menu.add_item(new IntegerField("integer", "Integer", null, 5, 1, 10, 2));
			menu.add_item(new IntegerField("integer", "Integer", null, 5, 1, 10, 2));
			menu.add_item(new StringField("string", "String", null, "(string)"));
			
			var ssf = new StringSelectionField("stringselection", "StringS");
			ssf.add_item("Kupo!");
			ssf.add_item("One");
			ssf.add_item("Two");
			ssf.add_item("Three");
			ssf.add_item("4");
			ssf.add_item("5");
			ssf.add_item("6");
			ssf.add_item("7");
			ssf.add_item("8");
			ssf.add_item("9");
			ssf.add_item("10");
			ssf.add_item("11");
			ssf.add_item("12");
			ssf.add_item("13");
			ssf.add_item("14");
			ssf.add_item("15");
			ssf.add_item("16");
			ssf.add_item("17");
			ssf.add_item("18");
			ssf.add_item("19");
			ssf.add_item("20");
			ssf.value = "Two";
			menu.add_item(ssf);
			
			menu.add_item(new MenuItem.save_item());
			menu.add_item(new MenuItem.cancel_item());
			return menu;
		}
	
	}
}
