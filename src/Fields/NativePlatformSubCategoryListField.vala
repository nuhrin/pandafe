/* NativePlatformSubCategoryListField.vala
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
using Catapult;
using Data;
using Data.Platforms;
using Data.Pnd;
using Layers.Controls;
using Layers.Controls.List;
using Menus;
using Menus.Fields;

namespace Fields
{
	public class NativePlatformSubCategoryListField : StringListField
	{
		NativePlatformCategory category;
		Category? main_category;
		public NativePlatformSubCategoryListField(string id, string name, string? help=null, NativePlatformCategory category, string? title=null) {
			base(id, name, help, category.excluded_subcategories, title);
			this.category = category;
			main_category = Data.pnd_data().get_category(category.name);
		}
		
		protected override void activate(MenuSelector selector) {
			if (main_category == null || main_category.subcategories.size == 0) {
				message("No subcategories found for category " + category.name);
				return;
			}
			base.activate(selector);
		}
		protected override StringListEditor get_list_editor(string? title) {
			return new NativePlatformSubCategoryListEditor(id, title ?? name, help, main_category, value);
		}
		
		class NativePlatformSubCategoryListEditor : StringListEditor
		{
			Category? category;
			public NativePlatformSubCategoryListEditor(string id, string title, string? help=null, Category? category, Gee.List<string> list) {
				base(id, title, help, list);
				this.category = category;
			}
			protected override bool create_item(Rect selected_item_rect, out string item) {
				item = "";
				if (category == null)
					return false;
				var all_subcategory_names = new Enumerable<CategoryBase>(category.subcategories).select<string>(c=>c.name);
				var existing_names = (this.items.size == 0) 
					? new ArrayList<string>()
					: new Enumerable<ListItem<string>>(this.items).select<string>(i=>i.value).to_list();
				var additional_names = all_subcategory_names.where(name=>(existing_names.contains(name) == false)).to_list();
				if (additional_names.size == 0) {
					return false;
				}
				var selector = new StringSelector("native_subcategory_selector", 
					selected_item_rect.x + (int16)selected_item_rect.w, selected_item_rect.y, 250, additional_names);
				selector.can_select_single_item = true;
				selector.run();
				if (selector.was_canceled)
					return false;
				item = selector.selected_item_name();
				return true;
			}
			protected override bool edit_list_item(ListItem<string> item, uint index) {
				return true;
			}
			protected override bool can_edit(ListItem<string> item) { return false; }
			protected override bool can_insert() { return (category != null && items.size < category.subcategories.size); }			
		}
	}
}
