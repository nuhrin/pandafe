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
				base("Rename", "Change the rom filename");
				this.game = game;
				this.menu_data = menu_data;
			}
			public override void activate(MenuSelector selector) {
				unowned SDL.Rect rect = menu_data.selected_item_rect();
				string existing_name = game.id;
				string? extension = null;
				int extension_index = game.id.last_index_of(".");
				if (extension_index != -1) {
					existing_name = game.id.substring(0, extension_index);
					extension = game.id.substring(extension_index+1);
				}
				int16 width = (int16)(@interface.screen_width - (@interface.screen_width - selector.xpos) - rect.x - 35);
				var entry = new Layers.Controls.TextEntry("game_rename", rect.x, rect.y, width, existing_name);
				string? new_name = entry.run();
				if (new_name == existing_name)
					return;
				if (extension != null)
					new_name = "%s.%s".printf(new_name, extension);
				
				string file = game.unique_id();
				if (FileUtils.test(file, FileTest.EXISTS) == false) {
					selector.menu.error("File does not exist");
					return;
				}
				string new_file = Path.build_filename(Path.get_dirname(file), new_name);
				try {
					if (File.new_for_path(file).move(File.new_for_path(new_file), FileCopyFlags.NOFOLLOW_SYMLINKS) == false) {
						selector.menu.error("Unable to rename file");
						return;
					}
					Data.platforms().rescan_folder(game.parent, new_file);
					selector.menu.quit();
				} catch(GLib.Error e) {
					selector.menu.error(e.message);
				}
			}
		}
			
		class MoveItem : MenuItem
		{
			GameItem game;
			RomPlatform platform;
			public MoveItem(GameItem game, RomPlatform platform) {
				base("Move", "Move the file to a different folder");
				this.game = game;
				this.platform = platform;
			}
			public override void activate(MenuSelector selector) { 
				var chooser = new FolderChooser("new_game_folder_chooser", "Select new folder for " + game.id, platform.rom_folder_root);
				chooser.allow_folder_creation = true;
				var current_folder = game.parent.unique_id();
				var new_folder = chooser.run(current_folder);
				if (new_folder != null && new_folder != current_folder) {
					var current_file = File.new_for_path(Path.build_filename(current_folder, game.id));					
					var new_file = File.new_for_path(Path.build_filename(new_folder, game.id));
					try 
					{
						var new_folder_relative = new_folder.replace(platform.rom_folder_root, "");
						if (new_folder_relative.has_prefix("/") == true)
							new_folder_relative = new_folder_relative.substring(1);
						var new_folder_depth = new_folder_relative.split("/").length;
						if (current_file.move(new_file, FileCopyFlags.NOFOLLOW_SYMLINKS) == true) {							
							var scan_target_node = game.parent;
							while(new_folder_depth <= scan_target_node.depth() && scan_target_node.parent != null)
								scan_target_node = scan_target_node.parent;
							Data.platforms().rescan_folder(scan_target_node, new_file.get_path());
							selector.menu.quit();
						} else {
							selector.menu.error("Unable to move '%s'.".printf(game.id));
						}
					} catch (GLib.Error e) {
						selector.menu.error(e.message);
					}					
				}		
			}
		}
		class DeleteItem : MenuItem
		{
			GameItem game;
			public DeleteItem(GameItem game) {
				base("Delete", "Delete the file");
				this.game = game;
			}
			public override void activate(MenuSelector selector) { 
				var rect = selector.get_selected_item_rect();
				var confirmed = new DeleteConfirmation("confirm_game_delete", rect.x, rect.y).run();
				if (confirmed == false)
					return;
				
				var file = File.new_for_path(game.unique_id());
				try {
					if (file.delete() == true) {
						Data.platforms().rescan_folder(game.parent);
						selector.menu.quit();
					} else {
						selector.menu.error("Unable to delete '%s'.".printf(game.id));
					}
				} catch (GLib.Error e) {
					selector.menu.error(e.message);
				}				
			}
		}
	}
}
