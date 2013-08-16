/* GameBrowserUI.vala
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

using SDL;
using SDLTTF;
using Data.Appearances;

public class GameBrowserUI
{
	public const int16 SELECTOR_WITDH = 710;

	Font _font;
	string _font_path;
	int _font_size;
	int16 _font_height;
	int16 _item_spacing;
	SDL.Color _background_color;
	uint32 _background_color_rgb;
	SDL.Color _item_color;
	SDL.Color _selected_item_color;
	SDL.Color _selected_item_background_color;
	uint32 _selected_item_background_color_rgb;
	SDL.Color _header_footer_color;
	Surface _blank_item_surface;
	Surface _blank_selected_item_surface;
	
	public GameBrowserUI.from_appearance(GameBrowserAppearance appearance) {
		appearance.update_ui_fonts(this);
		appearance.update_ui_colors(this);
	}
	
	public unowned Font font { get { return _font; } }
	public unowned string font_path { get { return _font_path; } }
	public int font_size { get { return _font_size; } }
	public int16 font_height { get { return _font_height; } }
	public int16 item_spacing { get { return _item_spacing; } }
	public unowned SDL.Color background_color { get { return _background_color; } }
	public uint32 background_color_rgb { get { return _background_color_rgb; } }
	public unowned SDL.Color item_color { get { return _item_color; } }
	public unowned SDL.Color selected_item_color { get { return _selected_item_color; } }
	public unowned SDL.Color selected_item_background_color { get { return _selected_item_background_color; } }
	public unowned SDL.Color header_footer_color { get { return _header_footer_color; } }
		
	public signal void appearance_updated();
	public signal void font_updated();
	public signal void colors_updated();
	
	public void update_appearance(GameBrowserAppearance appearance) {
		appearance.update_ui_fonts(this);
		appearance.update_ui_colors(this);
		appearance_updated();
	}
	public void update_fonts(GameBrowserAppearance appearance) {
		appearance.update_ui_fonts(this);
		font_updated();
	}
	public void update_colors(GameBrowserAppearance appearance) {
		appearance.update_ui_colors(this);
		colors_updated();
	}
	public void set_fonts(string font_path, int font_size, int16 item_spacing) {
		_font = new Font(font_path, font_size);
		if (_font == null) {
			GLib.error("Error loading font: %s", SDL.get_error());
		}
		_font_size = font_size;
		_font_path = font_path;
		_font_height = (int16)font.height();
		_item_spacing = item_spacing;		
		_blank_item_surface = null;
		_blank_selected_item_surface = null;
	}
	public void set_colors(SDL.Color background, SDL.Color item, SDL.Color selected_item, SDL.Color selected_item_background, SDL.Color header_footer) {
		_background_color = background;
		_background_color_rgb = @interface.map_rgb(_background_color);
		_item_color = item;
		_selected_item_color = selected_item;
		_selected_item_background_color = selected_item_background;
		_selected_item_background_color_rgb= @interface.map_rgb(_selected_item_background_color);
		_header_footer_color = header_footer;
		_blank_item_surface = null;
		_blank_selected_item_surface = null;
	}
	
	public unowned Surface get_blank_item_surface() { 
		if (_blank_item_surface == null)
			_blank_item_surface = get_blank_background_surface(SELECTOR_WITDH, _font_height);
		return _blank_item_surface; 
	}
	public unowned Surface get_blank_selected_item_surface() { 
		if (_blank_selected_item_surface == null)
			_blank_selected_item_surface = @interface.get_blank_surface(SELECTOR_WITDH, _font_height, _selected_item_background_color_rgb);
		return _blank_selected_item_surface; 
	}
	public Surface get_blank_background_surface(int width, int height) {
		return @interface.get_blank_surface(width, height, _background_color_rgb);
	}

	
	public Surface render_text(string text) {
		return _font.render_shaded(text, _item_color, _background_color);
	}
	public Surface render_text_selected(string text) {
		return _font.render_shaded(text, _selected_item_color, _selected_item_background_color);
	}

	public Surface render_header_footer_text(string text) {
		return _font.render(text, _header_footer_color);
	}
}
