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

namespace Layers.Controls
{
	public class GameCategorySelector : StringSelector
	{
		const string NO_CATEGORY_ITEM = "(Uncategorized)";
		const string NEW_CATEGORY_ITEM = "(New Category)";
		
		public GameCategorySelector(string id, int16 xpos, int16 ypos, int16 max_width, string? current_category)  {
			base(id, xpos, ypos, max_width);
			wrap_selector = true;
			uint index=0;
			add_item(NO_CATEGORY_ITEM);
			var categories = Data.all_games().get_root_category_names();
			foreach(var category in categories) {
				index++;
				add_item(category);
				if (current_category == category)
					selected_index = index;
			}
			add_item(NEW_CATEGORY_ITEM);
		}
		
		public bool no_category_selected { get { return (selected_index == 0); } }
		bool new_category_selected { get { return (selected_index == item_count - 1); } }
		
		protected override bool activate(Rect selected_item_rect) {
			if (new_category_selected == false)
				return true;
			
			var entry = new TextEntry(id+"_entry", selected_item_rect.x, selected_item_rect.y, (int16)selected_item_rect.w);
			string? new_category = entry.run();
			if (new_category != null)
				new_category = new_category.strip();
			if (new_category == null || new_category == "")
				return false;
				
			set_selected_item(new_category);
			return true;
		}
	}
}
