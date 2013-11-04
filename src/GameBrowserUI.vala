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
using Data.Appearances.GameBrowser;

public class GameBrowserUI
{
	SDL.Color _background_color;
	uint32 _background_color_rgb;
	
	public GameBrowserUI.from_appearance(GameBrowserAppearance appearance) {
		set_colors(appearance);
		header = new HeaderUI.from_appearance(appearance.header, this);
		list = new ListUI.from_appearance(appearance.list, this);
		footer = new FooterUI.from_appearance(appearance.footer, this);
	}
	
	public unowned SDL.Color background_color { get { return _background_color; } }
	public uint32 background_color_rgb { get { return _background_color_rgb; } }
	
	public HeaderUI header { get; private set; }
	public ListUI list { get; private set; }
	public FooterUI footer { get; private set; }
	
	public signal void appearance_updated();
	public signal void colors_updated();
	
	public void update_appearance(GameBrowserAppearance appearance) {		
		set_colors(appearance);
		header.update_appearance(appearance.header);
		list.update_appearance(appearance.list);
		footer.update_appearance(appearance.footer);
		appearance_updated();
	}
	public void update_colors(GameBrowserAppearance appearance) {
		set_colors(appearance);
		colors_updated();
	}
	void set_colors(GameBrowserAppearance appearance) {
		_background_color = appearance.background_color_sdl();
		_background_color_rgb = @interface.map_rgb(_background_color);		
	}
	
	public Surface get_blank_background_surface(int width, int height) {
		return @interface.get_blank_surface(width, height, _background_color_rgb);
	}

	public class HeaderUI : AppearanceAreaUI {
		GameBrowserUI ui;
		SDL.Color _text_color;

		public HeaderUI.from_appearance(GameBrowserHeader header, GameBrowserUI ui) {
			this.ui = ui;
			update_appearance(header);
		}
		
		public unowned SDL.Color text_color { get { return _text_color; } }
		
		public signal void colors_updated();
		
		public void update_appearance(GameBrowserHeader header) {
			set_area_font(header);
			set_colors(header);
		}
		public void update_font(GameBrowserHeader header) {
			set_area_font(header);
			font_updated();
		}
		public void update_colors(GameBrowserHeader header)  {
			set_colors(header);
			colors_updated();
			@interface.peek_layer().update(false);
		}
		void set_colors(GameBrowserHeader header) {
			_text_color = header.text_color_sdl();
		}
		
		public Surface render_text(string text) {
			return font.render(text, _text_color);
		}		
	}
	public class FooterUI : AppearanceAreaUI {
		GameBrowserUI ui;
		SDL.Color _text_color;
		
		public FooterUI.from_appearance(GameBrowserFooter footer, GameBrowserUI ui) {
			this.ui = ui;
			update_appearance(footer);
		}
		public unowned SDL.Color text_color { get { return _text_color; } }
		
		public signal void colors_updated();
		
		public void update_appearance(GameBrowserFooter footer) {
			set_area_font(footer);
			set_colors(footer);
		}
		public void update_font(GameBrowserFooter footer) {
			set_area_font(footer);
			font_updated();
		}
		public void update_colors(GameBrowserFooter footer)  {
			set_colors(footer);
			colors_updated();
			@interface.peek_layer().update(false);
		}
		void set_colors(GameBrowserFooter footer) {
			_text_color = footer.text_color_sdl();
		}
		
		public Surface render_text(string text) {
			return font.render(text, _text_color);
		}
	}
	public class ListUI : AppearanceAreaUI  {
		GameBrowserUI ui;
		SDL.Color _item_color;
		SDL.Color _selected_item_color;
		SDL.Color _selected_item_background_color;
		uint32 _selected_item_background_color_rgb;
		Surface _blank_item_surface;
		Surface _blank_selected_item_surface;

