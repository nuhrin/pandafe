/* FlagOption.vala
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
using Menus;
using Menus.Fields;

namespace Data.Options
{
	public class FlagOption : Option
	{
		public FlagOption(OptionSet parent) {
			base(parent);
		}
		public override OptionType option_type { get { return OptionType.FLAG; } }
		public bool on_by_default { get; set; }
		
		// menu
		protected override void build_edit_fields(MenuBuilder builder) {
			builder.add_bool("on_by_default", "On By Default", null, on_by_default);
		}
		protected override bool is_option_required() { return true; }
		
		// setting field
		public override MenuItemField get_setting_field(string? setting) {
			return new BooleanField(name, name, help, get_setting_value(setting));
		}
		public override string get_setting_value_from_field(MenuItemField field) {
			return (field as BooleanField).value.to_string();
		}
		
		// setting
		public override string get_option_from_setting_value(string? setting) {
			if (setting == null)
				return (on_by_default == true) ? option : "";
				
			if (get_setting_value(setting) == true)
				return option;
			return "";
		}
		
		bool get_setting_value(string? setting) {
			if (setting != null) {
				bool val;
				if (bool.try_parse(setting, out val) == true)
					return val;
			}
			return on_by_default;
		}
	}
}
