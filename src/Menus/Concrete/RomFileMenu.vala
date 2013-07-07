/* GameFileMenu.vala
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
using Data.Platforms;
using Layers.Controls;

namespace Menus.Concrete
{
	public class RomFileMenu : Menu  
	{	
		GameItem game;
		GameNodeMenuData menu_data;
		RomPlatform platform;
		public RomFileMenu(GameItem game, GameNodeMenuData menu_data, string? help=null) {
			if (game.platform.platform_type != PlatformType.ROM)
				GLib.error("RomFileMenu is only applicable to games from Rom Based Platforms");
			base("Manage Rom", help);
			this.title = "Manage Rom: " + game.id;
			this.game = game;
			this.menu_data = menu_data;
			platform = game.platform as RomPlatform;
		}

		protected override void populate_items(Gee.List<MenuItem> items) { 			
			items.add(new RenameItem(game, menu_data));
			items.add(new MoveItem(game, platform));
			items.add(new DeleteItem(game));
		}
		
		class RenameItem : MenuItem
		{
			GameItem game;
			GameNodeMenuData menu_data;
			public RenameItem(GameItem game, GameNodeMenuData menu_data) {
				base("Rename", "Change the rom filename(s)");
				this.game = game;
				this.menu_data = menu_data;
			}
			public override void activate(MenuSelector selector) {
				if (FileUtils.test(game.unique_id(), FileTest.EXISTS) == false) {
					selector.menu.error("File does not exist");
					return;
				}				
				string? error;
				RomFiles rom_files;
				if (RomFiles.build_for_game(game, out rom_files, out error) == false) {
					selector.menu.error(error);
					return;
				}
				
				unowned SDL.Rect rect = menu_data.selected_item_rect();			
				int16 width = (int16)(@interface.screen_width - (@interface.screen_width - selector.xpos) - rect.x - 35);
				var entry = new Layers.Controls.TextEntry("game_rename", rect.x, rect.y, width, rom_files.rom_fullname);
				string? new_name = entry.run();
				if (new_name == rom_files.rom_fullname)
					return;
				
				if (rom_files.rename(new_name, out error) == false) {
					selector.menu.error(error);
					return;
				}				
				
				Data.platforms().rescan_folder(game.parent, rom_files.unique_id());
				selector.menu.quit();
			}
		}
			
		class MoveItem : MenuItem
		{
			GameItem game;
			RomPlatform platform;
			public MoveItem(GameItem game, RomPlatform platform) {
				base("Move", "Move the rom file(s) to a different folder");
				this.game = game;
				this.platform = platform;
			}
			public override void activate(MenuSelector selector) { 
				if (FileUtils.test(game.unique_id(), FileTest.EXISTS) == false) {
					selector.menu.error("File does not exist");
					return;
				}
				
				string? error;
				RomFiles rom_files;
				if (RomFiles.build_for_game(game, out rom_files, out error) == false) {
					selector.menu.error(error);
					return;
				}
				
				var chooser = new FolderChooser("new_game_folder_chooser", "Select new folder for " + game.id, platform.rom_folder_root);
				chooser.allow_folder_creation = true;
				var current_folder = game.parent.unique_id();
				var new_folder = chooser.run(current_folder);
				if (new_folder == null || new_folder == current_folder)
					return;
								
				if (rom_files.move(new_folder, out error) == false) {
					selector.menu.error(error);
					return;
				}
				
				var new_folder_relative = new_folder.replace(platform.rom_folder_root, "");
				if (new_folder_relative.has_prefix("/") == true)
					new_folder_relative = new_folder_relative.substring(1);
				var new_folder_depth = new_folder_relative.split("/").length;
				var scan_target_node = game.parent;
				while(new_folder_depth <= scan_target_node.depth() && scan_target_node.parent != null)
					scan_target_node = scan_target_node.parent;
				Data.platforms().rescan_folder(scan_target_node, rom_files.unique_id());
				selector.menu.quit();							
			}
		}
		class DeleteItem : MenuItem
		{
			GameItem game;
			public DeleteItem(GameItem game) {
				base("Delete", "Delete the rom file(s)");
				this.game = game;
			}
			public override void activate(MenuSelector selector) { 
				if (FileUtils.test(game.unique_id(), FileTest.EXISTS) == false) {
					selector.menu.error("File does not exist");
					return;
				}

				string? error;
				RomFiles rom_files;
				if (RomFiles.build_for_game(game, out rom_files, out error) == false) {
					selector.menu.error(error);
					return;
				}
				
				var rect = selector.get_selected_item_rect();
				var confirmed = new DeleteConfirmation("confirm_game_delete", rect.x, rect.y).run();
				if (confirmed == false)
					return;
				
				if (rom_files.remove(out error) == false) {
					selector.menu.error(error);
					return;
				}
				
				Data.platforms().rescan_folder(game.parent);
				selector.menu.quit();				
			}
		}
	}
}
