/* OptionGroupingMenu.vala
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
using Data;
using Data.Options;
using Data.Programs;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class OptionGroupingMenu : Menu  
	{	
		OptionSet options;
		ProgramSettings settings;
		ProgramSettings? default_settings;
		string program_name;
		string? title_prefix;
		HashMap<Option,MenuItemField> field_hash;
		
		public OptionGroupingMenu(OptionGrouping grouping, ProgramSettings settings, ProgramSettings? default_settings, string program_name, string? title_prefix=null) {
			base("%s%s Settings: %s".printf(title_prefix ?? "", grouping.name, program_name));
			this.options = grouping.options;
			this.settings = settings;
			this.default_settings = default_settings;
			this.program_name = program_name;
			this.title_prefix = title_prefix;
			field_hash = new HashMap<Option,MenuItemField>();
		}
		
		public void populate_settings_from_fields(ProgramSettings target_settings) {
			foreach(var option in options) {
				if (title_prefix == null && option.locked == true)
					continue;
				
				var field = field_hash[option];
				var grouping_field = field as OptionGroupingField;
				if (grouping_field != null)
					grouping_field.populate_settings_from_fields(target_settings);
				else
					target_settings[option.setting_name] = option.get_setting_value_from_field(field);
			}
		}
				
		protected override void populate_items(Gee.List<MenuItem> items) {
			foreach(var option in options) {
				var grouping = option as OptionGrouping;
				if (grouping != null) {
					var field = grouping.get_grouping_field(settings, default_settings, program_name, title_prefix);
					field_hash[option] = field;
					items.add(field);
					continue;
				}
				
				string? setting = null;
				if (settings.has_key(option.setting_name) == true)
					setting = settings[option.setting_name];
				var field = option.get_setting_field(setting);
				if (title_prefix == null && option.locked == true)
					continue;
				field_hash[option] = field;
				items.add(field);
			}
			items.add(new MenuItemSeparator());
			var reset_index = items.size;
			items.add(new MenuItem.custom("Reset", "Reset settings to defaults", "", () => {
				settings.clear();
				if (default_settings != null)
					this.settings.merge_override(default_settings);
				refresh(reset_index);
			}));
			items.add(new MenuItem.cancel_item("Return"));
		}
		
		protected override void cleanup() {
			field_hash.clear();
		}
	}
}
