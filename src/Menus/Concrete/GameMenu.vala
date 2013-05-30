/* GameMenu.vala
 * 
 * Copyright (C) 2012 nuhrin
 * 
 * This file is part of Pandafe.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *      nuhrin <nuhrin@oceanic.to>
 */

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
		GameNodeMenuData menu_data;
		Platform platform;
		GameSettingsMenu? settings_menu;
		string? program_name;
		public GameMenu(GameItem game, GameNodeMenuData menu_data) {
			base("Game: " + game.full_name);
			this.game = game;
			this.menu_data = menu_data;
			platform = game.platform;
		}

		protected override void populate_items(Gee.List<MenuItem> items) { 						
			if (platform.supports_game_settings) {
				settings_menu = new GameSettingsMenu(game);
				var settings_menu_item = new MenuBrowserItem("Settings", "Change game settings", settings_menu);
				item_connect(settings_menu_item, (item)=> ((MenuBrowserItem)item).finished.connect(() => {
					if (settings_menu.program_changed == true) {
						refresh(0);
					} else {
						settings_menu = new GameSettingsMenu(game);
						settings_menu_item.set_menu(settings_menu);
					}
				}));
				items.add(settings_menu_item);
			}
			
			var favorites_index = items.size;
			var is_favorite = game.is_favorite;
			items.add(new MenuItem.custom("Favorite: " + ((is_favorite) ? "Yes" : "No"), "Mark/Unmark this game as a favorite", null, ()=> {
				game.is_favorite = !is_favorite;
				refresh(favorites_index);
			}));			
			
			items.add(new MenuItemSeparator());
			
			if (platform.platform_type == PlatformType.ROM) {
				items.add(new RomFileMenu(game, menu_data));
				items.add(new MenuItemSeparator());
			} else if (platform.platform_type == PlatformType.NATIVE) {
				var ovr_item_index = items.size;
				items.add(new MenuItem.custom("Edit OVR", "Edit override information (.ovr)", null, () => {
					try {
						var app = (platform as NativePlatform).get_game_app(game);
						var app_override = new Data.Pnd.AppOverride(app);				
						if (ObjectMenu.edit("App: " + app.id, app_override) == true) {
							game.parent.rescan_children();
							this.title = "Game: " + app.title;
							refresh(ovr_item_index);
						}
					} catch(GLib.Error e) {
						this.error(e.message);
					}						
				}));
			}
			
			if (platform.platform_type != PlatformType.PROGRAM && game.parent != null)
				items.add(new GameFolderMenu(game.parent, menu_data, "Show a menu for the folder containing this game"));
			
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
