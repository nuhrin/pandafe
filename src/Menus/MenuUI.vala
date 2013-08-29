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

using Gee;
using SDL;
using SDLTTF;
using Data.Appearances;
using Data.Appearances.Menu;

namespace Menus
{
	public class MenuUI
	{		
		const int MAX_SMALL_FONT_SIZE = 17;
		const int MIN_SMALL_FONT_SIZE = 10;
		
		SDL.Color _background_color;
		uint32 _background_color_rgb;
		
		public MenuUI.from_appearance(MenuAppearance appearance) {
			set_colors(appearance);
			header = new HeaderUI.from_appearance(appearance.header, this);
			controls = new ControlsUI.from_appearance(appearance.controls, this);
			footer = new FooterUI.from_appearance(appearance.footer, this);
		}
		
		public unowned SDL.Color background_color { get { return _background_color; } }
		public uint32 background_color_rgb { get { return _background_color_rgb; } }
		
		public HeaderUI header { get; private set; }
		public ControlsUI controls { get; private set; }
		public FooterUI footer { get; private set; }

		public signal void appearance_updated();
		public signal void colors_updated();
		public signal void font_updated();
		
		public void update_appearance(MenuAppearance appearance) {
			set_colors(appearance);
			header.update_appearance(appearance.header);
			controls.update_appearance(appearance.controls);
			footer.update_appearance(appearance.footer);
			appearance_updated();
		}
		public void update_colors(MenuAppearance appearance) {
			set_colors(appearance);
			colors_updated();
		}
		void set_colors(MenuAppearance appearance) {
			_background_color = appearance.background_color_sdl();
			_background_color_rgb = @interface.map_rgb(_background_color);
		}				
		
		public Surface get_blank_background_surface(int width, int height) {
			return @interface.get_blank_surface(width, height, _background_color_rgb);
		}		

		public class HeaderUI : AppearanceAreaUI {
			MenuUI ui;
			SDL.Color _text_color;

			public HeaderUI.from_appearance(MenuHeader header, MenuUI ui) {
				this.ui = ui;
				update_appearance(header);				
			}
			
			public unowned SDL.Color text_color { get { return _text_color; } }
			public uint32 background_color_rgb { get { return ui.background_color_rgb; } }
			
			public signal void colors_updated();
			
			public void update_appearance(MenuHeader header) {
				set_area_font(header);
				set_colors(header);
			}
			public void update_font(MenuHeader header) {
				set_area_font(header);
				ui.font_updated();
			}
			public void update_colors(MenuHeader header)  {
				set_colors(header);
				colors_updated();
			}
			void set_colors(MenuHeader header) {
				_text_color = header.text_color_sdl();
			}
			
			public Surface render_text(string text) {
				return font.render_shaded(text, _text_color, ui.background_color);
			}
			public Surface render_text_to_fit(string text, int max_width) {
				var surface = render_text(text);
				if (surface.w <= max_width)
					return surface;
				
				return get_font_for_text_fit(font_size - 1, MIN_SMALL_FONT_SIZE, text.length, max_width).render_shaded(text, _text_color, ui.background_color);
			}
		}
		public class FooterUI : AppearanceAreaUI {
			MenuUI ui;
			SDL.Color _text_color;
			
			public FooterUI.from_appearance(MenuFooter footer, MenuUI ui) {
				this.ui = ui;
				update_appearance(footer);
			}
			public unowned SDL.Color text_color { get { return _text_color; } }
			public uint32 background_color_rgb { get { return ui.background_color_rgb; } }
			
			public signal void colors_updated();
			
			public void update_appearance(MenuFooter footer) {
				set_area_font(footer);
				set_colors(footer);
			}
			public void update_font(MenuFooter footer) {
				set_area_font(footer);
				ui.font_updated();
			}
			public void update_colors(MenuFooter footer)  {
				set_colors(footer);
				colors_updated();
			}
			void set_colors(MenuFooter footer) {
				_text_color = footer.text_color_sdl();
			}
			
			public Surface render_text(string text) {
				return font.render_shaded(text, _text_color, ui.background_color);
			}
			public Surface render_text_to_fit(string text, int max_width) {
				var surface = render_text(text);
				if (surface.w <= max_width)
					return surface;
				
				return get_font_for_text_fit(font_size - 1, MIN_SMALL_FONT_SIZE, text.length, max_width).render_shaded(text, _text_color, ui.background_color);
			}

		}
		public class ControlsUI : AppearanceAreaUI  {
			MenuUI ui;
			Font _font_small;
			int _font_small_size;
			int16 _font_small_height;
			int16 _char_width;
			int16 _item_spacing;
			int16 _value_control_spacing;
			SDL.Color _item_color;
			SDL.Color _selected_item_color;
			SDL.Color _selected_item_background_color;
			uint32 _selected_item_background_color_rgb;
			SDL.Color _text_cursor_color;
			uint32 _text_cursor_color_rgb;
					
