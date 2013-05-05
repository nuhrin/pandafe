/* GameFolderMenu.vala
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
	public class GameFolderMenu : Menu  
	{	
		GameFolder folder;
		GameNodeMenuData menu_data;
		Platform platform;
		public GameFolderMenu(GameFolder folder, GameNodeMenuData menu_data, string? help=null) {
			string name = "Folder: " + ((folder.parent != null) ? folder.display_name() : "Root");
			base(name, help);
			this.title = "Game " + name;
			this.folder = folder;
			this.menu_data = menu_data;
			platform = folder.platform;
		}

		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Rescan", "Rescan the folder for game changes", "Scanning folder...", () => {
				if (platform.platform_type == PlatformType.NATIVE) {
					this.message("Scanning PNDs...");
					Data.rescan_pnd_data();
				}
				folder.rescan_children();
			}));

			items.add(new MenuItemSeparator());

			if (platform.platform_type == PlatformType.ROM) {
				var full_path = folder.unique_id();
				items.add(new MenuItem.custom("Terminal", "Open terminal in this folder", "", () => {
					var result = Spawning.spawn_command("/usr/bin/terminal", full_path);
					if (result.success == false)
						result.show_result_dialog();
				}));
				items.add(new MenuItem.custom("File Manager", "Open file manager in this folder", "", () => {
					var result = Spawning.spawn_command("/usr/bin/thunar", full_path);
					if (result.success == false)
						result.show_result_dialog();
				}));
				items.add(new MenuItemSeparator());
				
				if (folder.parent != null) {
					items.add(new RenameItem(folder, menu_data));
					items.add(new MoveItem(folder, platform as RomPlatform));
					items.add(new MenuItemSeparator());
				}
			}
			
			var platform_menu = new PlatformMenu(platform);
			var platform_item_index = items.size;
			platform_menu.saved.connect(() => refresh(platform_item_index));			
			items.add(platform_menu);
		}
		
		class RenameItem : MenuItem
		{
			GameFolder folder;
			GameNodeMenuData menu_data;
			public RenameItem(GameFolder folder, GameNodeMenuData menu_data) {
				base("Rename", "Change the folder name");
				this.folder = folder;
				this.menu_data = menu_data;
			}
			public override void activate(MenuSelector selector) {
				unowned SDL.Rect rect = menu_data.selected_item_rect();
				string existing_name = folder.name;
				int16 width = (int16)(@interface.screen_width - (@interface.screen_width - selector.xpos) - rect.x - 35);
				var entry = new Layers.Controls.TextEntry("folder_rename", rect.x, rect.y, width, existing_name);
				string? new_name = entry.run();
				if (new_name == existing_name)
					return;
				
				string path = folder.unique_id();
				if (FileUtils.test(path, FileTest.IS_DIR) == false) {
					selector.menu.error("Folder does not exist or is not a directory");
					return;
				}
				string new_path = Path.build_filename(Path.get_dirname(path), new_name);
				try {
					if (File.new_for_path(path).move(File.new_for_path(new_path), FileCopyFlags.NOFOLLOW_SYMLINKS) == false) {
						selector.menu.error("Unable to rename folder");
						return;
					}
					Data.platforms().rescan_folder(folder.parent);
					selector.menu.quit();
				} catch(GLib.Error e) {
					selector.menu.error(e.message);
				}
			}
		}
			
		class MoveItem : MenuItem
		{
			GameFolder folder;
			RomPlatform platform;
			public MoveItem(GameFolder folder, RomPlatform platform) {
				base("Move", "Move the folder to a different folder");
				this.folder = folder;
				this.platform = platform;
			}
			public override void activate(MenuSelector selector) { 
				var chooser = new FolderChooser("new_folder_chooser", "Select new folder for " + folder.name, platform.rom_folder_root);
				chooser.allow_folder_creation = true;
				var current_folder = folder.parent.unique_id();
				var new_folder = chooser.run(current_folder);
				if (new_folder != null && new_folder != current_folder) {
					var current_path = File.new_for_path(Path.build_filename(current_folder, folder.name));
					var new_path = File.new_for_path(Path.build_filename(new_folder, folder.name));
					try 
					{
						var new_folder_relative = new_folder.replace(platform.rom_folder_root, "");
						if (new_folder_relative.has_prefix("/") == true)
							new_folder_relative = new_folder_relative.substring(1);
						var new_folder_depth = new_folder_relative.split("/").length;
						if (current_path.move(new_path, FileCopyFlags.NOFOLLOW_SYMLINKS) == true) {							
							var scan_target_node = folder.parent;
							while(new_folder_depth <= scan_target_node.depth() && scan_target_node.parent != null)
								scan_target_node = scan_target_node.parent;
							Data.platforms().rescan_folder(scan_target_node);
							selector.menu.quit();
						} else {
							selector.menu.error("Unable to move '%s'.".printf(folder.name));
						}
					} catch (GLib.Error e) {
						selector.menu.error(e.message);
					}					
				}
			}
		}

	}
}
