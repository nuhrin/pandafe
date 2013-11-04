/*
 * AppearanceInfo.vala
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

namespace Data.Appearances
{
	public class AppearanceInfo
	{
		public static AppearanceInfo default {
			get {
				if (_default == null)
					_default = new AppearanceInfo("default", "[Default]");
				return _default;
			}
		}
		static AppearanceInfo _default;
		
		public AppearanceInfo(string id, string name, bool is_local=false) {
			_id = id;
			_name = name;
			this.is_local = is_local;
		}
		
		public unowned string id { get { return _id; } }
		string _id;
		
		public unowned string name { get { return _name; } }
		string _name;	
		
		public bool is_local { get; private set; }
		
		public static int compare(AppearanceInfo a, AppearanceInfo b) {
			return Utility.strcasecmp(a.name, b.name);
		}
	}
}
