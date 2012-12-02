/* AppItem.vala
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

using Catapult;

namespace Data.Pnd
{
	public class AppItem : YamlObject
	{
		weak PndItem pnd;
		public AppItem() { }
		public AppItem.from_app(Pandora.Apps.App app) {
			id = app.id;
			appdata_dirname = app.appdata_dirname;
			title = app.title;
			description = app.description;
			clockspeed = app.clockspeed;
			exec_command = app.exec_command ?? "";
			exec_arguments = app.exec_arguments;
			startdir = app.startdir;
			main_category = app.main_category ?? "";
			subcategory1 = app.main_category1 ?? "";
			subcategory2 = app.main_category2 ?? "";
		}
		public string id { get; set; }
		public string appdata_dirname { get; set; }
		public string title { get; set; }
		public string description { get; set; }
		public uint clockspeed { get; set; }
		public string exec_command { get; set; }
		public string? exec_arguments { get; set; }
		public string? startdir { get; set; }
		public string main_category { get; set; }
		public string subcategory1 { get; set; }
		public string subcategory2 { get; set; }

		public string filename { get { ensure_pnd(); return pnd.filename; } }
		public string package_id { get { ensure_pnd(); return pnd.pnd_id; } }
		public string get_fullpath() {
			ensure_pnd();
			return pnd.get_fullpath();
		}

		internal void set_pnd(PndItem pnd) { this.pnd = pnd; }
		void ensure_pnd() {
			if (pnd == null)
				error("AppItem '%s' has not been associated with a PndItem.", id);
		}
	}
}
