/* NativePlatformCategory.vala
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
using Catapult;
using Menus;
using Fields;

namespace Data.Platforms
{
	public class NativePlatformCategory : Object, MenuObject
	{
		construct {
			excluded_subcategories = new ArrayList<string>();
			excluded_apps = new ArrayList<string>();
		}
		public string name { get; set; }

		public Gee.List<string> excluded_subcategories { get; set; }
		public Gee.List<string> excluded_apps { get; set; }
		
		// menu
		protected void build_menu(MenuBuilder builder) {
			subcategories_field = new NativePlatformSubCategoryListField("excluded_subcategories", "Excluded SubCategories", 
				"If specified, apps in these subcategories will be excluded.", this);
			builder.add_field(subcategories_field);
			apps_field = new NativePlatformCategoryAppListField("excluded_apps", "Excluded Apps",
				"If specified, these specific apps will be excluded.", this);
			builder.add_field(apps_field);
		}
		
		NativePlatformSubCategoryListField subcategories_field;
		NativePlatformCategoryAppListField apps_field;
	}
}
