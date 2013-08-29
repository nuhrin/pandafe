/* AppearanceAreaUI.vala
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

using SDLTTF;

namespace Data.Appearances
{
	public abstract class AppearanceAreaUI {
		Font _font;
		string _font_path;
		int _font_size;
		int16 _font_height;

		public unowned Font font { get { return _font; } }
		public unowned string font_path { get { return _font_path; } }
		public int font_size { get { return _font_size; } }
		public int16 font_height { get { return _font_height; } }
		
		public signal void font_updated();
		
		public void set_area_font(AppearanceAreaType area) {
			_font_path = area.font_resolved();
			_font_size = area.font_size_resolved();
			_font = new Font(_font_path, _font_size);
			if (_font == null) {
				GLib.error("Error loading font: %s", SDL.get_error());
			}
			_font_height = (int16)font.height();
		}
		
		protected Font get_font_for_text_fit(int starting_font_size, int min_font_size, int text_length, int max_width) {
			int font_size = starting_font_size;
			while (font_size > min_font_size && font_size_fits_text(font_size, text_length, max_width) == false) {
				font_size--;
			}
			Font font = new Font(font_path, font_size);
			if (font == null)
				GLib.error("Error loading font: %s", SDL.get_error());
			return font;
		}
		bool font_size_fits_text(int font_size, int text_length, int max_width) {
			return (max_width >= (get_font_size_width(font_size) * text_length));
		}
		int get_font_size_width(int font_size) {
			if (_font_size_width_map == null)
				_font_size_width_map = new Gee.HashMap<int,int>();
			if (_font_size_width_map.has_key(font_size))
				return _font_size_width_map[font_size];
			
			Font font = new Font(font_path, font_size);
			if (font == null)
				GLib.error("Error loading font: %s", SDL.get_error());
			var width = font.render_shaded(" ", {0,0,0}, {0,0,0}).w;
			_font_size_width_map[font_size] = width;
			return width;
		}
		Gee.HashMap<int,int> _font_size_width_map;		
	}
}
