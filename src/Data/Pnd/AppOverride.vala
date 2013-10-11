/* AppOverride.vala
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

using Catapult;
using Pandora.Config;
using Menus;
using Menus.Fields;
using Fields;

namespace Data.Pnd
{
	public class AppOverride : Object, MenuObject
	{
		AppItem app;
		AppItem app_direct;
		PndOvrAppFile app_ovr;
		
		public AppOverride(AppItem app) throws KeyFileError, FileError {
			this.app = app;
			app_direct = app.read_direct_from_pnd();
			app_ovr = app.get_ovr_file();
			title = app.title;
			clockspeed = app.clockspeed;
			appdata = app.appdata_dirname;
			main_category = app.main_category;
			sub_category = app.subcategory1;
		}
		
		public string? title { get; set; }
		public uint? clockspeed { get; set; }
		public string? appdata { get; set; }
		public string? main_category { get; set; }
		public string? sub_category { get; set; }
		
		public bool save() {
			//
			// first, resolve current values against app_direct and set app_ovr values
			// 		(process in reverse order, so that .ovr file is well ordered)
			
			// sub_category
			if (sub_category != null)
				sub_category = sub_category.strip();
			if (sub_category == null || sub_category == "" || sub_category == app_direct.subcategory1) {
				app_ovr.sub_category = null;
				sub_category = app_direct.subcategory1;
			} else {
				app_ovr.sub_category = sub_category;
			}
			// main_category
			if (main_category != null)
				main_category = main_category.strip();
			if (main_category == null || main_category == "" || main_category == app_direct.main_category) {
				app_ovr.main_category = null;
				main_category = app_direct.main_category;
			} else {
				app_ovr.main_category = main_category;
			}
			// appdata
			if (appdata != null)
				appdata = appdata.strip();
			if (appdata == null || appdata == "" || appdata == app_direct.appdata_dirname || appdata == app.package_id) {
				app_ovr.appdata = null;
				appdata = app_direct.appdata_dirname;
			} else {
				app_ovr.appdata = appdata;
			}
			// clockspeed
			if (clockspeed == null || clockspeed == app_direct.clockspeed) {
				app_ovr.clockspeed = null;
				clockspeed = app_direct.clockspeed;
			} else {
				app_ovr.clockspeed = clockspeed;
			}
			// title
			if (title != null)
				title = title.strip();
			if (title == null || title == "" || title == app_direct.title) {
				app_ovr.title = null;
				title = app_direct.title;
			} else {
				app_ovr.title = title;
			}
			
			//
			// then, try to write the ovr			
			if (app_ovr.write() == false)
				return false;
				
			//
			// success. update the app (AppItem) and rebuild the pnd cache
			app.title = title;
			app.clockspeed = clockspeed;
			app.appdata_dirname = appdata;
			app.main_category = main_category;
			app.subcategory1 = sub_category;
			Data.pnd_data().rebuild();
			Data.platforms().get_native_platform().reset_runtime_data();
			
			return true; 			
		}
		
		// menu
		protected void build_menu(MenuBuilder builder) {
			title_field = builder.add_string("title", "Title", null, title);
			
			uint clockspeed = 0;
			if (this.clockspeed != null && this.clockspeed != app_direct.clockspeed)
				clockspeed = this.clockspeed;
			var clockspeed_field = new ClockSpeedField("clockspeed", "Clockspeed", null, clockspeed, 120, 1000, 5);
			clockspeed_field.default_value = app_direct.clockspeed;
			builder.add_field(clockspeed_field);
			
			appdata_field = builder.add_string("appdata", "Appdata Dirname", null, appdata ?? app_direct.appdata_dirname ?? app.package_id);
			
			category_field = builder.add_string("main_category", "Main Category", null, main_category);
			subcategory_field = builder.add_string("sub_category", "Sub Category", null, sub_category);
		
			builder.add_separator();
			
			initialize_fields();
		}
		void initialize_fields() {
			title_field.changed.connect(() => {
				if (title_field.value == null || title_field.value.strip() == "")
					title_field.value = app_direct.title;
			});
			appdata_field.changed.connect(() => {
				if (appdata_field.value == null || appdata_field.value.strip() == "")
					appdata_field.value = app_direct.appdata_dirname ?? app.package_id;
			});
			category_field.changed.connect(() => {
				if (category_field.value == null || category_field.value.strip() == "")
					category_field.value = app_direct.main_category;
			});
			subcategory_field.changed.connect(() => {
				if ((subcategory_field.value == null || subcategory_field.value.strip() == "") && app_direct.subcategory1 != "")
					subcategory_field.value = app_direct.subcategory1;
			});
		}
		protected bool apply_changed_field(Menus.Menu menu, MenuItemField field) {
			if (field.id == "clockspeed") {
				var value = (uint)field.value;
				if (value == app_direct.clockspeed || value == 0)
					clockspeed = null;
				else
					clockspeed = value;
				return true;
			}
			return false;
		}
		protected bool save_object(Menus.Menu menu) {
			menu.message("Saving...");
			if (save() == false) {
				menu.error("unknown error saving ovr file.");
				return false;
			}
			return true;
		}
		protected void release_fields(bool was_saved) { 
			title_field = null;
			appdata_field = null;
			category_field = null;
			subcategory_field = null;
		}
		StringField title_field;
		StringField appdata_field;
		StringField category_field;
		StringField subcategory_field;		
	}
}
