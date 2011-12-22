using Gee;
using Catapult;

using Menus.Fields;

namespace Menus.Concrete
{
	public class MainConfiguration : Menu
	{
		static MainConfiguration instance;
		public static void run() {
			if (instance == null)
				instance = new MainConfiguration();
			else
				instance.RefreshFromPreferences();
			
			var browser = new MenuBrowser(instance, 40, 40);			
			browser.menu_changed.connect((menu) => {
				if (menu is AppearanceMenu) {
					browser.push_layer(instance.demo_selector);
				} else {
					browser.remove_layer(instance.demo_selector.id);
				}
				browser.update();
			});
			browser.run();
		}
		
		MainConfiguration() { 
			base("Pandafe Configuration"); 
			demo_selector = new DemoSelector(100, 300);
			demo_selector.select_item(1);
			ensure_items();
		}
		
		public void RefreshFromPreferences() {
			appearance.RefreshFromPreferences();
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			appearance = new AppearanceMenu();
			items.add(appearance);
			items.add(GetTestMenu());
			items.add(new MenuItem.cancel_item("Return"));
		}
		
		AppearanceMenu appearance;
		DemoSelector demo_selector;
		
		class AppearanceMenu : Menu  
		{
			public AppearanceMenu() {
				base("Appearance");				
			}
			
			public void RefreshFromPreferences() {
				initialize_from_preferences();
			}
			
			public override bool save() {
				var prefs = Data.preferences();
				bool has_color_change = false;
				if (item_color.has_changes()) {
					prefs.item_color = item_color.value;
					has_color_change = true;
				}
				if (selected_item_color.has_changes()) {
					prefs.selected_item_color = selected_item_color.value;
					has_color_change = true;
				}
				if (background_color.has_changes()) {
					prefs.background_color = background_color.value;
					has_color_change = true;
				}
				
				bool has_font_change = false;
				
				if (has_color_change == false && has_font_change == false)
					return true;
			
				bool success = Data.save_preferences();
				// TODO: display error if there was a problem saving prefs?
				if (success) {
					if (has_color_change == true)
						@interface.update_colors_from_preferences();
					if (has_font_change == true)
						@interface.update_fonts_from_preferences();					
				}
				
				return true;
			}
			
			protected override void populate_items(Gee.List<MenuItem> items) { 
				item_color = new ColorField("item_color", "Item Color");
				selected_item_color = new ColorField("selected_item_color", "Selected Item Color");
				background_color = new ColorField("background_color", "Background Color");
				items.add(item_color);
				items.add(selected_item_color);
				items.add(background_color);
				items.add(new MenuItem.cancel_item());
				items.add(new MenuItem.save_item());
				initialize_from_preferences();
			}
			void initialize_from_preferences() {
				ensure_items();
				var prefs = Data.preferences();
				item_color.value = prefs.item_color;
				selected_item_color.value = prefs.selected_item_color;
				background_color.value = prefs.background_color;
			}
			
			ColorField item_color;
			ColorField selected_item_color;
			ColorField background_color;
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
	
		class DemoSelector : Selector 
		{
			string[] items;

			public DemoSelector(int16 xpos, int16 ypos) {
				base("demo_selector", xpos, ypos);
				items = new string[] {
					"Item 1",
					"Selected Item",
					"Item 3",
					"Item 4",
					"Item 5"
//~ 					"Item 6",
//~ 					"Item 7",
//~ 					"Item 8",
//~ 					"Item 9",
//~ 					"Item 10"
				};
			}

			protected override int get_itemcount() { return items.length; }
			protected override string get_item_name(int index) { return items[index]; }
			protected override string get_item_full_name(int index) { return get_item_name(index); }
		}
	}
}
