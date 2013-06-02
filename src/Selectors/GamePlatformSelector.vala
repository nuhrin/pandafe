/* GamePlatformSelector.vala
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

using Gee;
using SDL;
using SDLTTF;
using Catapult;
using Data;
using Data.GameList;

public class GamePlatformSelector : Selector 
{
	Platform _platform;
	public GamePlatformSelector(string id, int16 xpos, int16 ypos, int16 ymax, Platform platform) {
		base(id, xpos, ypos, ymax);
		_platform = platform;
	}	

	Gee.List<GameItem> items {
		get {
			if (_items == null) {
				loading();
				_items = _platform.all_games().to_list();
				_items.sort(IGameListNode.compare);
			}
			return _items;
		}
	}
	Gee.List<GameItem> _items;
	
	public Platform platform { get { return _platform; } }
	
	public void set_platform(Platform platform) {
		if (_platform.id == platform.id)
			return;
		_platform = platform;
		var filter = get_filter_pattern();
		if (filter == null) {
			rebuild();
		} else {
			clear_filter();
			this.filter(filter);
		}			
	}

	public GameItem? selected_game() {
		if (selected_index < 0)
			return null;
		return items[selected_index];
	}
	public bool select_game(GameItem game) {
		int index=0;
		int found_index=-1;
		foreach(var item in items) {
			if (item.id == game.id) {
				found_index = index;
				break;
			}
			index++;
		}
		if (found_index == -1 || selected_index == found_index)
			return false;			
		
		return select_item(found_index);		
	}
	
	protected override void rebuild_items(int selection_index, string? new_selection_id) {
		var selection_id = new_selection_id;
		if (selection_id == null && selection_index != -1)
			selection_id = items[selection_index].unique_id();
		
		_items = null;
		int new_index = -1;
		if (selection_id != null) {
			for(int index=0;index<items.size;index++) {
				var item = items[index];
				if (item.unique_id() == selection_id) {
					new_index = index;
					break;
				}
			}
		}
		if (new_index != -1)
			select_item(new_index, false);
	}
	protected override int get_itemcount() { return items.size; }
	protected override string get_item_name(int index) {
		return items[index].name;
	}
	protected override string get_item_full_name(int index) {
		return items[index].full_name;
	}	
}
