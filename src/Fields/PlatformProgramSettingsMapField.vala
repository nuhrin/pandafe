/* PlatformProgramSettingsMapField.vala
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

using Data;
using Data.Platforms;
using Data.Programs;
using Menus.Fields;
using Menus.Concrete;

namespace Fields
{	
	public class PlatformProgramSettingsMapField : MenuItemField
	{
		string platform_name;		
		PlatformProgramSettingsMap settings_map;
		Gee.List<Program> programs;
		public PlatformProgramSettingsMapField(string id, string name, string? help=null, string platform_name, PlatformProgramSettingsMap program_settings, Gee.List<Program> programs) {
			base(id, name, help);
			this.platform_name = platform_name;
			settings_map = new PlatformProgramSettingsMap.clone(program_settings);
			this.programs = programs;
		}

		public new PlatformProgramSettingsMap value {
			get { return settings_map; }
			set { change_value(value); }
		}
		
		public void set_platform_name(string platform_name) {
			this.platform_name = platform_name;
		}
		public void set_programs(Gee.List<Program> programs) {
			this.programs = programs;
		}
		
		public override bool is_menu_item() { return true; }
		public override string get_value_text() { return ""; }
		public override int get_minimum_menu_value_text_length() { return 0; }
		protected override bool has_value() { return true; }
		
		protected override Value get_field_value() { return settings_map; }
		protected override void set_field_value(Value value) { change_value((PlatformProgramSettingsMap)value); }

		protected override void activate(Menus.MenuSelector selector) {
			if (PlatformProgramSettingsMapMenu.edit(platform_name, settings_map, programs) == true)
				changed();
		}
		
		void change_value(PlatformProgramSettingsMap new_value) {
			settings_map = new_value;
			changed();
		}
	}
		
}
