/* MenuSelector.vala
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
using Gee;
using Menus.Fields;

namespace Menus
{
	public class MenuSelector : Layers.Layer
	{
		Menu _menu;
		uint8 max_name_length;
		uint8 max_value_length;
		Surface surface;
		unowned Font font;
		int16 font_height;
		int _height;
		int _width;
		uint8 max_name_length_real;
		uint8 max_value_length_real;
		int16 x_pos_value;
		string field_item_format;
		string menu_item_format;
		Surface blank_name_area;
		Surface select_name_area;
		Surface blank_value_area;

		bool has_field;
		int visible_items;
		int16 item_spacing;
		int index_before_select_first;
		int index_before_select_last;
		int first_enabled_index;
		int last_enabled_index;
		int enabled_item_count;

		public MenuSelector(string id, int16 xpos, int16 ypos, Menu menu, int16 max_height, uint8 max_name_length, uint8 max_value_length) {
			base(id);
			this.xpos = xpos;
			this.ypos = ypos;
			this._menu = menu;
			this.max_name_length = max_name_length;
			this.max_value_length = max_value_length;
			font = @interface.get_monospaced_font();
			font_height = @interface.get_monospaced_font_height();
			item_spacing = @interface.get_monospaced_font_item_spacing();			
			visible_items = @interface.get_monospaced_font_selector_visible_items(max_height);
			ensure_surface();
			index_before_select_first = -1;
			index_before_select_last = -1;
			
			for(int index=0; index<menu.items.size; index++) {
				var field = menu.items[index] as MenuItemField;
				if (field != null) {
					int field_index = index;
					field.changed.connect(()=>update_item_value(field_index));
				}
			}
			
			menu.refreshed.connect((index) => refresh(index));
			
			wrap_selector = true;
		}
		public unowned string menu_title { get { return _menu.title; } }
		public Menu menu { get { return _menu; } }
		public signal void refreshed();
		
		public int16 xpos { get; set; }
		public int16 ypos { get; set; }
		public int height { get { return _height; } }
		public int width { get { return _width; } }
		public uint item_count { get { return menu.items.size; } }

		public bool wrap_selector { get; set; }
		public uint selected_index { get; private set; }
		public MenuItem selected_item() { return menu.items[(int)selected_index]; }

		public Rect? get_selected_item_value_entry_rect() {
			var field = selected_item() as MenuItemField;
			if (field == null)
				return null;
			uint top_index;
			uint bottom_index;
			get_display_range(selected_index, out top_index, out bottom_index);			
			int16 offset = get_offset(selected_index);
			if ((int)bottom_index > visible_items - 1)
				offset = offset - get_offset(top_index);
			
			Rect rect = {xpos + x_pos_value - 4, ypos + offset - 5};
			rect.w = (int16)blank_value_area.w;
			rect.h = (int16)blank_value_area.h;
			return rect;
		}

		protected override void draw() {
			ensure_surface();
			Rect dest_r = {xpos, ypos};

			uint top_index;
			uint bottom_index;
			get_display_range(selected_index, out top_index, out bottom_index);
			var items = (bottom_index - top_index) + 1;
			var height = (int16)((font_height * items) + (item_spacing * items));
			Rect source_r = {0, get_offset(top_index), (int16)_width, height};
			blit_surface(surface, source_r, dest_r);
		}

		public void hide_selection(bool flip=true) {
			update_item_name((int)selected_index, false);
			update(flip);
		}
		public void show_selection(bool flip=true) {
			update_item_name((int)selected_index, true);
			update(flip);
		}
		public void ensure_initial_selection(bool flip=true) {
			select_item(menu.initial_selection_index(), flip);
		}
		public bool select_previous(bool flip=true) {
			if (first_enabled_index == -1)
				return false;
			if (selected_index == (uint)first_enabled_index) {
				if (wrap_selector)
					return select_previous_enabled_item(last_enabled_index, flip);
				return false;
			}

			return select_previous_enabled_item(selected_index - 1, flip);
		}
		public bool select_next(bool flip=true) {
			if (last_enabled_index == -1)
				return false;
			
			if (selected_index == last_enabled_index) {
				if (wrap_selector)
					return select_item(first_enabled_index, flip);
				return false;
			}

			return select_item(selected_index + 1, flip);
		}
		public bool select_first(bool flip=true) {
			if (first_enabled_index == -1)
				return false;
			
			if (index_before_select_first != -1)
				return select_item(index_before_select_first, flip);

			int index = (int)selected_index;
			if (select_item(first_enabled_index, flip) == false)
				return false;

			index_before_select_first = index;
			return true;
		}
		public bool select_last(bool flip=true) {
			if (last_enabled_index == -1)
				return false;
				
			if (index_before_select_last != -1)
				return select_item(index_before_select_last, flip);

			int index = (int)selected_index;
			if (select_item(last_enabled_index, flip) == false)
				return false;

			index_before_select_last = index;
			return true;
		}
		public bool select_item_starting_with(string str, bool flip=true) {
			if (first_enabled_index == -1)
				return false;
			
			uint test_index = _selected_index;
			for(int counter=0;counter<enabled_item_count;counter++) {
				test_index++;
				if (test_index > last_enabled_index)
					test_index = first_enabled_index;
				if (menu.items[(int)test_index].name.strip().casefold().has_prefix(str.casefold()) == true)
					return select_item(test_index);				
			}
			return false;
		}
		public bool select_item(uint index, bool flip=true) {
			return select_next_enabled_item(index, flip);
		}
		public void update_selected_item_value() {
			update_item_value((int)selected_index);
			draw();
		}
		public void refresh(uint select_index=0) {
			surface = null;
			ensure_surface();
			select_item_no_update(select_index);
			refreshed();
		}

		protected bool select_item_no_update(uint index) {
			return select_next_enabled_item_no_update(index);
		}
		bool select_previous_enabled_item(uint index, bool flip=true) {
			if (first_enabled_index == -1)
				return false;
				
			uint resolved_index = index;
			if (resolved_index > last_enabled_index)
				resolved_index = last_enabled_index;

			while (menu.items[(int)resolved_index].enabled == false) {
				if (resolved_index == first_enabled_index)
					return false;
				resolved_index--;
			}
			select_resolved_item_no_update(resolved_index);
			update(flip);
			return true;
		}
		bool select_next_enabled_item(uint index, bool flip=true) {
			if (select_next_enabled_item_no_update(index) == false)
				return false;
			update(flip);
			return true;
		}
		bool select_next_enabled_item_no_update(uint index) {
			if (index > last_enabled_index)
				return false;
			
			uint resolved_index = index;
			while(menu.items[(int)resolved_index].enabled == false) {
				resolved_index++;
				if (resolved_index > last_enabled_index)
					return false;					
			}
			select_resolved_item_no_update(resolved_index);
			return true;			
		}		
		void select_resolved_item_no_update(uint index) {
			update_item_name((int)selected_index, false);
			update_item_name((int)index, true);
			selected_index = index;
			index_before_select_first = -1;
			index_before_select_last = -1;			
		}

		void ensure_surface() {
			if (surface != null)
				return;
			update_selector_attributes();
			surface = @interface.get_blank_surface(_width, _height);
			
			first_enabled_index = -1;
			last_enabled_index = -1;
			enabled_item_count = 0;
			Rect rect = {0, 0};
			for(int index=0; index < item_count; index++) {
				if (menu.items[index].enabled == true) {
					if (first_enabled_index == -1)
						first_enabled_index = index;
					last_enabled_index = index;
					enabled_item_count++;
				}
				render_item(index).blit(null, surface, rect);
				rect.y = (int16)(rect.y + font_height + item_spacing);
			}
		}
		
		void update_selector_attributes() {
			int surface_items = menu.items.size;
			_height = (font_height * surface_items) + (item_spacing * surface_items) + (item_spacing * 2);

			int max_name_chars = 0;
			int max_value_chars = 0;			
			foreach(var item in menu.items) {
				if (item.name.length > max_name_chars)
					max_name_chars = item.name.length;
				var field = item as MenuItemField;
				if (field != null) {
					has_field = true;
					if (max_value_chars == -1)
						continue;
					int field_value_max = field.get_minimum_menu_value_text_length();
					if (field_value_max == -1)
						max_value_chars = -1;
					else if (field_value_max > max_value_chars)
						max_value_chars = field_value_max;
				}				
			}
			if (max_value_chars > 0)
				max_value_chars++; // for line padding
			if (max_name_chars > uint8.MAX)
				max_name_chars = uint8.MAX;
			if (max_value_chars > uint8.MAX)
				max_value_chars = uint8.MAX;			
			max_name_length_real = (max_name_chars < max_name_length) ? (uint8)max_name_chars : max_name_length;
			max_value_length_real = (max_value_chars != -1 && max_value_chars < max_name_length) ? (uint8)max_value_chars : max_value_length;
			int name_area_width = @interface.get_monospaced_font_width(max_name_length_real);
			int value_area_width = @interface.get_monospaced_font_width(max_value_length_real);
			x_pos_value = @interface.get_monospaced_font_width(max_name_length_real + 3); // +3 for " : " before value
			_width = (has_field == false)
				? @interface.get_monospaced_font_width(max_name_length_real + 2) // +2 for submenu " >"
				: x_pos_value + value_area_width;

			blank_name_area = @interface.get_blank_surface(name_area_width, font_height);
			select_name_area = @interface.get_blank_surface(name_area_width, font_height);
			select_name_area.fill(null, @interface.white_color_rgb);
			blank_value_area = @interface.get_blank_surface(value_area_width, font_height);

			field_item_format = "%-" + max_name_length_real.to_string() + "s : %s";
			menu_item_format = "%-" + max_name_length_real.to_string() + "s >";
		}

		Surface render_item(int index) {
			var item = menu.items[index];
			unowned SDL.Color render_color = get_render_color(item);
			var text = item.name;
			if (item.name.strip() == "")
				text = " ";
			if (item.is_menu_item())
				return font.render_shaded(menu_item_format.printf(text), render_color, @interface.black_color);
			var field = item as MenuItemField;
			if (field != null)
				return font.render_shaded(field_item_format.printf(text, field.get_value_text()), @render_color, @interface.black_color);
			
			return font.render_shaded(text, render_color, @interface.black_color);
		}
		void update_item_name(int index, bool selected=false) {
			Rect rect = {0, get_offset(index)};
			var item = menu.items[index];
			unowned SDL.Color render_color = get_render_color(item, selected);
			if (selected == true) {
				select_name_area.blit(null, surface, rect);
				font.render_shaded(item.name, render_color, @interface.white_color).blit(null, surface, rect);
			} else {
				blank_name_area.blit(null, surface, rect);
				font.render_shaded(item.name, render_color, @interface.black_color).blit(null, surface, rect);
			}
		}
		void update_item_value(int index) {
			var field = menu.items[index] as MenuItemField;
			if (field == null)
				return;
			Rect rect = {x_pos_value, get_offset(index)};
			blank_value_area.blit(null, surface, rect);
			Surface? value_surface = field.get_value_rendering(font);
			if (value_surface == null)
				value_surface = font.render_shaded(field.get_value_text(), get_render_color(field), @interface.black_color);
			value_surface.blit(null, surface, rect);
		}
		unowned SDL.Color get_render_color(MenuItem item, bool selected=false) {
			if (item.enabled == true) {
				if (selected == false)
					return @interface.white_color;
				else
					return @interface.black_color;
			} else {
				return @interface.grey_color;
			}
		}
		int16 get_offset(uint index) {
			return (int16)((font_height * index) + (item_spacing * index));
		}
		void get_display_range(uint center_index, out uint top_index, out uint bottom_index) {
			int top = (int)center_index - (visible_items / 2);
			if (top < 0)
				top = 0;
			int bottom = top + visible_items - 1;
			if (bottom >= item_count)
				bottom = (int)item_count - 1;
			if ((bottom - top) < visible_items - 1)
				top = bottom - visible_items + 1;
			if (bottom < visible_items - 1 || top < 0)
				top = 0;			
			top_index = (uint)top;
			bottom_index = (uint)bottom;			
		}
	}
}
