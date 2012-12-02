/* Option.vala
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
	public abstract class Option : Object, MenuObject
	{
		const string NAME_CHARACTER_REGEX = "[[:alnum:] ]";
		weak OptionSet _parent;
		public Option(OptionSet parent) {
			_parent = parent;
		}
		
		public weak OptionSet parent { get { return _parent; } }
		
		public string name { get; set; }
		public string? help { get; set; }		
		public bool locked { get; set; }
		public string option { get; set; }
		
		public abstract OptionType option_type { get; }
		
		public unowned string setting_name { 
			get  {
				if (_setting_name != null)
					return _setting_name;
				return name;
			}
		}
		public virtual void set_setting_prefix(string prefix) { _setting_name = prefix + name; }
		string? _setting_name;		
		
		// menu
		protected virtual void build_menu(MenuBuilder builder) {
			add_name_field(name, builder);
			var option_field = builder.add_string("option", "Option", "-o, --option, etc", option ?? "");
			if (is_option_required() == true)
				option_field.required = true;
			build_edit_fields(builder);			
			builder.add_bool("locked", "Locked", "If true, games cannot change this setting.", locked);
			builder.add_string("help", "Help", "Help text to display during option selection", help ?? "");
		}
		protected abstract bool is_option_required();
		protected abstract void build_edit_fields(MenuBuilder builder);
		protected static void add_name_field(string? name, MenuBuilder builder) {
			var name_field = builder.add_string("name", "Name", null, name ?? "", NAME_CHARACTER_REGEX);
			name_field.required = true;
		}
		protected virtual bool apply_changed_field(Menus.Menu menu, MenuItemField field) { return false; }

		// field
		public abstract MenuItemField get_setting_field(string? setting);
		public abstract string get_setting_value_from_field(MenuItemField field);
		
		// 
		public abstract string get_option_from_setting_value(string? setting);
		
		// yaml
		internal virtual void populate_yaml_mapping(Yaml.NodeBuilder builder, Yaml.MappingNode mapping) {
			builder.populate_mapping_with_object_properties(this, mapping);
		}
		internal virtual void post_yaml_load() { }
	}
}
