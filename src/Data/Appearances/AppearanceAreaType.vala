/* AppearanceAreaType.vala
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

using Catapult;
using Fields;
using Menus;
using Menus.Fields;

namespace Data.Appearances
{
	public interface AppearanceAreaType<G> : AppearanceType<G>
	{
		// yaml
		protected Yaml.Node build_yaml_node_area_implementation(Yaml.NodeBuilder builder) {
			var mapping = new Yaml.MappingNode();
			
			unowned ObjectClass klass = this.get_class();
	    	var properties = klass.list_properties();
	    	foreach(var property in properties) {
				if ((property.flags & ParamFlags.READWRITE) == ParamFlags.READWRITE) {
					Value existing_prop_value = Value(property.value_type);
					this.get_property(property.name, ref existing_prop_value);
					if (property.value_type == typeof(Data.Color)) {
						if (existing_prop_value.get_object() == null)
							continue;
					}
					mapping.set_scalar(property.name, builder.build_value(existing_prop_value));
				}
			}
	    	
			return mapping;
		}
		protected void apply_yaml_node_area_implementation(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return;
				
			foreach(var key in mapping.scalar_keys()) {				
				var property = ((ObjectClass)this.get_type().class_peek()).find_property(key.value);
				if (property != null && (property.flags & ParamFlags.READWRITE) == ParamFlags.READWRITE) {
					if (property.value_type == typeof(Data.Color)) {
						this.set_property(property.name, parse_color(mapping[key], parser));
					} else {
						this.set_property(property.name, parser.parse_value_of_type(mapping[key], property.value_type));
					}
				}
			}
		}

		// menu
		protected abstract void attribute_changed();
		protected abstract void color_changed();
			
		protected void build_menu_area_implementation(MenuBuilder builder) {
			build_area_fields(builder);
			
			builder.add_separator();
			
			builder.add_cancel_item();
			builder.add_save_item("Ok");
		}
		protected abstract void build_area_fields(MenuBuilder builder);		
		protected void cleanup_fields_implementation() {
			cleanup_area_fields();
		}
		protected abstract void cleanup_area_fields();
		
	}
}
