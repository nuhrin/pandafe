/* GameCategorySelector.vala
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

public class GameCategorySelector : Selector 
{	
	public GameCategorySelector(string id, int16 xpos, int16 ypos, int16 ymax,string? category_path) {
		base(id, xpos, ypos, ymax);		
		this.category_path = category_path;
		Data.all_games().cache_updated.connect((new_selection_id) => rebuild(new_selection_id));
		rebuild_items(-1, null);
	}

	string? category_path;
	ArrayList<SubCategory> subcategories;
	Gee.List<GameItem> games;
		
	public unowned string? active_category_path { get { return category_path; } }
	public string? parent_category_path() {
		if (category_path == null)
			return null;
		int last_slash_index = category_path.last_index_of("/");
		if (last_slash_index == -1)
			return null;
			
		return category_path.substring(0, last_slash_index);
	}
	public unowned string? selected_category_path() {
		var subcategory = subcategory_at(selected_index);
		if (subcategory != null)
			return subcategory.path;
		
		return null;		
	}
	public GameItem? selected_game() {
		return game_at(selected_index);
	}
			
	public void change_category(string? category_path) {
		if (this.category_path == category_path)
			return;
		this.category_path = category_path;
		selected_index = -1;
		var filter = get_filter_pattern();
		if (filter == null) {
			rebuild();
		} else {
			clear_filter();
			this.filter(filter);
		}			
	}
	
	public bool select_category_path(string category_path) {
		int index=0;
		int found_index=-1;
		foreach(var item in subcategories) {
			if (item.path == category_path) {
				found_index = index;
				break;
			}
			index++;
		}
		if (found_index == -1 || selected_index == found_index)
			return false;			
		
		return select_item(found_index);
	}

	public bool select_game(GameItem game) {
		int index=0;
		int found_index=-1;
		foreach(var item in games) {
			if (item.id == game.id) {
				found_index = index;
				break;
			}
			index++;
		}
		if (found_index > -1)
			found_index = found_index + subcategories.size;
			
		if (found_index == -1 || selected_index == found_index)
			return false;			
		
		return select_item(found_index);
	}

	protected override void rebuild_items(int selection_index, string? new_selection_id) {
		var selection_id = new_selection_id;
		if (selection_id == null && selection_index != -1)
			selection_id = item_unique_id(selection_index);
		
		Gee.List<string> subcategory_names;
		Gee.List<GameItem> games;
		if (Data.all_games().load_category_data(category_path, out subcategory_names, out games) == true) {
			subcategories = new ArrayList<SubCategory>();			
			foreach(var name in subcategory_names) {
				var subcategory = (category_path == null)
					? new SubCategory(name, name)
					: new SubCategory(name, "%s/%s".printf(category_path, name));
				subcategories.add(subcategory);
			}			
			if (category_path == null)
				subcategories.add(new SubCategory(AllGames.UNCATEGORIZED_CATEGORY_NAME, AllGames.UNCATEGORIZED_CATEGORY_NAME));
			
			games.sort(IGameListNode.compare);				
			this.games = games;			
		} else {
			subcategories = new ArrayList<SubCategory>();
			games = Gee.List.empty<GameItem>();			
		}
		
		int new_index = -1;
		if (selection_id != null) {
			for(int index=0;index<get_itemcount();index++) {				
				if (item_unique_id(index) == selection_id) {
					new_index = index;
					break;
				}
			}
		}
		if (new_index == -1 && selection_index > -1 && selection_index < get_itemcount())
			new_index = selection_index;
		
		if (new_index != -1)
			select_item(new_index, false);
	}	
	string? item_unique_id(int index) {
		var sc = subcategory_at(index);
		if (sc != null)
			return sc.path;
		var game = game_at(index);
		if (game != null)
			return game.unique_id();
		return null;
	}
	
	protected override int get_itemcount() { return subcategories.size + games.size; }
	protected override string get_item_name(int index) {
		var subcategory = subcategory_at(index);
		if (subcategory != null)
			return subcategory.name + " >";
		var game = game_at(index);
		if (game != null)
			return game.name;
		
		assert_not_reached();
	}
	protected override string get_item_full_name(int index) {
		var subcategory = subcategory_at(index);
		if (subcategory != null)
			return subcategory.name + " >";
		var game = game_at(index);
		if (game != null)
			return game.full_name;
		
		assert_not_reached();
	}
	SubCategory? subcategory_at(int index) {
		if (index < 0 || index >= subcategories.size)
			return null;
		return subcategories[index];
	}
	GameItem? game_at(int index) {
		if (index < subcategories.size)
			return null;
		return games[index - subcategories.size];
	}
	
	class SubCategory {
		public SubCategory(string name, string path) {
			_name = name;
			_path = path;
		}
		string _name;
		string _path;
		public unowned string name { get { return _name; } }
		public unowned string path { get { return _path; } }		
	}
}
