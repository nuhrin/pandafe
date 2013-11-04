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
using Catapult.Helpers;
using Pandora.Config;

namespace Data.Pnd
{
	public class AppItem : YamlObject
	{
		const uint UNINITIALIZED_SUBAPP_NUMBER = 9999;
		weak PndItem pnd;
		public AppItem() { 
			subapp_number = UNINITIALIZED_SUBAPP_NUMBER;
		}
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
			subapp_number = app.subapp_number;
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
		public string subcategory1 { 
			get { return _subcategory1; }
			set { 
				_subcategory1 = value;
				_subcategory_display_name = null;
			}
		}
		string _subcategory1;
		public string subcategory2 { get; set; }
		public uint subapp_number { get; set;}
		
		public string filename { get { ensure_pnd(); return pnd.filename; } }
		public string package_id { get { ensure_pnd(); return pnd.pnd_id; } }
		public string get_fullpath() {
			ensure_pnd();
			return pnd.get_fullpath();
		}
		public unowned string mount_id { 
			get { 
				if (appdata_dirname != null)
					return appdata_dirname;
				return id; 				 
			}
		}
		public string menu_title() { 
			ensure_pnd();
			return "%s (%s)".printf(id, get_shortpath());
		}
		public string get_shortpath() {
			ensure_pnd();
			return Path.build_filename(Path.get_basename(pnd.path), pnd.filename);
		}

		public string subcategory_display_name { 
			get { 
				if (_subcategory_display_name == null) {
					if (_game_suffix_regex == null)
						_game_suffix_regex = new RegexHelper("""Game$""");
						
					_subcategory_display_name = _game_suffix_regex.replace(subcategory1, "");
				}
				return _subcategory_display_name;
			}
		}
		string _subcategory_display_name;
		static RegexHelper _game_suffix_regex = null;
		
		public PndOvrAppFile get_ovr_file() throws KeyFileError, FileError {
			if (subapp_number == UNINITIALIZED_SUBAPP_NUMBER)
				throw new FileError.FAILED("Cached pnd app data is missing subapp_number, please rescan.");
			return Pandora.Config.get_pnd_ovr_app_file(get_fullpath(), subapp_number);
		}
		
		public AppItem read_direct_from_pnd() throws KeyFileError, FileError {
			ensure_pnd();
			if (FileUtils.test(pnd.get_fullpath(), FileTest.EXISTS) == false)
				throw new FileError.FAILED("The pnd file '%s' was not found.".printf(pnd.get_fullpath()));
			var ovr_path = pnd.get_fullpath().replace(".pnd", ".ovr");
			FileUtils.rename(ovr_path, ovr_path+".off");
			var pnd = Data.pnd_data().get_pnd_direct(pnd.path, pnd.filename);
			FileUtils.rename(ovr_path+".off", ovr_path);
			if (pnd != null) {
				foreach(var app in pnd.apps) {
					if (app.id == this.id)
						return app;
				}
			}
			throw new KeyFileError.NOT_FOUND("App '%s' was not found in pnd '%s'.", this.id, get_fullpath());
		}

		internal void set_pnd(PndItem pnd) { this.pnd = pnd; }
		void ensure_pnd() {
			if (pnd == null)
				error("AppItem '%s' has not been associated with a PndItem.", id);
		}
	}
}
