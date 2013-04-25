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

namespace Menus.Concrete
{
	public class GameFolderMenu : Menu  
	{	
		GameFolder folder;		
		Platform platform;
		public GameFolderMenu(GameFolder folder, string? help=null) {
			string name = "Folder: " + ((folder.parent != null) ? folder.display_name() : "Root");
			base(name, help);
			this.title = "Game " + name;
			this.folder = folder;			
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
			
			var platform_menu = new PlatformMenu(platform);
			var platform_item_index = items.size;
			platform_menu.saved.connect(() => refresh(platform_item_index));			
			items.add(platform_menu);
		}		
	}
}
