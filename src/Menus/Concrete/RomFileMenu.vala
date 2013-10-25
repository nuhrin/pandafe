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
			items.add(new MenuItemSeparator());
			var full_path = game.parent.unique_id();
			items.add(new MenuItem.custom("Terminal", "Open terminal in " + full_path, "", () => {
				Spawning.open_terminal(full_path);
			}));
			items.add(new MenuItem.custom("File Manager", "Open file manager in " + full_path, "", () => {
				Spawning.open_file_manager(full_path);
			}));
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
				int16 width = selector.xpos - @interface.menu_ui.controls.value_control_spacing - rect.x;
				var entry = new Layers.Controls.TextEntry.browser("game_rename", rect.x, rect.y, width, rom_files.rom_fullname);
				string? new_name = entry.run_no_pop();
				if (new_name == rom_files.rom_fullname) {
					@interface.pop_layer();
					return;
				}
				
				selector.menu.message("Renaming...");
				
				if (rom_files.rename(new_name, out error) == false) {
					@interface.pop_layer(false);
					selector.menu.error(error);
					return;
				}				
				Data.platforms().rescan_folder(game.parent, rom_files.unique_id());
				
				@interface.pop_layer(false);
				selector.menu.quit();
			}
		}
			
		class MoveItem : MenuItem
		{
			GameItem game;
			RomPlatform platform;
			public MoveItem(GameItem game, RomPlatform platform) {
				base("Change Category", "Move the rom file(s) to a different category folder");
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
				
				var rect = selector.get_selected_item_rect();
				var current_category = game.parent.unique_display_name();
				if (current_category == "")
					current_category = null;
				var category_selector = new Layers.Controls.GameCategorySelector("game_category_selector", rect.x, rect.y, 200, current_category);
				var category_overlay = new Layers.GameBrowser.SelectorOverlay<string>.from_selector("Change Category: " + game.id, null, category_selector);
				
				var overlay_layer = @interface.pop_layer(false);
				category_overlay.run_no_pop();
				
				if (
				    category_selector.was_canceled == true ||
				    (current_category == null && category_selector.no_category_selected == true) ||
				    (current_category == category_selector.selected_item())
				) {
					@interface.pop_layer(false);
					@interface.push_layer(overlay_layer);
					return;
				}
				
				string? new_category = null;				
				if (category_selector.no_category_selected == false)
					new_category = category_selector.selected_item();				
				
				if (new_category != null) {
					var existing_folder = game.parent.root_folder().child_folders()
						.where(f => f.display_name() == new_category)					
						.first();
					if (existing_folder != null)
						new_category = existing_folder.name;
				}
				
				var new_folder = (new_category == null)
					? platform.rom_folder_root
					: Path.build_filename(platform.rom_folder_root, new_category);
				
				if (new_folder == game.parent.unique_id()) {
					@interface.pop_layer(false);
					@interface.push_layer(overlay_layer);
					return; // already the same
				}
				
				category_overlay.set_message("Changing category...");
				
				// move the rom file(s)
				bool newly_created = false;
				if (FileUtils.test(new_folder, FileTest.IS_DIR) == false) {
					try {
						if (File.new_for_path(new_folder).make_directory_with_parents() == false)
							throw new FileError.FAILED("unable to create directory");
						newly_created = true;
					} catch(Error e) {
						@interface.pop_layer(false);
						@interface.push_layer(overlay_layer, 0, 0, false);
						selector.menu.error("%s: %s".printf(new_category, e.message));
						return;
					}
				}
				if (rom_files.move(new_folder, out error) == false) {
					if (newly_created == true) {
						try {
							File.new_for_path(new_folder).delete();
						} catch(Error e) {
						}
					}
					@interface.pop_layer(false);
					@interface.push_layer(overlay_layer, 0, 0, false);
					selector.menu.error(error);
					return;
				}
								
				// attempt to remove the old directory. only removed if its empty. if not empty, the call will simply return -1 and be ignored
				FileUtils.remove(game.parent.unique_id());
								
				var new_folder_relative = new_folder.replace(platform.rom_folder_root, "");
				if (new_folder_relative.has_prefix("/") == true)
					new_folder_relative = new_folder_relative.substring(1);
				var new_folder_depth = new_folder_relative.split("/").length;
				var scan_target_node = game.parent;
				while(new_folder_depth <= scan_target_node.depth() && scan_target_node.parent != null)
					scan_target_node = scan_target_node.parent;
				Data.platforms().rescan_folder(scan_target_node, rom_files.unique_id());
				
				@interface.pop_layer(false);
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
				var delete_selector = new DeleteConfirmation("confirm_game_delete", rect.x, rect.y);
				var delete_overlay = new Layers.GameBrowser.SelectorOverlay<string>.from_selector("Delete: " + game.id, null, delete_selector);
				var overlay_layer = @interface.pop_layer(false);
				delete_overlay.run_no_pop();
				
				if (delete_selector.confirm_selected() == false) {
					@interface.pop_layer(false);
					@interface.push_layer(overlay_layer);
					return;
				}
				
				delete_overlay.set_message("Deleting...");
				
				if (rom_files.remove(out error) == false) {
					@interface.pop_layer(false);
					@interface.push_layer(overlay_layer, 0, 0, false);					
					selector.menu.error(error);
					return;
				}
				
				Data.platforms().rescan_folder(game.parent);
				
				@interface.pop_layer(false);
				selector.menu.quit();				
			}
		}
	}
}
