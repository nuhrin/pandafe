/* GameAppMenu.vala
 * 
 * Copyright (C) 2013 nuhrin
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
	public class GameAppMenu : Menu  
	{	
		GameItem game;
		AppItem app;
		GameNodeMenuData menu_data;
		NativePlatform platform;
		public GameAppMenu(GameItem game, AppItem app, GameNodeMenuData menu_data, string? help=null) {
			if (game.platform.platform_type != PlatformType.NATIVE)
				GLib.error("GameFileMenu is only applicable to games from the Native Platform");
			base("Manage App", help);
			this.title = "Manage File: " + game.id;
			this.game = game;
			this.menu_data = menu_data;
			platform = game.platform as NativePlatform;
			if (app == null)
				GLib
		}

		protected override void populate_items(Gee.List<MenuItem> items) { 			
			items.add(new EditOvrItem(game, menu_data));
			items.add(new DeleteItem(game));
		}
	}
}
