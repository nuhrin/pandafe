/* PndCategoryChooser.vala
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
using Layers;
using Layers.Controls.Chooser;
using Layers.MenuBrowser;
using Data.Pnd;

namespace Layers.Controls
{
	public class PndCategoryChooser : ChooserBase
	{				
		const string SELECTOR_ID = "category_selector";
		string? selected_path;

		public PndCategoryChooser(string id, string title) {			
			base(id, title);					
		}

		protected override string? get_run_result() { return selected_path; }
		
		protected override ChooserSelector create_selector(string key, int16 xpos, int16 ypos, int16 max_height) {
			return new PndCategorySelector(SELECTOR_ID, xpos, ypos, max_height, key);
		}		
		
		protected override void update_header(ChooserHeader header, ChooserSelector selector) {
			header.path = ((PndCategorySelector)selector).path;
		}
		protected override bool process_activation(ChooserSelector selector) {
			var category_selector = (PndCategorySelector)selector;
			if (category_selector.is_choose_item_selected) {
				// choose this category
				selected_path = category_selector.selected_path();				
				return true;
			}
			return false;
		}
		protected override string get_selected_key(ChooserSelector selector) { return ((PndCategorySelector)selector).selected_path(); }
		protected override string get_parent_key(ChooserSelector selector) { return Path.get_dirname(((PndCategorySelector)selector).path); }
		protected override string get_parent_child_name(ChooserSelector selector) { return Path.get_basename(((PndCategorySelector)selector).path); }
	}
}
