/* CategorySelectorOverlay.vala
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
using Layers.MenuBrowser;
using Layers.Controls;

namespace Layers.GameBrowser
{
	public class CategorySelectorOverlay : SelectorOverlay<string>
	{
		public class CategorySelectorOverlay(string? current_category) {			
			var categories = new ArrayList<string>();
			categories.add_all(Data.all_games().get_root_category_names().to_list());
						
			int found_index=-1;
			if (current_category == "")
				found_index = categories.size;
			else {
				int index=0;
				foreach(var category in categories) {
					if (current_category == category) {
						found_index = index;
						break;
					}
					index++;
				}
			}
			
			categories.add(Data.GameList.AllGames.UNCATEGORIZED_CATEGORY_NAME);
			uint selected_index = (found_index > 0) ? (uint)found_index : 0;
			base("Change Category", "Select a new category...", (MapFunc<string,string>)get_category_name, categories, selected_index);
			this.can_select_single_item = true;
		}
		
		protected override string? get_selection_help(string selected_item) {
			return "Show %s games".printf(selected_item);
		}
		static string get_category_name(string category) { return category; }
		
	}
}
