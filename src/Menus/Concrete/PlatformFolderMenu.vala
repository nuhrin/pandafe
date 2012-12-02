/* PlatformFolderMenu.vala
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
	public class PlatformFolderMenu : Menu  
	{	
		PlatformFolder platform_folder;
		public PlatformFolderMenu(PlatformFolder platform_folder, string? help=null, string? name=null) {
			base("%s: %s".printf(name ?? "Folder", platform_folder.name), help);
			title = "Platform Folder: " + platform_folder.name;
			this.platform_folder = platform_folder;
			ensure_items();		
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Edit", "Edit the platform folder", null, () => {
				if (ObjectMenu.edit("Edit Platform Folder", platform_folder) == true) {
					string? error;
					if (Data.platforms().save_platform_folder_data(out error) == false) {
						this.error(error);
					} else {
						title = "Platform Folder: " + platform_folder.name;
						refresh(0);
						saved();
					}					
				}
			}));
			if (platform_folder.parent != null) {
				items.add(new MenuItemSeparator());
				
				var parent_folder_menu = new PlatformFolderMenu(platform_folder.parent, "Show a menu for the parent of this platform folder", "Parent");
				var parent_folder_item_index = items.size;
				parent_folder_menu.saved.connect(() => refresh(parent_folder_item_index));
				items.add(parent_folder_menu);
			}
		}						
	}

}
