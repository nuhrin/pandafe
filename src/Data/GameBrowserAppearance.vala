/* GameBrowserAppearance.vala
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
using Catapult;

namespace Data
{
	public class GameBrowserAppearance : YamlObject
	{
		//const string DEFAULT_FONT_PATH  = "/usr/share/fonts/truetype/";
		const string DEFAULT_FONT = "/usr/share/fonts/truetype/DejaVuSansMono.ttf";
		const string DEFAULT_FONT_PREFERRED = "fonts/bitwise.ttf";
		public const int DEFAULT_FONT_SIZE = 24;
		public const int DEFAULT_ITEM_SPACING = 6;
		public const int MAX_FONT_SIZE = 30;
		public const int MIN_FONT_SIZE = 10;
		const string DEFAULT_BACKGROUND_COLOR = "#0F3854";
		const string DEFAULT_ITEM_COLOR = "#178ECB";
		const string DEFAULT_SELECTED_ITEM_COLOR = "#0F3854";
		const string DEFAULT_SELECTED_ITEM_BACKGROUND_COLOR = "#178ECB";
		const string DEFAULT_HEADER_FOOTER_COLOR = "#FFFFFF";
		construct {
		}

		public GameBrowserAppearance() {
		}
		public GameBrowserAppearance.default() {
			font = get_default_font_path();
			_font_size = DEFAULT_FONT_SIZE;
			item_spacing = DEFAULT_ITEM_SPACING;

			background_color = build_color(DEFAULT_BACKGROUND_COLOR);
			item_color = build_color(DEFAULT_ITEM_COLOR);
			selected_item_color = build_color(DEFAULT_SELECTED_ITEM_COLOR);
			selected_item_background_color = build_color(DEFAULT_SELECTED_ITEM_BACKGROUND_COLOR);
			header_footer_color = build_color(DEFAULT_HEADER_FOOTER_COLOR);
		}

		public string? font { get; set; }
		public int font_size { 
			get { return _font_size; }
			set { _font_size = normalize_font_size(value); }
		}
		int _font_size;
		public int item_spacing { get; set; }
		
		public Data.Color? background_color { get; set; }
		public Data.Color? item_color { get; set; }
		public Data.Color? selected_item_color { get; set; }
		public Data.Color? selected_item_background_color { get; set; }
		public Data.Color? header_footer_color { get; set; }
		
		public GameBrowserAppearance copy() {
			var copy = new GameBrowserAppearance();
			copy.font = font;
			copy._font_size = _font_size;
			copy.item_spacing = item_spacing;

			if (background_color != null)
				copy.background_color = background_color.copy();
			if (item_color != null)
				copy.item_color = item_color.copy();
			if (selected_item_color != null)
				copy.selected_item_color = selected_item_color.copy();
			if (selected_item_background_color != null)
				copy.selected_item_background_color = selected_item_background_color.copy();
			if (header_footer_color != null)
				copy.header_footer_color = header_footer_color.copy();
			return copy;			
		}
		
		public bool has_data() { return (font != null || item_color != null || selected_item_color != null || selected_item_background_color != null || background_color != null); }
		public bool matches(GameBrowserAppearance other) {
			if (font != other.font)
				return false;
			if (font_size != other.font_size)
				return false;
			if (item_spacing != other.item_spacing)
				return false;

			if (color_matches(a=>a.background_color, this, other) == false)
				return false;
			if (color_matches(a=>a.item_color, this, other) == false)
				return false;
			if (color_matches(a=>a.selected_item_color, this, other) == false)
				return false;
			if (color_matches(a=>a.selected_item_background_color, this, other) == false)
				return false;
			if (color_matches(a=>a.header_footer_color, this, other) == false)
				return false;
			
			return true;
		}
		static bool color_matches(owned MapFunc<Data.Color?,GameBrowserAppearance> get_color, GameBrowserAppearance a, GameBrowserAppearance b) {
			var color_a = get_color(a);
			var color_b = get_color(b);
			if (color_a == null) {
				if (color_b != null)
					return false;
			} else {
				if (color_b == null)
					return false;
				if (color_a.spec != color_b.spec)
					return false;
			}
			return true;
		}

		public GameBrowserUI create_ui(GameBrowserAppearance? fallback_appearance=null) {
			string? resolved_font = font;
			if (resolved_font == null && fallback_appearance != null)
				resolved_font = fallback_appearance.font;
			if (resolved_font == null || FileUtils.test(resolved_font, FileTest.EXISTS) == false)
				resolved_font = get_default_font_path();
				
			int resolved_font_size = font_size;
			if (resolved_font_size <= 0 && fallback_appearance != null)
				resolved_font_size = fallback_appearance.font_size;
			if (resolved_font_size <= 0)
				resolved_font_size = DEFAULT_FONT_SIZE;
			
			int resolved_item_spacing = item_spacing;
			if (resolved_item_spacing <= 0 && fallback_appearance != null)
				resolved_item_spacing = fallback_appearance.item_spacing;
			if (resolved_item_spacing <= 0)
				resolved_item_spacing = DEFAULT_ITEM_SPACING;
			
			var background_color = resolve_color(c=>c.background_color, fallback_appearance, DEFAULT_BACKGROUND_COLOR);
			var item_color = resolve_color(c=>c.item_color, fallback_appearance, DEFAULT_ITEM_COLOR);
			var selected_item_color = resolve_color(c=>c.selected_item_color, fallback_appearance, DEFAULT_SELECTED_ITEM_COLOR);
			var selected_item_background_color = resolve_color(c=>c.selected_item_background_color, fallback_appearance);
			if (selected_item_background_color == null)
				selected_item_background_color = background_color;
			var header_footer_color = resolve_color(c=>c.header_footer_color, fallback_appearance);
			if (header_footer_color == null)
				header_footer_color = selected_item_color;
				
			return new GameBrowserUI(resolved_font, resolved_font_size, (int16)resolved_item_spacing, 
			                         background_color.get_sdl_color(),
			                         item_color.get_sdl_color(), 
			                         selected_item_color.get_sdl_color(), 
			                         selected_item_background_color.get_sdl_color(), 
			                         header_footer_color.get_sdl_color());
		}
		public static string get_default_font_path() {
			string path = Path.build_filename(RuntimeEnvironment.system_data_dir(), DEFAULT_FONT_PREFERRED);
			if (FileUtils.test(path, FileTest.EXISTS) == false)
				path = DEFAULT_FONT;
			return path;
		}
		int normalize_font_size(int size) {
			if (size <= 0)
				return 0;
			if (size < MIN_FONT_SIZE)
				return MIN_FONT_SIZE;
			if (size > MAX_FONT_SIZE)
				return MAX_FONT_SIZE;
			return size;
		}
		
		Data.Color? resolve_color(owned MapFunc<Data.Color?,GameBrowserAppearance> get_color, GameBrowserAppearance? fallback_appearance, string? default_spec=null) {
			var resolved_color = get_color(this);
			if (resolved_color == null && fallback_appearance != null)
				resolved_color = get_color(fallback_appearance);
			if (resolved_color == null && default_spec != null)			
				resolved_color = build_color(default_spec);
			
			return resolved_color;
		}
		Data.Color build_color(string spec) {
			Data.Color color;
			if (Data.Color.parse(spec, out color) == false)
				GLib.error("Unable to parse color constant: %s", spec);	
			return color;
		}
		
		// yaml
		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var mapping = new Yaml.MappingNode();
			if (font != null) {
				mapping.set_scalar("font", builder.build_value(font));
				mapping.set_scalar("font-size", builder.build_value(font_size));
				mapping.set_scalar("item-spacing", builder.build_value(item_spacing));
			}

			if (background_color != null)
				mapping.set_scalar("background-color", builder.build_value(background_color));
			if (item_color != null)
				mapping.set_scalar("item-color", builder.build_value(item_color));
			if (selected_item_color != null)
				mapping.set_scalar("selected-item-color", builder.build_value(selected_item_color));
			if (selected_item_background_color != null)
				mapping.set_scalar("selected-item-background-color", builder.build_value(selected_item_background_color));			
			if (header_footer_color != null)
				mapping.set_scalar("header-footer-color", builder.build_value(header_footer_color));

			return mapping;	
		}
		protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return;
			foreach(var key in mapping.scalar_keys()) {
				switch(key.value) {
					case "font":					
						font = parser.parse<string>(mapping[key], DEFAULT_FONT);
						break;
					case "font-size":
						font_size = parser.parse<int>(mapping[key], 0);
						break;
					case "item-spacing":
						item_spacing = parser.parse<int>(mapping[key], 0);
						break;
					case "background-color":
						background_color = parse_color(mapping[key], parser);
						break;
					case "item-color":
						item_color = parse_color(mapping[key], parser);
						break;
					case "selected-item-color":
						selected_item_color = parse_color(mapping[key], parser);
						break;
					case "selected-item-background-color":
						selected_item_background_color = parse_color(mapping[key], parser);
						break;
					case "header-footer-color":
						header_footer_color = parse_color(mapping[key], parser);
						break;
				}
			}
		}
		Data.Color? parse_color(Yaml.Node node, Yaml.NodeParser parser) {
			var spec = parser.parse<string>(node, "");
			Data.Color color;
			if (Data.Color.parse(spec, out color) == true)
				return color;
			return null;
		}
	}
}
