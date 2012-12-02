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

public class GameBrowserUI
{
	const int FONT_SIZE = 16;
	public const int16 SELECTOR_WITDH = 680;

	Data.Preferences preferences;
	Font _font;
	string _font_path;
	int _font_size;
	int16 _font_height;
	SDL.Color _item_color;
	SDL.Color _selected_item_color;
	SDL.Color _background_color;
	uint32 _background_color_rgb;
	Surface _blank_item_surface;
	
	public GameBrowserUI(string font_path, int font_size, SDL.Color item_color, SDL.Color selected_item_color, SDL.Color background_color) {
		preferences = Data.preferences();
		set_font(font_path, font_size);
		_item_color = item_color;
		_selected_item_color = selected_item_color;
		_background_color = background_color;
		_background_color_rgb = @interface.map_rgb(_background_color);
		_blank_item_surface = get_blank_background_surface(SELECTOR_WITDH, _font_height);
	}
	public GameBrowserUI.from_preferences() {
		preferences = Data.preferences();
		update_font_from_preferences();
		update_colors_from_preferences();
	}
	
	public unowned Font font { get { return _font; } }
	public unowned string font_path { get { return _font_path; } }
	public int font_size { get { return _font_size; } }
	public int16 font_height { get { return _font_height; } }
	public unowned SDL.Color item_color { get { return _item_color; } }
	public unowned SDL.Color selected_item_color { get { return _selected_item_color; } }
	public unowned SDL.Color background_color { get { return _background_color; } }
	public uint32 background_color_rgb { get { return _background_color_rgb; } }
	
	public signal void font_updated();
	public signal void colors_updated();
	
	public GameBrowserUI clone() {
		return new GameBrowserUI(_font_path, _font_size, _item_color, _selected_item_color, _background_color);
	}
	
	public void set_font(string font_path, int font_size) {
		_font = new Font(font_path, font_size);
		if (_font == null) {
			GLib.error("Error loading font: %s", SDL.get_error());
		}
		_font_size = font_size;
		_font_path = font_path;
		_font_height = (int16)font.height();
		font_updated();
	}
	public void set_colors(SDL.Color item, SDL.Color selected_item, SDL.Color background) {
		_item_color = item;
		_selected_item_color = selected_item;
		_background_color = background;
		_background_color_rgb = @interface.map_rgb(_background_color);
		_blank_item_surface = null;
		colors_updated();
	}
	public void set_appearance(Data.GameBrowserAppearance appearance, Data.GameBrowserAppearance? fallback_appearance=null) {
		var ui = appearance.create_ui(fallback_appearance);
		set_font(ui._font_path, ui._font_size);
		_item_color = ui._item_color;
		_selected_item_color = ui._selected_item_color;
		_background_color = ui._background_color;
		_background_color_rgb = ui._background_color_rgb;
		colors_updated();
	}
	
	public void update_font_from_preferences() {
		set_font(preferences.appearance.font, preferences.appearance.font_size);		
	}
	public void update_colors_from_preferences() {
		var appearance = preferences.appearance;
		set_colors(appearance.item_color.get_sdl_color(),
				   appearance.selected_item_color.get_sdl_color(),
				   appearance.background_color.get_sdl_color());
	}
	
	public unowned Surface get_blank_item_surface() { 
		if (_blank_item_surface == null)
			_blank_item_surface = get_blank_background_surface(SELECTOR_WITDH, _font_height);
		return _blank_item_surface; 
	}
	public Surface get_blank_background_surface(int width, int height) {
		return @interface.get_blank_surface(width, height, _background_color_rgb);
	}

	
	public Surface render_text(string text) {
		return _font.render_shaded(text, _item_color, _background_color);
	}
	public Surface render_text_selected(string text) {
		return _font.render_shaded(text, _selected_item_color, _background_color);
	}

	public Surface render_text_selected_fast(string text) {
		return _font.render(text, _selected_item_color);
	}
}
