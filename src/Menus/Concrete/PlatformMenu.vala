/* PlatformMenu.vala
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

using Data.Platforms;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class PlatformMenu : Menu  
	{	
		Platform platform;
		PlatformFolder? platform_folder;
		
		public PlatformMenu(Platform platform, string? help=null, PlatformFolder? platform_folder=null) {
			base("Platform: " + platform.name, help ?? "Show a menu for the current platform");
			title = "%s: %s".printf(platform.platform_type_description(), platform.name);
			this.platform = platform;
			this.platform_folder = platform_folder;
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Edit", "Edit the platform definition", null, () => {
				if (ObjectMenu.edit("%s: %s".printf(platform.platform_type_description(), platform.name), platform) == true) {
					saved();
				}
			}));
			items.add(new MenuItem.custom("Rescan", "Rescan the platform for game changes", "", () => {
				if (platform.platform_type == PlatformType.PROGRAM) {
					platform.rescan(f=> this.message("Scanning '%s'...".printf(platform.name)));
					return;
				}
				if (platform.platform_type == PlatformType.NATIVE) {
					this.message("Scanning PNDs...");
					Data.rescan_pnd_data();
					platform.reset_runtime_data();
				}
				platform.rescan(f=> this.message("Scanning folder '%s'...".printf(f.unique_name())));
				refresh(1);
			}));
						
			if (platform_folder != null) {
				items.add(new MenuItemSeparator());
				
				var platform_folder_menu = new PlatformFolderMenu(platform_folder, "Show a menu for the folder containing this platform");
				var platform_folder_item_index = items.size;
				platform_folder_menu.saved.connect(() => refresh(platform_folder_item_index));
				items.add(platform_folder_menu);
			}
		}						
	}

}
