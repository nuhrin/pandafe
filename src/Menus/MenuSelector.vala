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
		MenuUI.ControlsUI ui;
		Menu _menu;
		Surface surface;
		int _height;
		int _width;
		int16 max_height;
		int16 max_width;
		uint8 max_name_length;
		uint8 max_value_length;
		int16 value_x_pos;
		string field_item_format;
		string menu_item_format;
		Surface blank_name_area;
		Surface select_name_area;
		Surface blank_value_area;

		int visible_items;
		int index_before_select_first;
		int index_before_select_last;
		int first_enabled_index;
		int last_enabled_index;
		int enabled_item_count;

		public MenuSelector(string id, int16 xpos, int16 ypos, Menu menu, int16 max_height, int16 max_width, uint8 max_name_length=0) {
			base(id);			
			this.xpos = xpos;
			this.ypos = ypos;
			this._menu = menu;
			this.max_height = max_height;
			this.max_width = max_width;
			this.max_name_length = max_name_length;

			ui = @interface.menu_ui.controls;
			ui.colors_updated.connect(update_colors);
			@interface.menu_ui.colors_updated.connect(update_colors);
			ensure_surface();
			
			index_before_select_first = -1;
			index_before_select_last = -1;
			
			for(uint index=0; index<menu.item_count; index++) {
				var field = menu.field_at(index);
				if (field != null) {
					uint field_index = index;
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
		public uint item_count { get { return menu.item_count; } }

		public bool wrap_selector { get; set; }
		public uint selected_index { get; private set; }
		public MenuItem selected_item() { return menu.item_at(selected_index); }

		public Rect get_selected_item_rect() {
			uint top_index;
			uint bottom_index;
			get_display_range(selected_index, out top_index, out bottom_index);
			int16 offset = get_offset(selected_index);
			if ((int)bottom_index > visible_items - 1)
				offset = offset - get_offset(top_index);

			Rect rect = {xpos - ui.item_spacing, ypos + offset - @ui.item_spacing};
			rect.w = (int16)blank_name_area.w;
			rect.h = (int16)blank_name_area.h;
			return rect;
		}
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
			
			Rect rect = {xpos + value_x_pos - ui.value_control_spacing, ypos + offset - ui.value_control_spacing};
			rect.w = (int16)blank_value_area.w + ui.value_control_spacing;
			rect.h = (int16)blank_value_area.h + ui.value_control_spacing;
			return rect;
		}

		public void recreate(int16 max_height) {
			this.max_height = max_height;
			surface = null;
			ensure_surface();
			show_selection(false);
		}
		void update_colors() {
			var pushed_layer = @interface.peek_layer();
			if (pushed_layer == null || pushed_layer.id.has_prefix("menuoverlay_") == false)
				return; // another control has focus, don't bother updating
						
			surface = null;
			ensure_surface();
			show_selection(false);
		}

		protected override void draw() {
			ensure_surface();
			Rect dest_r = {xpos, ypos};

			uint top_index;
			uint bottom_index;
			get_display_range(selected_index, out top_index, out bottom_index);
			var items = (bottom_index - top_index) + 1;
			var height = (int16)((ui.font_height * items) + (ui.item_spacing * items));
			Rect source_r = {0, get_offset(top_index), (int16)_width, height};
			blit_surface(surface, source_r, dest_r);
			
			int16 rect_height = (int16)_height;
			if (rect_height > max_height)
				rect_height = max_height;			
			draw_rectangle_outline(xpos, ypos, (int16)_width, (int16)rect_height, ui.border_color);
		}

		public void hide_selection(bool flip=true) {
			update_item_name(selected_index, false);
			update(flip);
		}
		public void show_selection(bool flip=true) {
			update_item_name(selected_index, true);
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
				if (menu.item_at(test_index).name.strip().casefold().has_prefix(str.casefold()) == true)
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

			while (menu.item_enabled(resolved_index) == false) {
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
			while(menu.item_enabled(resolved_index) == false) {
				resolved_index++;
				if (resolved_index > last_enabled_index)
					return false;					
			}
			select_resolved_item_no_update(resolved_index);
			return true;			
		}		
		void select_resolved_item_no_update(uint index) {
			update_item_name(selected_index, false);
			update_item_name(index, true);
			selected_index = index;
			index_before_select_first = -1;
			index_before_select_last = -1;			
		}

		void ensure_surface() {
			if (surface != null)
				return;
			if (selected_index >= menu.item_count)
				selected_index = menu.item_count - 1;
			update_selector_attributes();
			surface = ui.get_blank_background_surface(_width, _height);
			
			first_enabled_index = -1;
			last_enabled_index = -1;
			enabled_item_count = 0;
			Rect rect = {ui.font_width(), 0};
			for(uint index=0; index < item_count; index++) {
				if (menu.item_enabled(index) == true) {
					if (first_enabled_index == -1)
						first_enabled_index = (int)index;
					last_enabled_index = (int)index;
					enabled_item_count++;
				}
				
				render_item(index).blit(null, surface, rect);
				rect.y = (int16)(rect.y + ui.font_height + ui.item_spacing);
			}
		}
		
		void update_selector_attributes() {
			int surface_items = (int)menu.item_count;
			visible_items = ui.get_selector_visible_items(max_height);
			_height = (ui.font_height * surface_items) + (ui.item_spacing * surface_items) + (ui.item_spacing * 2);
			
			int max_name_chars = 0;
			int max_value_chars = 0;		
			bool has_field = false;
			bool has_menu_item = false;
			bool has_unlimited_value_field = false;
			foreach(var item in menu.items()) {
				if (item.name.length > max_name_chars)
					max_name_chars = item.name.length;
				if (item.is_menu_item()) {
					has_menu_item = true;
					continue;
				}
				var field = item as MenuItemField;
				if (field != null) {
					has_field = true;
					int field_value_max = field.get_minimum_menu_value_text_length();
					if (field_value_max == -1)
						has_unlimited_value_field = true;
					else if (field_value_max > max_value_chars)
						max_value_chars = field_value_max;
				}				
			}
			if (max_name_chars > uint8.MAX)
				max_name_chars = uint8.MAX;
			if (max_value_chars > uint8.MAX)
				max_value_chars = uint8.MAX;
			
			if (max_name_length == 0 || max_name_chars < max_name_length)
				max_name_length = (uint8)max_name_chars;
			max_value_length = 0;
			
			uint8 max_total_length = (uint8)(max_width / ui.font_width());
			
			uint8 item_padding_length = 2; // spacing around name;
			if (has_menu_item)
				item_padding_length = 3; // for spacing plus ">" suffix
			if (has_field)
				item_padding_length = 4; // for spacing plus ": "
			if (max_name_length + item_padding_length > max_total_length)
				max_name_length = max_total_length - item_padding_length;
			if (max_name_length < 0)
				max_name_length = 3; // ensure room for at least 3 chars of name
					
			
			if (has_field == false)  {
				value_x_pos = -1;
				blank_value_area = null;			
				_width = ui.font_width(max_name_length + item_padding_length);
			} else {
				if (max_total_length < 10) {
					// ensure room for " xxx : xxx" at minimum
					max_width = ui.font_width(10);
					max_name_length = 3;
					max_total_length = 10;
				}
				value_x_pos = ui.font_width(max_name_length + item_padding_length);
				max_value_length = (uint8)((max_width - value_x_pos) / ui.font_width());
				if ((has_unlimited_value_field == true && max_value_chars > max_value_length) ||
				    (has_unlimited_value_field == false && max_value_chars < max_value_length))
					max_value_length = (uint8)max_value_chars;
				if (max_value_length < 3 && max_value_length != max_value_chars) {
					// ensure at least 3 chars of value (unless less are requested)
					max_name_length = max_name_length - (3 - max_value_length);
					value_x_pos = ui.font_width(max_name_length + item_padding_length);
					max_value_length = 3; 
				}
				while(max_name_length + item_padding_length + max_value_length > max_total_length) {
					if (max_value_length > max_name_length && max_value_length > 3) {
						max_value_length--;						
					} else {
						max_name_length--;
						value_x_pos = ui.font_width(max_name_length + item_padding_length);
					}
				}
				int value_area_width = ui.font_width(max_value_length + 1); // +1 for padding
				blank_value_area = ui.get_blank_item_surface(value_area_width);
				_width = value_x_pos + value_area_width;
			}
			
			int name_area_width = ui.font_width(max_name_length + 2); // +2 for padding			
			blank_name_area = ui.get_blank_item_surface(name_area_width);
			select_name_area = ui.get_blank_selected_item_surface(name_area_width);
			field_item_format = "%-" + max_name_length.to_string() + "s : %s";
			menu_item_format = "%-" + max_name_length.to_string() + "s >";
		}

		Surface render_item(uint index) {
			var item = menu.item_at(index);
			
			var text = item.name;
			if (item.name.strip() == "")
				text = " ";
			if (text.length > max_name_length)
				text = text.substring(0, max_name_length);
			if (item.is_menu_item())
				text = menu_item_format.printf(text);
			else {
				var field = item as MenuItemField;
				if (field != null && (field is MenuItemFieldSeparator) == false) {
					var val = field.get_value_text();
					if (val.length > max_value_length)
						val = val.substring(0, max_value_length);
					text = field_item_format.printf(text, val);
				}
			}
			
			return ui.render_text(text, item.enabled);
		}
		void update_item_name(uint index, bool selected=false) {
			Rect rect = {0, get_offset(index)};
			var item = menu.item_at(index);
			var name = item.name;
			if (name.length > max_name_length)
				name = name.substring(0, max_name_length);
			if (selected == true) {
				select_name_area.blit(null, surface, rect);
				rect.x += ui.font_width();
				ui.render_text_selected(name).blit(null, surface, rect);
			} else {
				blank_name_area.blit(null, surface, rect);
				rect.x += ui.font_width();
				ui.render_text(name, item.enabled).blit(null, surface, rect);
			}
		}
		void update_item_value(uint index) {
			var field = menu.field_at(index);
			if (field == null)
				return;
			var val = field.get_value_text();
			if (val.length > max_value_length)
				val = val.substring(0, max_value_length);
			Rect rect = {value_x_pos, get_offset(index)};
			blank_value_area.blit(null, surface, rect);
			ui.render_text(val, field.enabled).blit(null, surface, rect);
		}
		int16 get_offset(uint index) {
			return (int16)((ui.font_height * index) + (ui.item_spacing * index));
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
