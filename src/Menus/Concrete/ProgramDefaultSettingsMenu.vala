/* ProgramDefaultSettingsMenu.vala
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
	public class ProgramDefaultSettingsMenu : Menu  
	{		
		public static bool edit(string program_name, ProgramDefaultSettings settings, OptionSet options, int clockspeed=-1, string? extra_arguments=null) {
			var menu = new ProgramDefaultSettingsMenu("Default", program_name, settings, options, clockspeed, extra_arguments);
			new MenuBrowser(menu).run();
			return menu.was_saved;
		}
	
		string? title_prefix;
		string program_name;
		OptionSet options;
		HashMap<Option,MenuItemField> field_hash;
		ProgramDefaultSettings original_settings;
		ProgramDefaultSettings settings;
		StringField extra_arguments_field;
		ClockSpeedField clockspeed_field;
		BooleanField show_output_field;
		int clockspeed;
		string? extra_arguments;
		
		public ProgramDefaultSettingsMenu(string title_prefix, string program_name, ProgramDefaultSettings settings, OptionSet options, int clockspeed=-1, string? extra_arguments=null) {
			base(title_prefix + " Settings: " + program_name);
			this.title_prefix = title_prefix;
			this.program_name = program_name;
			this.options = options;
			this.original_settings = settings;
			var effective = new ProgramDefaultSettings();
			effective.merge_override(settings);
			this.settings = effective;
			field_hash = new HashMap<Option,MenuItemField>();
			this.clockspeed = clockspeed;
			this.extra_arguments = extra_arguments;
		}
				
		public bool was_saved { get; private set; }
		
		protected override bool do_cancel() {
			was_saved = false;
			return true;
		}
		protected override bool do_save() {
			original_settings.clear();			
			foreach(var option in options) {
				var field = field_hash[option];
				var grouping_field = field as OptionGroupingField;
				if (grouping_field != null)
					grouping_field.populate_settings_from_fields(original_settings);
				else
					original_settings[option.setting_name] = option.get_setting_value_from_field(field);
			}
			original_settings.extra_arguments = extra_arguments_field.value;							
			original_settings.clockspeed = clockspeed_field.value;	
			if (show_output_field.value == true)		
				original_settings.show_output = true;
			else
				original_settings.show_output = false;
			was_saved = true;
			return true;
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) {
			foreach(var option in options) {
				var grouping = option as OptionGrouping;
				if (grouping != null) {
					var field = grouping.get_grouping_field(original_settings, null, program_name, title_prefix + " ");
					field_hash[option] = field;
					items.add(field);
					continue;
				}
				string? setting = null;
				if (settings.has_key(option.setting_name) == true)
					setting = settings[option.setting_name];
				var field = option.get_setting_field(setting);
				field_hash[option] = field;
				items.add(field);
			}
			string name = (options.size > 0) ? "Extra Arguments" : "Arguments";
			extra_arguments_field = new StringField("extra_arguments", name, null, settings.extra_arguments ?? "");
			if (this.extra_arguments != null)
				extra_arguments_field.value = this.extra_arguments;
			items.add(extra_arguments_field);
			
			clockspeed_field = new ClockSpeedField("clockspeed", "Clockspeed", null, settings.clockspeed, 150, 1000, 5);
			if (this.clockspeed > 0)
				clockspeed_field.value = this.clockspeed;
			items.add(clockspeed_field);
			show_output_field = new BooleanField("show_output", "Show Output", "Always show output dialog after program is run (useful for debugging)", settings.show_output ?? false);
			items.add(show_output_field);
			
			items.add(new MenuItemSeparator());
			var reset_index = items.size;
			items.add(new MenuItem.custom("Reset", "Reset settings to defaults", "", () => {
				this.settings.clear();
				refresh(reset_index);
			}));
			items.add(new MenuItem.cancel_item());
			items.add(new MenuItem.save_item());
		}
		
		protected override void cleanup() {
			field_hash = null;
			extra_arguments_field = null;
			clockspeed_field = null;
			show_output_field = null;
		}
	}
}
