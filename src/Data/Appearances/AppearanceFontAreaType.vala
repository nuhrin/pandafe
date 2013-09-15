/* AppearanceFontAreaType.vala
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
	public interface AppearanceFontAreaType<G> : AppearanceAreaType<G>
	{		
		public string font_resolved() {
			unowned string font = get_font();
			if (font != null && FileUtils.test(font, FileTest.EXISTS) == true)
				return font;
			return get_default_font_path();
		}
		public int font_size_resolved() {
			var font_size = get_font_size();
			if (font_size > 0)
				return font_size;
			return default_font_size();
		}
		
		protected abstract unowned string get_font();
		protected abstract void set_font(string font);
		protected abstract int get_font_size();
		protected abstract void set_font_size(int size);
		protected abstract bool monospace_font_required();
		int normalize_font_size(int size) {
			if (size <= 0)
				return 0;
			if (size < min_font_size())
				return min_font_size();
			if (size > max_font_size())
				return max_font_size();
			return size;
		}				
		
		protected void initialize_with_defaults() {
			set_font(get_default_font_path());
			set_font_size(default_font_size());
		}
		
		protected void copy_font_to(AppearanceFontAreaType other) {
			other.set_font(get_font());
			other.set_font_size(get_font_size());
		}
		protected void copy_font_from(AppearanceFontAreaType other) {
			set_font(other.get_font());
			set_font_size(other.get_font_size());
		}
		string get_root_font_path() { return Path.build_filename(RuntimeEnvironment.system_data_dir(), "fonts"); }
		string get_relative_font_path(string font) {
			var resolved = font;
			var root_path = get_root_font_path();
			if (font.has_prefix(root_path) == true) {
				resolved = font.replace(root_path, "");
				if (resolved.has_prefix(Path.DIR_SEPARATOR_S) == true)
					resolved = resolved.substring(1);
			}
			return resolved;
		}
		string get_absolute_font_path(string font) {
			if (font.has_prefix(Path.DIR_SEPARATOR_S) == true)
				return font;
			return Path.build_filename(get_root_font_path(), font);
		}
		// AppearanceType dependencies
		protected abstract int default_font_size();
		protected abstract int max_font_size();
		protected abstract int min_font_size();

		// yaml
		protected Yaml.Node build_yaml_node_font_area_implementation(Yaml.NodeBuilder builder) {
			var mapping = new Yaml.MappingNode();
			
			if (get_font() != null) {
				mapping.set_scalar("font", builder.build_value(get_relative_font_path(get_font())));
				mapping.set_scalar("font-size", builder.build_value(get_font_size()));
			}
			
			unowned ObjectClass klass = this.get_class();
	    	var properties = klass.list_properties();
	    	foreach(var property in properties) {
				if (property.name == "font" || property.name == "font_size")
					continue;
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
		protected void apply_yaml_node_font_area_implementation(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return;
				
			foreach(var key in mapping.scalar_keys()) {
				switch(key.value) {
					case "font":
						var font = parser.parse<string>(mapping[key], get_default_font_path());
						set_font(get_absolute_font_path(font));
						break;
					case "font-size":
						set_font_size(normalize_font_size(parser.parse<int>(mapping[key], 0)));
						break;
					default:
						var property = ((ObjectClass)this.get_type().class_peek()).find_property(key.value);
						if (property != null && (property.flags & ParamFlags.READWRITE) == ParamFlags.READWRITE) {
							if (property.value_type == typeof(Data.Color)) {
								this.set_property(property.name, parse_color(mapping[key], parser));
							} else {
								this.set_property(property.name, parser.parse_value_of_type(mapping[key], property.value_type));
							}
						}
						break;
				}
			}
		}

		// menu
		protected abstract void attribute_changed();
		protected abstract void color_changed();
			
		protected void build_menu_font_area_implementation(MenuBuilder builder) {
			var font_field = new FileField("font", "Font", null, "", "ttf", Path.build_filename(RuntimeEnvironment.system_data_dir(), "fonts"));
			font_field.chooser_title = get_field_description("Font");
			font_field.hide_root_path = true;
			if (monospace_font_required() == true) {
				font_field.set_validator((font_path) => {
					var font = new SDLTTF.Font(font_path, 12);
					if (font == null || font.is_fixed_width() == 0)
						return false;
					return true;
				}, "A monospaced font is required.");
			}
			font_field.changed.connect(() => {
				set_font(font_field.value);
				attribute_changed();
			});
			font_field.value = get_font();
			builder.add_field(font_field);
			
			var font_size_field = new IntegerField("font_size", "Font Size", null, get_font_size(), min_font_size(), max_font_size());
			font_size_field.changed.connect(() => {
				set_font_size(font_size_field.value);
				attribute_changed();
			});
			builder.add_field(font_size_field);
			
			build_area_fields(builder);
			
			builder.add_separator();
			
			builder.add_cancel_item();
			builder.add_save_item("Ok");
		}
		protected abstract void build_area_fields(MenuBuilder builder);		
		protected abstract void cleanup_area_fields();
		
	}
}