			public ControlsUI.from_appearance(MenuControls controls, MenuUI ui) {
				this.ui = ui;
				update_appearance(controls);				
			}
			public int16 font_width(uint chars=1) { return (int16)(_char_width * chars); }
			public unowned Font small_font { get { return _font_small; } }
			public int small_font_size { get { return _font_small_size; } }
			public int16 small_font_height { get { return _font_small_height; } }
			public int16 item_spacing { get { return _item_spacing; } }
			public int16 value_control_spacing { get { return _value_control_spacing; } }
			public unowned SDL.Color item_color { get { return _item_color; } }
			public unowned SDL.Color selected_item_color { get { return _selected_item_color; } }
			public unowned SDL.Color selected_item_background_color { get { return _selected_item_background_color; } }
			public unowned SDL.Color text_cursor_color { get { return _text_cursor_color; } }
			public uint32 text_cursor_color_rgb { get { return _text_cursor_color_rgb; } }
			public unowned SDL.Color background_color { get { return ui.background_color;  } }
			public uint32 background_color_rgb { get { return ui.background_color_rgb; } }			
		
			public signal void colors_updated();

			public void update_appearance(MenuControls controls) {
				set_font(controls);
				set_colors(controls);
			}
			public void update_font(MenuControls controls) {
				set_font(controls);
				ui.font_updated();
			}
			public void update_colors(MenuControls controls) {
				set_colors(controls);
				colors_updated();
			}
			void set_font(MenuControls controls) {
				set_area_font(controls);
				
				_char_width = (int16)font.render_shaded(" ", ui.background_color, ui.background_color).w;
				
				var font_size_small = (int)(font_size * 0.7);
				if (font_size_small > MAX_SMALL_FONT_SIZE)
					font_size_small = MAX_SMALL_FONT_SIZE;
				_font_small = new Font(font_path, font_size_small);
				_font_small_size = font_size_small;
				_font_small_height = (int16)_font_small.height();
				
				_item_spacing = controls.item_spacing_resolved();
				_value_control_spacing = _item_spacing;
				if (item_spacing < font_height / 3)
					_value_control_spacing = font_height / 3;
			}		
			void set_colors(MenuControls controls) {
				_item_color = controls.item_color_sdl();
				_selected_item_color = controls.selected_item_color_sdl();
				_selected_item_background_color = controls.selected_item_background_color_sdl();
				_selected_item_background_color_rgb= @interface.map_rgb(_selected_item_background_color);
				_text_cursor_color = controls.text_cursor_color_sdl();
				_text_cursor_color_rgb = @interface.map_rgb(_text_cursor_color);
			}

					
			public int get_selector_visible_items(int16 max_height) {
				var min_height = (font_height + item_spacing) * 3;
				if (max_height < min_height)
					return 3;
				var visible_items = max_height / (font_height + item_spacing);
				return visible_items;
			}
			
			public Surface get_blank_background_surface(int width, int height) {
				return ui.get_blank_background_surface(width, height);
			}
			public Surface get_blank_item_surface(int width) { 
				return get_blank_background_surface(width, font_height);
			}
			public Surface get_blank_selected_item_surface(int width) { 
				return @interface.get_blank_surface(width, font_height, _selected_item_background_color_rgb);
			}
			public Surface render_text(string text, bool enabled=true) {
				if (enabled == false)
					return render_text_disabled(text);
				return font.render_shaded(text, _item_color, ui.background_color);
			}
			public Surface render_text_small(string text) {
				return _font_small.render_shaded(text, _item_color, ui.background_color);
			}

			public Surface render_text_disabled(string text, uchar alpha=128) {
				var surface = font.render_shaded(text, _item_color, ui.background_color);
				surface.set_alpha(SurfaceFlag.RLEACCEL | SurfaceFlag.SRCALPHA, alpha);
				return surface;
			}
			public Surface render_text_selected(string text) {
				return font.render_shaded(text, _selected_item_color, _selected_item_background_color);
			}
		}	
	}
}
