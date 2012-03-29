using Gee;
using Data;
using Data.Options;
using Data.Platforms;
using Data.Programs;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class PlatformProgramSettingsMapMenu : Menu  
	{
		public static bool edit(string platform_name, PlatformProgramSettingsMap program_settings, Gee.List<Program> programs) {
			var menu = new PlatformProgramSettingsMapMenu(platform_name, program_settings, programs);
			new MenuBrowser(menu).run();
			return menu.was_saved;
		}
		
		string platform_name;
		Gee.List<Program> programs;
		PlatformProgramSettingsMap original_map;
		PlatformProgramSettingsMap settings_map;
		
		public PlatformProgramSettingsMapMenu(string platform_name, PlatformProgramSettingsMap program_settings, Gee.List<Program> programs) {
			base(platform_name + " Program Settings");
			this.platform_name = platform_name;
			this.programs = programs;			
			original_map = program_settings;
			settings_map = new PlatformProgramSettingsMap.clone(program_settings);
			ensure_items();		
		}
				
		public bool was_saved { get; private set; }
		
		protected override bool do_cancel() {
			was_saved = false;
			return true;
		}
		protected override bool do_save() {
			original_map.clear();
			foreach(var program in programs) {
				var program_id = program.app_id;
				if (settings_map.has_key(program_id) == true)
					original_map[program_id] = settings_map[program_id];
			}
							
			was_saved = true;
			return true;
		}
		protected override void populate_items(Gee.List<MenuItem> items) {
			foreach(var program in programs) {
				var program_id = program.app_id;
				var program_settings = (settings_map.has_key(program_id) == true)
					? settings_map[program_id]
					: new ProgramDefaultSettings();
				var menu_item = new MenuBrowserItem(program.name, null, new ProgramDefaultSettingsMenu(platform_name, program.name, program_settings, program.options));
				menu_item.saved.connect(() => {
					settings_map[program_id] = program_settings;
				});
				items.add(menu_item);				
			}
			
			items.add(new MenuItemSeparator());
			items.add(new MenuItem.cancel_item());
			items.add(new MenuItem.save_item());
		}		
	}
}
