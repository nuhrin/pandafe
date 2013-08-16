/* MenuUI.vala
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

using SDL;
using SDLTTF;
using Data.Appearances;

namespace Menus
{
	public class MenuUI
	{
		const int MAX_SMALL_FONT_SIZE = 17;
		Font _font;
		Font _font_small;
		string _font_path;
		int _font_size;
		int _font_small_size;
		int16 _font_height;
		int16 _font_small_height;
		int16 _char_width;
		int16 _item_spacing;
		int16 _value_control_spacing;
		SDL.Color _background_color;
		uint32 _background_color_rgb;
		SDL.Color _item_color;
		SDL.Color _selected_item_color;
		SDL.Color _selected_item_background_color;
		uint32 _selected_item_background_color_rgb;
		SDL.Color _text_cursor_color;
		uint32 _text_cursor_color_rgb;
		
		public MenuUI.from_appearance(MenuAppearance appearance) {
			appearance.update_ui_fonts(this);
			appearance.update_ui_colors(this);
		}
		
		public unowned string font_path { get { return _font_path; } }
		public unowned Font font { get { return _font; } }
		public int font_size { get { return _font_size; } }
		public int16 font_height { get { return _font_height; } }
		public unowned Font small_font { get { return _font_small; } }
		public int small_font_size { get { return _font_small_size; } }
		public int16 small_font_height { get { return _font_small_height; } }
		public int16 item_spacing { get { return _item_spacing; } }
		public int16 value_control_spacing { get { return _value_control_spacing; } }
		
		public unowned SDL.Color background_color { get { return _background_color; } }
		public uint32 background_color_rgb { get { return _background_color_rgb; } }
		public unowned SDL.Color item_color { get { return _item_color; } }
		public unowned SDL.Color selected_item_color { get { return _selected_item_color; } }
		public unowned SDL.Color selected_item_background_color { get { return _selected_item_background_color; } }
		public unowned SDL.Color text_cursor_color { get { return _text_cursor_color; } }
		public uint32 text_cursor_color_rgb { get { return _text_cursor_color_rgb; } }
		
		public signal void appearance_updated();
		public signal void font_updated();
		public signal void colors_updated();
		
		public void update_appearance(MenuAppearance appearance) {
			appearance.update_ui_fonts(this);
			appearance.update_ui_colors(this);
			appearance_updated();
		}
		public void update_fonts(MenuAppearance appearance) {
			appearance.update_ui_fonts(this);
			font_updated();
		}
		public void update_colors(MenuAppearance appearance) {
			appearance.update_ui_colors(this);
			colors_updated();
		}
		public void set_fonts(string font_path, int font_size, int16 item_spacing) {
			_font = new Font(font_path, font_size);
			if (_font == null) {
				GLib.error("Error loading font: %s", SDL.get_error());
			}
			_font_path = font_path;			
			_font_size = font_size;
			_font_height = (int16)_font.height();
			_char_width = (int16)_font.render_shaded(" ", _background_color, _background_color).w;
			
			var font_size_small = (int)(font_size * 0.7);
			if (font_size_small > MAX_SMALL_FONT_SIZE)
				font_size_small = MAX_SMALL_FONT_SIZE;
			_font_small = new Font(font_path, font_size_small);
			_font_small_size = font_size_small;
			_font_small_height = (int16)_font_small.height();
			
			_item_spacing = item_spacing;
			_value_control_spacing = item_spacing;
			if (item_spacing < font_height / 2)
				_value_control_spacing = font_height / 2;
		}
		public void set_colors(SDL.Color background, SDL.Color item, SDL.Color selected_item, SDL.Color selected_item_background, SDL.Color text_cursor) {
			_background_color = background;
			_background_color_rgb = @interface.map_rgb(_background_color);
			_item_color = item;
			_selected_item_color = selected_item;
			_selected_item_background_color = selected_item_background;
			_selected_item_background_color_rgb= @interface.map_rgb(_selected_item_background_color);
			_text_cursor_color = text_cursor;
			colors_updated();
		}				
		
		public int16 font_width(uint chars=1) { return (int16)(_char_width * chars); }
		public int get_selector_visible_items(int16 max_height) {
			var min_height = (font_height + item_spacing) * 3;
			if (max_height < min_height)
				return 3;
			return max_height / (font_height + item_spacing);			
		}
		
		public Surface get_blank_item_surface(int width) { 
			return get_blank_background_surface(width, _font_height);
		}
		public Surface get_blank_selected_item_surface(int width) { 
			return @interface.get_blank_surface(width, _font_height, _selected_item_background_color_rgb);
		}
		public Surface get_blank_background_surface(int width, int height) {
			return @interface.get_blank_surface(width, height, _background_color_rgb);
		}
		
		public Surface render_text(string text, bool enabled=true) {
			if (enabled == false)
				return render_text_disabled(text);
			return _font.render_shaded(text, _item_color, _background_color);
		}
		public Surface render_text_small(string text) {
			return _font_small.render_shaded(text, _item_color, _background_color);
		}

		public Surface render_text_disabled(string text, uchar alpha=128) {
			var surface = _font.render_shaded(text, _item_color, _background_color);
			surface.set_alpha(SurfaceFlag.RLEACCEL | SurfaceFlag.SRCALPHA, alpha);
			return surface;
		}
		public Surface render_text_selected(string text) {
			return _font.render_shaded(text, _selected_item_color, _selected_item_background_color);
		}
	}
	
}
