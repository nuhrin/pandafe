/* EverythingSelector.vala
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

using Gee;
using SDL;
using SDLTTF;
using Catapult;
using Data;
using Data.GameList;

public class EverythingSelector : Selector 
{
	GameBrowserViewData view;
	
	public EverythingSelector(string id, int16 xpos, int16 ypos, int16 ymax, GameBrowserViewData? view) {
		base(id, xpos, ypos, ymax);
		this.view = view ?? new GameBrowserViewData(GameBrowserViewType.ALL_GAMES);
		Data.all_games().cache_updated.connect((new_selection_id) => rebuild(new_selection_id));
		Data.favorites().changed.connect(() => favorites_changed());
	}

	Gee.List<GameItem> items {
		get {
			if (_items == null) {
				loading();
				_items = get_view_games(view);
			}
			return _items;
		}
	}
	Gee.List<GameItem> _items;
	
	public unowned string view_name { get { return view.name; } }
	
	public void change_view(GameBrowserViewData view) {
		if (this.view.equals(view) == true)
			return;
		this.view = view;
		var filter = get_filter_pattern();
		if (filter == null) {
			rebuild();
		} else {
			clear_filter();
			this.filter(filter);
		}			
	}
	void favorites_changed() {
		if (view.view_type == GameBrowserViewType.FAVORITES)
			rebuild();
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
	
	public void game_run_completed() {
		if (view.view_type == GameBrowserViewType.MOST_PLAYED || view.view_type == GameBrowserViewType.MOST_RECENT)
			rebuild();
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
	
	Gee.List<GameItem> get_view_games(GameBrowserViewData view) {		
		var games = Data.all_games().load();
		
		// filter games list
		bool do_sort = true;
		switch (view.view_type) {
			case GameBrowserViewType.FAVORITES:
				games = games.where(g=>g.is_favorite == true);
				break;
			case GameBrowserViewType.MOST_RECENT:
				games = Data.get_most_recently_played_games(games);
				do_sort = false;
				break;
			case GameBrowserViewType.MOST_PLAYED:
				games = Data.get_most_frequently_played_games(games);
				do_sort = false;
				break;
			default:
				break;
		}
		
		var list = games.to_list();
		if (do_sort == true)
			list.sort(IGameListNode.compare);
			
		return list;
	}
}
