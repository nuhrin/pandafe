/* AppearanceTypeBase.vala
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
using Menus;
using Menus.Fields;

namespace Data.Appearances
{
	public interface AppearanceType<G> : Object, IYamlObject, MenuObject
	{
		public abstract G copy();
		public abstract void copy_from(G other);
		public abstract void set_name(string? name);
		public unowned string? name { get { return __get_name(); } }
		protected abstract unowned string? __get_name();
		
		protected abstract unowned string default_font();
		protected abstract unowned string default_font_preferred();
		protected abstract int default_font_size();
		protected abstract int max_font_size();
		protected abstract int min_font_size();
		protected abstract unowned string default_background_color();
		
		internal string get_default_font_path() {
			var default_font_path = Path.build_filename(RuntimeEnvironment.system_data_dir(), default_font_preferred());
			if (FileUtils.test(default_font_path, FileTest.EXISTS) == false)
				default_font_path = default_font();
			return default_font_path;		
		}
		internal Data.Color build_color(string spec) {
			Data.Color color;
			if (Data.Color.parse(spec, out color) == false)
				GLib.error("Unable to parse color constant: %s", spec);
			return color;
		}
		internal SDL.Color resolve_sdl_color(Data.Color color, string fallback_color_spec) {
			var resolved_color = color ?? build_color(fallback_color_spec);
			return resolved_color.get_sdl_color();
		}
		internal Data.Color? parse_color(Yaml.Node node, Yaml.NodeParser parser) {
			var spec = parser.parse<string>(node, "");
			Data.Color color;
			if (Data.Color.parse(spec, out color) == true)
				return color;
			return null;
		}

		protected abstract void appearance_changed();
		protected abstract void color_changed();
		protected abstract string get_appearance_description();
		internal string get_field_description(string field_name) { return "%s: %s %s".printf(name, get_appearance_description(), field_name); }
		
		protected ObjectBrowserField add_appearance_field<G>(MenuBuilder builder, string id, string name, string help, AppearanceType<G> appearance) {
			var field_handlers = get_field_handler_map();
			var copy = (AppearanceType<G>)appearance.copy();
			copy.set_name(appearance.name);
			var field = new ObjectBrowserField(id, name, get_field_description(name), help, copy);
			field.menu.set_metadata("header_footer_reveal", "true");
			field_handlers.set(field, field.cancelled.connect(() => {
				appearance_changed();
				copy.copy_from(appearance);
			}));	
			field_handlers.set(field, field.saved.connect(() =>  {
				appearance.copy_from(copy);
			}));
			builder.add_field(field);
			return field;
		}
		protected Fields.ColorField add_color_field(MenuBuilder builder, string id, string name, string help, Data.Color? color, string? spec=null) {
			var field_handlers = get_field_handler_map();
			var field = new Fields.ColorField(id, name, help, get_field_description(name) + " Color");
			var resolved_color = color;
			if (resolved_color == null && spec != null)
				resolved_color = build_color(spec);
			field.value.copy_from(resolved_color);
			field_handlers.set(field, field.selection_changed.connect((c) => {
				Value existing_property_value = Value(typeof(Data.Color));
				this.get_property(field.id, ref existing_property_value);
				Data.Color existing_color = (Data.Color)existing_property_value;
				if (existing_color != null)
					existing_color.copy_from(c);
				else
					this.set_property(field.id, c.copy());
				color_changed();
			}));
			builder.add_field(field);
			return field;
		}
		protected abstract Gee.HashMultiMap<MenuItemField, ulong> get_field_handler_map();
		protected void release_field_handlers() {
			var field_handlers = get_field_handler_map();
			if (field_handlers == null)
				return;
			foreach(var field in field_handlers.get_keys()) {
				foreach(ulong handler in field_handlers[field])
					field.disconnect(handler);
			}
			field_handlers.clear();
		}

	}	
}
