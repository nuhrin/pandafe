/* GameFolderSelector.vala
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
using Data.GameList;

public class GameFolderSelector : Selector
{
	GameFolder _folder;
	Gee.List<IGameListNode> items;
	
	public GameFolderSelector(GameFolder folder, string id, int16 xpos, int16 ypos, int16 ymax) {
		base(id, xpos, ypos, ymax);
		_folder = folder;
		_folder.rescanned.connect(() => rebuild());
		items = _folder.children().to_list();
	}

	public GameFolder folder { get { return _folder; } }
	public void set_folder(GameFolder folder, string? new_selection_id) {
		if (_folder != folder) {
			_folder = folder;
			_folder.rescanned.connect(() => rebuild());
		}
		rebuild(new_selection_id);
	}

	public IGameListNode? selected_item()
	{
		if (selected_index == -1)
			return null;
		return items[selected_index];
	}
	
	protected override void rebuild_items(int selection_index, string? new_selection_id) {
		var selection_id = new_selection_id;
		if (selection_id == null && selection_index != -1)
			selection_id = items[selection_index].unique_id();
		
		items = _folder.children().to_list();
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
		if (new_index == -1 && selection_index > -1 && selection_index < items.size)
			new_index = selection_index;
		if (new_index != -1)
			select_item(new_index, false);
	}

	protected override int get_itemcount() { return items.size; }
	protected override string get_item_name(int index) {
		var item = items[index];
		var folder = item as GameFolder;
		if (folder != null)
			return folder.display_name() + "/";
		return item.name;
	}
	protected override string get_item_full_name(int index) {
		var item = items[index];
		var folder = item as GameFolder;
		if (folder != null)
			return folder.display_name() + "/";
		return item.full_name;
	}
}
