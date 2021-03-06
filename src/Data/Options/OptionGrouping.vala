/* OptionGrouping.vala
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
using Fields;
using Data.Programs;

namespace Data.Options
{
	public class OptionGrouping : Option
	{
		public OptionGrouping(OptionSet parent) {
			base(parent);
			options = new OptionSet();
		}
		public override OptionType option_type { get { return OptionType.GROUPING; } }
		public OptionSet options { get; set; }
		
		public override void set_setting_prefix(string prefix) { 
			base.set_setting_prefix(prefix);
			foreach(var option in options)
				option.set_setting_prefix(this.setting_name + "/");
		}
		
		// menu
		protected override void build_menu(MenuBuilder builder) {
			add_name_field(name, builder);
			var options_field = new ProgramOptionsListField("options", "Options", null, options);
			options_field.required = true;
			builder.add_field(options_field);
			builder.add_string("help", "Help", "Help text to display during option selection", help ?? "");
		}
		protected override bool is_option_required() { return false; }
		protected override void build_edit_fields(MenuBuilder builder) { }
		protected override bool apply_changed_field(Menus.Menu menu, MenuItemField field) {
			if(field.id == "options") {
				options = (OptionSet)field.value;
				return true;
			}
			return false;
		}
		protected bool save_object(Menus.Menu menu) {
			set_option_setting_prefix();
			return true;
		}
		
		// setting field
		public override MenuItemField get_setting_field(string? setting) {
			assert_not_reached();
		}
		public override string get_setting_value_from_field(MenuItemField field) {
			return "";
		}
		public OptionGroupingField get_grouping_field(ProgramSettings settings, ProgramSettings? default_settings, string program_name, string? title_prefix=null) {
			return new OptionGroupingField(name, name, help, this, settings, default_settings, program_name, title_prefix);
		}
		
		// setting
		public override string get_option_from_setting_value(string? setting) {
			return "";
		}
		
		
		// yaml
		internal override void populate_yaml_mapping(Yaml.NodeBuilder builder, Yaml.MappingNode mapping) {
			builder.add_item_to_mapping("name", name, mapping);
			builder.add_item_to_mapping("help", help, mapping);
			builder.add_item_to_mapping("options", options, mapping);
		}
		internal override void post_yaml_load() { 
			set_option_setting_prefix();
		}
		void set_option_setting_prefix() {
			foreach(var option in options)
				option.set_setting_prefix(this.setting_name + "/");			
		}
	}
}