		public ListUI.from_appearance(GameBrowserList list, GameBrowserUI ui) {
			this.ui = ui;
			spacing = new ListSpacingUI(this);
			update_appearance(list);
		}
		public ListSpacingUI spacing { get; private set; }
		public int16 selector_width() { return (int16)(@interface.screen_width - (spacing.left + spacing.right) - 40); }
		
		public unowned SDL.Color item_color { get { return _item_color; } }
		public unowned SDL.Color selected_item_color { get { return _selected_item_color; } }
		public unowned SDL.Color selected_item_background_color { get { return _selected_item_background_color; } }

		public signal void colors_updated();

		public void update_appearance(GameBrowserList list, bool update_screen=false) {
			spacing.update_appearance(list.spacing);
			set_font(list);
			set_colors(list);
			if (update_screen)
				ui.appearance_updated();
		}
		public void update_font(GameBrowserList list) {
			set_font(list);
			font_updated();
		}
		public void update_colors(GameBrowserList list) {
			set_colors(list);
			colors_updated();
			@interface.peek_layer().update(false);
		}
		void set_font(GameBrowserList list) {
			set_area_font(list);
			_blank_item_surface = null;
			_blank_selected_item_surface = null;
		}		
		void set_colors(GameBrowserList list) {
			_item_color = list.item_color_sdl();
			_selected_item_color = list.selected_item_color_sdl();
			_selected_item_background_color = list.selected_item_background_color_sdl();
			_selected_item_background_color_rgb= @interface.map_rgb(_selected_item_background_color);
			_blank_item_surface = null;
			_blank_selected_item_surface = null;
		}

		public unowned Surface get_blank_item_surface() { 
			if (_blank_item_surface == null)
				_blank_item_surface = ui.get_blank_background_surface(selector_width(), font_height);
			return _blank_item_surface; 
		}
		public unowned Surface get_blank_selected_item_surface() { 
			if (_blank_selected_item_surface == null)
				_blank_selected_item_surface = @interface.get_blank_surface(selector_width(), font_height, _selected_item_background_color_rgb);
			return _blank_selected_item_surface; 
		}
		public Surface get_blank_background_surface(int width, int height) {
			return ui.get_blank_background_surface(width, height);
		}

		public Surface render_text(string text) {
			return _render_text(text, _item_color, ui.background_color);
		}
		public Surface render_text_selected(string text) {
			return _render_text(text, _selected_item_color, _selected_item_background_color);
		}
		Surface _render_text(string* text, SDL.Color text_color, SDL.Color background_color) {
			int max_width = get_blank_item_surface().w - (spacing.item_h * 2);
			if (get_text_width(text) <= max_width)
				return font.render_shaded(text, text_color, background_color);
			
			var sb = new StringBuilder(text);
			do {
				sb.truncate(sb.len-1);
			} while(get_text_width(sb.str) > max_width);
			
			return font.render_shaded(sb.str, text_color, background_color);
		}
	}
	public class ListSpacingUI {
		ListUI list;
		int16 _top;
		int16 _bottom;
		int16 _left;
		int16 _right;
		int16 _item_v;
		int16 _item_h;
		
		public ListSpacingUI(ListUI list) {
			this.list = list;
		}
		public int16 top { get { return _top; } }
		public int16 bottom { get { return _bottom; } }
		public int16 left { get { return _left; } }
		public int16 right { get { return _right; } }
		public int16 item_v { get { return _item_v; } }
		public int16 item_h { get { return _item_h; } }
		
		public void update_appearance(GameBrowserListSpacing spacing) {
			set_attributes(spacing);
		}
		public void update_attributes(GameBrowserListSpacing spacing) {
			set_attributes(spacing);
			list.font_updated();
		}
		void set_attributes(GameBrowserListSpacing spacing) {
			_top = spacing.top_resolved();
			_bottom = spacing.bottom_resolved();
			_left = spacing.left_resolved();
			_right = spacing.right_resolved();
			_item_v = spacing.item_v_resolved();
			_item_h = spacing.item_h_resolved();
		}
	}
}
