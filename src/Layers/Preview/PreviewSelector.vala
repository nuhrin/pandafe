/* PreviewSelector.vala
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

namespace Layers.Preview
{
	public class PreviewSelector : Selector 
	{
		static string[] items;
		static string[] get_items() { 
			return new string[] {
				"Item 1",
				"Selected Item",
				"Item 3"
//~ 				"Item 4"
//~ 				"Item 5",
//~ 					"Item 6",
//~ 					"Item 7",
//~ 					"Item 8",
//~ 					"Item 9",
//~ 					"Item 10"
			};
		}

		public PreviewSelector(int16 xpos, int16 ypos, GameBrowserUI ui) {
			base("preview_selector", xpos, ypos, ui);
			if (items == null)
				items = get_items();
			selected_index = 1;
		}

		protected override void rebuild_items(int selection_index, string? new_selection_id) { }
		protected override int get_itemcount() { return items.length; }
		protected override string get_item_name(int index) { return items[index]; }
		protected override string get_item_full_name(int index) { return get_item_name(index); }
	}
}
