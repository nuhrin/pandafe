/* MenuAppearance.vala
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

using Gee;
using Catapult;

using Fields;
using Menus;
using Menus.Fields;

namespace Data.Appearances
{
	public class MenuAppearance : YamlObject, MenuObject
	{
		const string DEFAULT_FONT = "/usr/share/fonts/truetype/DejaVuSansMono.ttf";
		const string DEFAULT_FONT_PREFERRED = "fonts/monof55.ttf";
		const int DEFAULT_FONT_SIZE = 24;
		const int DEFAULT_ITEM_SPACING = 6;
		const int MAX_FONT_SIZE = 30;
		const int MIN_FONT_SIZE = 10;
		const string DEFAULT_BACKGROUND_COLOR = "#000000";
		const string DEFAULT_ITEM_COLOR = "#FFFFFF";
		const string DEFAULT_SELECTED_ITEM_COLOR = "#000000";
		const string DEFAULT_SELECTED_ITEM_BACKGROUND_COLOR = "#FFFFFF";
		const string DEFAULT_TEXT_CURSOR_COLOR = "#00498A";
		
		construct {
		}
		public MenuAppearance.default() {
			font = get_default_font_path();
			_font_size = DEFAULT_FONT_SIZE;
			item_spacing = DEFAULT_ITEM_SPACING;

			background_color = build_color(DEFAULT_BACKGROUND_COLOR);
			item_color = build_color(DEFAULT_ITEM_COLOR);
			selected_item_color = build_color(DEFAULT_SELECTED_ITEM_COLOR);
			selected_item_background_color = build_color(DEFAULT_SELECTED_ITEM_BACKGROUND_COLOR);
			text_cursor_color = build_color(DEFAULT_TEXT_CURSOR_COLOR);
		}
		
		public string? font { get; set; }
		public int font_size { 
			get { return _font_size; }
			set { _font_size = normalize_font_size(value); }
		}
		int _font_size;
		public int item_spacing { get; set; }
		
		public Data.Color background_color { get; set; }
		public Data.Color item_color { get; set; }
		public Data.Color selected_item_color { get; set; }
		public Data.Color selected_item_background_color { get; set; }
		public Data.Color text_cursor_color { get; set; }

		public MenuAppearance copy() {
			var copy = new MenuAppearance();
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
			if (text_cursor_color != null)
				copy.text_cursor_color = text_cursor_color.copy();
			return copy;			
		}

		public MenuUI create_ui() {
			return new MenuUI.from_appearance(this);
		}
		public void update_ui_fonts(MenuUI ui)  {
			string? resolved_font = font;			
			if (resolved_font == null || FileUtils.test(resolved_font, FileTest.EXISTS) == false)
				resolved_font = get_default_font_path();
			
			int resolved_font_size = font_size;
			if (resolved_font_size <= 0)
				resolved_font_size = DEFAULT_FONT_SIZE;
			
			int resolved_item_spacing = item_spacing;
			if (resolved_item_spacing <= 0)
				resolved_item_spacing = DEFAULT_ITEM_SPACING;
			
			ui.set_fonts(resolved_font, resolved_font_size, (int16)resolved_item_spacing);
		}
		public void update_ui_colors(MenuUI ui) {
			var background = background_color ?? build_color(DEFAULT_BACKGROUND_COLOR);
			var item = item_color ?? build_color(DEFAULT_ITEM_COLOR);
			var selected_item = selected_item_color ?? build_color(DEFAULT_SELECTED_ITEM_COLOR);
			var selected_item_background = selected_item_background_color;
			if (selected_item_background == null)
				selected_item_background = background;
			var text_cursor = text_cursor_color ?? build_color(DEFAULT_TEXT_CURSOR_COLOR);
			
			ui.set_colors(background.get_sdl_color(), item.get_sdl_color(), selected_item.get_sdl_color(), selected_item_background.get_sdl_color(), text_cursor.get_sdl_color());			
		}

		string get_default_font_path() {
			string path = Path.build_filename(RuntimeEnvironment.system_data_dir(), DEFAULT_FONT_PREFERRED);
			if (FileUtils.test(path, FileTest.EXISTS) == false)
				path = DEFAULT_FONT;
			return path;
		}
		int normalize_font_size(int size) {
			if (size <= 0)
				return MIN_FONT_SIZE;
			if (size < MIN_FONT_SIZE)
				return MIN_FONT_SIZE;
			if (size > MAX_FONT_SIZE)
				return MAX_FONT_SIZE;
			return size;
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
			if (text_cursor_color != null)
				mapping.set_scalar("text-cursor-color", builder.build_value(text_cursor_color));

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
					case "test-cursor-color":
						text_cursor_color = parse_color(mapping[key], parser);
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

		// menu
		public signal void font_changed();
		public signal void color_changed();
			
		protected void build_menu(MenuBuilder builder) {
			font_field = new FileField("font", "Font", null, "", "ttf", Path.build_filename(RuntimeEnvironment.system_data_dir(), "fonts"));
			font_field.set_validator((font_path) => {
				var font = new SDLTTF.Font(font_path, 12);
				if (font == null || font.is_fixed_width() == 0)
					return false;
				return true;
			}, "A monospaced font is required.");
			//font_field.set_minimum_menu_value_text_length(15);
			builder.add_field(font_field);
			font_size_field = new IntegerField("font_size", "Font Size", null, DEFAULT_FONT_SIZE, MIN_FONT_SIZE, MAX_FONT_SIZE);
			builder.add_field(font_size_field);
			item_spacing_field = new IntegerField("item_spacing", "Item Spacing", null, DEFAULT_ITEM_SPACING, 1, 15);
			builder.add_field(item_spacing_field);
			
			builder.add_separator();
			
			background_color_field = new ColorField("background_color", "Background", "Background Color");
			builder.add_field(background_color_field);
			item_color_field = new ColorField("item_color", "Item", "Item Color");
			builder.add_field(item_color_field);
			selected_item_color_field = new ColorField("selected_item_color", "Selected Item", "Selected Item Color");
			builder.add_field(selected_item_color_field);
			selected_item_background_color_field = new ColorField("selected_item_background_color", "Selected Background", "Selected Item Background Color");
			builder.add_field(selected_item_background_color_field);
			text_cursor_color_field = new ColorField("text_cursor_color", "Text Cursor", "Text Cursor Color");
			builder.add_field(text_cursor_color_field);
			
			initialize();
			font_field.changed.connect(on_font_change);
			font_size_field.changed.connect(on_font_change);
			item_spacing_field.changed.connect(on_font_change);

			background_color_field.changed.connect(on_color_change);
			background_color_field.selection_changed.connect((c) => {
				sync_selected_item_background = false;
				this.background_color.copy_from(c);
				if (background_color_field.value.spec == selected_item_background_color_field.value.spec) {
					if (this.selected_item_background_color != null)
						this.selected_item_background_color.copy_from(c);
					else
						this.selected_item_background_color = c.copy();
					sync_selected_item_background = true;
				}
				color_changed();
			});		
			item_color_field.changed.connect(on_color_change);
			item_color_field.selection_changed.connect((c) => {
				this.item_color.copy_from(c);
				color_changed();
			});
			selected_item_color_field.changed.connect(on_color_change);
			selected_item_color_field.selection_changed.connect((c) => {
				this.selected_item_color.copy_from(c);
				color_changed();
			});
			selected_item_background_color_field.changed.connect(() => {
				sync_selected_item_background = false;
				on_color_change();
			});
			selected_item_background_color_field.selection_changed.connect((c) => {
				if (this.selected_item_background_color != null)
					this.selected_item_background_color.copy_from(c);
				else
					this.selected_item_background_color = c.copy();
				color_changed();
			});
			text_cursor_color_field.changed.connect(on_color_change);
			text_cursor_color_field.selection_changed.connect((c) => {
				if (this.text_cursor_color != null)
					this.text_cursor_color.copy_from(c);
				else
					this.text_cursor_color = c.copy();				
				color_changed();
			});

		}
		protected bool suppress_default_actions() { return true; }		
		protected bool apply_changed_field(Menus.Menu menu, MenuItemField field) { return true; }				
		protected void release_fields(bool was_saved) {
			GLib.message("releasing fields");
			font_field = null;
			font_size_field = null;
			item_spacing_field = null;
			background_color_field = null;
			item_color_field = null;
			selected_item_color_field = null;
			selected_item_background_color_field = null;
			text_cursor_color_field = null;
			sync_selected_item_background = false;
		}
		
		void initialize() {
			font_field.value = this.font;
			font_size_field.value = this.font_size;
			item_spacing_field.value = this.item_spacing;
			
			var background = background_color ?? build_color(DEFAULT_BACKGROUND_COLOR);
			var item = item_color ?? build_color(DEFAULT_ITEM_COLOR);
			var selected_item = selected_item_color ?? build_color(DEFAULT_SELECTED_ITEM_COLOR);
			var selected_item_background = selected_item_background_color;
			if (selected_item_background == null)
				selected_item_background = background;
			var text_cursor = text_cursor_color ?? build_color(DEFAULT_TEXT_CURSOR_COLOR);
		
			background_color_field.value.copy_from(background);
			item_color_field.value.copy_from(item);
			selected_item_color_field.value.copy_from(selected_item);			
			selected_item_background_color_field.value.copy_from(selected_item_background);
			text_cursor_color_field.value.copy_from(text_cursor);
		}
		void on_font_change() {
			this.font = font_field.value;
			this.font_size = font_size_field.value;
			this.item_spacing = item_spacing_field.value;
			font_changed();
		}
		void on_color_change() {			
			this.background_color.copy_from(background_color_field.value);			
			this.item_color.copy_from(item_color_field.value);
			this.selected_item_color.copy_from(selected_item_color_field.value);
			
			if (sync_selected_item_background == true) {
				if (this.selected_item_background_color != null)
					this.selected_item_background_color.copy_from(background_color_field.value);
			}  else {
				if (this.selected_item_background_color != null)
					this.selected_item_background_color.copy_from(selected_item_background_color_field.value);
				else
					this.selected_item_background_color = selected_item_background_color_field.value.copy();					
			}
			
			this.text_cursor_color.copy_from(text_cursor_color_field.value);
			
			if (sync_selected_item_background == true) {
				refresh(4);
				sync_selected_item_background = false;
			}					
			
			color_changed();
		}
		
		FileField font_field;
		IntegerField font_size_field;
		IntegerField item_spacing_field;
		ColorField item_color_field;
		ColorField selected_item_color_field;
		ColorField selected_item_background_color_field;
		ColorField background_color_field;
		ColorField text_cursor_color_field;
		bool sync_selected_item_background;
	}
}
