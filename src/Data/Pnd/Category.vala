/* Category.vala
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

namespace Data.Pnd
{
	public class Category : CategoryBase
	{
		ArrayList<SubCategory> _subcategories;
		Gee.List<SubCategory> _subcategories_view;
		public Category(string name) {
			base(name);
			_subcategories = new ArrayList<SubCategory>();
			_subcategories_view = _subcategories.read_only_view;
		}

		public Gee.List<SubCategory> subcategories { get { return _subcategories_view; } }
		public SubCategory? get_subcategory(string subcategory_name) {
			foreach(var sub in _subcategories) {
				if (sub.name == subcategory_name)
					return sub;
			}
			return null;
		}
		
		public Enumerable<AppItem> get_all_apps() {
			var e = new Enumerable<AppItem>(apps);
			foreach(var sub in subcategories)
				e = e.concat(sub.apps);
			return e;
		}

		internal SubCategory ensure_subcategory(string subcategory_name) {
			SubCategory sub = get_subcategory(subcategory_name);
			if (sub != null)
				return sub;
			sub = new SubCategory(subcategory_name, this);
			_subcategories.add(sub);
			return sub;
		}
	}

	public class SubCategory : CategoryBase
	{
		public SubCategory(string name, Category parent) { 
			base(name); 
			this.parent = parent;
		}
	}
	public abstract class CategoryBase : Object
	{
		string _name;
		ArrayList<AppItem> _apps;
		Gee.List<AppItem> _apps_view;
		public CategoryBase(string name) {
			_name = name;
			_apps = new ArrayList<AppItem>();
			_apps_view = _apps.read_only_view;
		}
		
		public Category? parent { get; protected set; }

		public unowned string name { get { return _name; } }

		public Gee.List<AppItem> apps { get { return _apps_view; } }

		public string get_path() {
			return (parent == null) ? name : Path.build_filename(parent.name, name);
		}

		internal void add_app(AppItem app) {
			_apps.add(app);
		}
	}
}
