/* GameNodeMenuData.vala
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

namespace Data.GameList
{
	public class GameNodeMenuData 
	{
		SDL.Rect _selected_item_rect;
		public GameNodeMenuData(Selector browser_selector) {
			_selected_item_rect = browser_selector.get_selected_item_rect();
		}
		
		public unowned SDL.Rect selected_item_rect() { return _selected_item_rect; }
	}
}
