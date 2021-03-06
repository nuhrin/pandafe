/* NativePlatformCategoryAppListField.vala
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
	public class NativePlatformCategoryAppListField : StringListField
	{
		NativePlatformCategory category;
		Gee.List<AppItem>? category_apps;
		public NativePlatformCategoryAppListField(string id, string name, string? help=null, NativePlatformCategory category, string? title=null) {
			base(id, name, help, category.excluded_apps, title);
			this.category = category;
			var main_category = Data.pnd_data().get_category(category.name);
			if (main_category != null) {
				category_apps = new ArrayList<AppItem>();				
				var app_id_hashset = new HashSet<string>();
				var apps = main_category.get_all_apps()
					.sort((a,b)=>Utility.strcasecmp(a.title, b.title));
				foreach(var app in apps) {
					if (app_id_hashset.contains(app.id) == true)
						continue;
					app_id_hashset.add(app.id);
					category_apps.add(app);
				}
			}
		}
		
		protected override void activate(MenuSelector selector) {
			if (category_apps == null || category_apps.size == 0) {
				message("No apps found for category " + category.name);
				return;
			}
			base.activate(selector);
		}
		protected override StringListEditor get_list_editor(string? title) {
			return new NativePlatformCategoryAppListEditor(id, title ?? name, help, category_apps, value);
		}
		
		class NativePlatformCategoryAppListEditor : StringListEditor
		{
			Gee.List<AppItem>? category_apps;
			public NativePlatformCategoryAppListEditor(string id, string title, string? help=null, Gee.List<AppItem>? category_apps, Gee.List<string> list) {
				base(id, title, help, list);
				this.category_apps = category_apps;
			}
			protected override bool create_item(Rect selected_item_rect, out string item) {
				item = "";
				if (category_apps == null || category_apps.size == 0)
					return false;
				var all_category_apps = new Enumerable<AppItem>(category_apps);
				var existing_app_ids = (this.items.size == 0) 
					? new ArrayList<string>()
					: new Enumerable<ListItem<string>>(this.items).select<string>(i=>i.value).to_list();
				var additional_apps = all_category_apps.where(a=>(existing_app_ids.contains(a.id) == false)).to_list();
				if (additional_apps.size == 0) {
					return false;
				}
				var selector = new ValueSelector<AppItem>("native_category_app_selector",
					selected_item_rect.x + (int16)selected_item_rect.w, selected_item_rect.y, 250,
					a => a.title, additional_apps);
				selector.can_select_single_item = true;
				int selected_index = (int)selector.run();
				if (selector.was_canceled)
					return false;
				item = additional_apps[selected_index].id;
				return true;
			}
			protected override bool edit_list_item(ListItem<string> item, uint index) {
				return true;
			}
			protected override bool can_edit(ListItem<string> item) { return false; }
			protected override bool can_insert() { return (category_apps != null && items.size < category_apps.size); }	
		}
	}
}
