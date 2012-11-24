using Fields;
using Menus.Fields;
using Data.GameList;
using Data.Programs;
using Data.Platforms;

namespace Menus.Concrete
{
	public class GameMenu : Menu  
	{	
		GameItem game;
		Platform platform;
		GameSettingsMenu? settings_menu;
		string? program_name;
		public GameMenu(GameItem game) {
			base("Game: " + game.full_name);
			this.game = game;
			platform = game.platform();
			ensure_items();		
		}
		protected override void do_refresh(uint select_index) {
			clear_items();
			ensure_items();
		}
		protected override void populate_items(Gee.List<MenuItem> items) { 						
			if (platform.supports_game_settings) {
				settings_menu = new GameSettingsMenu(game);
				var settings_menu_item = new MenuBrowserItem("Settings", "Change game settings", settings_menu);
				settings_menu_item.finished.connect(() => {
					if (settings_menu.program_changed == true) {
						refresh(0);
					} else {
						settings_menu = new GameSettingsMenu(game);
						settings_menu_item.set_menu(settings_menu);
					}
				});
				items.add(settings_menu_item);
			}
			
			var favorites_index = items.size;
			var is_favorite = game.is_favorite;
			items.add(new MenuItem.custom("Favorite: " + ((is_favorite) ? "Yes" : "No"), "Mark/Unmark this game as a favorite", null, ()=> {
				game.is_favorite = !is_favorite;
				refresh(favorites_index);
			}));			
			
			items.add(new MenuItemSeparator());
			
			if (platform.platform_type != PlatformType.PROGRAM && game.parent != null)
				items.add(new GameFolderMenu(game.parent, "Show a menu for the folder containing this game"));
			
			if (platform.platform_type == PlatformType.ROM && settings_menu.program != null) {
				program_name = settings_menu.program.name;				
				var program_menu = new ProgramMenu(settings_menu.program);
				var program_item_index = items.size;
				program_menu.saved.connect(() => {
					if (settings_menu.program.name != program_name) {
						program_name = null;
						refresh(program_item_index);
					}
				});
				items.add(program_menu);
			} else if (platform.platform_type == PlatformType.PROGRAM) {
				var program_platform = platform as ProgramPlatform;
				var platform_program_menu = new ProgramMenu(program_platform.program, false, "Show a menu for the current platform program");
				items.add(platform_program_menu);
			};

			var platform_menu = new PlatformMenu(platform);
			var platform_item_index = items.size;
			platform_menu.saved.connect(() => refresh(platform_item_index));			
			items.add(platform_menu);
			
//~ 			items.add(new MenuItem.custom("Run", null, "Running...", () => {
//~ 				game.run();
//~ 			}));
		}		
	}

}
