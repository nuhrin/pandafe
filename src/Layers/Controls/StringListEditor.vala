/* StringListEditor.vala
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

using SDL;
using Gee;
using Layers.Controls.List;

namespace Layers.Controls
{
	public class StringListEditor : ListEditorBase<string>
	{
		string? character_mask_regex;
		string? value_mask_regex;
		
		public StringListEditor(string id, string title, string? help=null, Gee.List<string> list, string? character_mask_regex=null, string? value_mask_regex=null) {
			base(id, title, help, list);
			this.character_mask_regex = character_mask_regex;
			this.value_mask_regex = value_mask_regex;
		}
		
		protected override ListItem<string> get_list_item(string item) {
			return new StringListItem(item);
		}
		protected override bool create_item(Rect selected_item_rect, out string item) { 
			item = ""; 
			return true;
		}
		protected override bool edit_list_item(ListItem<string> item, uint index) {
			Rect rect = get_selected_item_rect();
			var entry = new TextEntry("%s_item_%u".printf(id, index), rect.x - 4, rect.y, 300, item.value, character_mask_regex, value_mask_regex);			
			string? edited = entry.run();
			if (edited != item.value) {
				item.value = edited ?? "";
				return true;
			}
			
			return false;
		}
		
	}
}
