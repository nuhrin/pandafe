/* ValueSelectorBase.vala
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
using SDL;
using SDLTTF;

namespace Layers.Controls
{
	public abstract class ValueSelectorBase<G> : Layers.Layer, EventHandler
	{
		Menus.MenuUI ui;
		Surface surface;
		int16 max_text_width;
		int max_characters;
		int16 window_height;
		int _height;
		int _width;
		Surface blank_name_area;
		Surface select_name_area;
		int visible_items;
		
		ArrayList<G> items;
		uint _selected_index;
		uint original_index;
		bool canceled;
		ArrayList<int> cancel_keys;
		KeySymbol? _cancel_key_pressed;
		
		protected ValueSelectorBase(string id, int16 xpos, int16 ypos, int16 max_width, Iterable<G>? items=null, uint selected_index=0) {
			this.internal(id, xpos, ypos, max_width);			
			if (items != null)
				set_items(items);
			if (selected_index < this.items.size) {
				_selected_index = selected_index;
				original_index = selected_index;
			}
		}
		protected ValueSelectorBase.from_array(string id, int16 xpos, int16 ypos, int16 max_width, G[]? items=null, uint selected_index=0) {
			this.internal(id, xpos, ypos, max_width);
			if (items != null)
				set_items_array(items);
			if (selected_index < this.items.size) {
				_selected_index = selected_index;
				original_index = selected_index;
			}
		}
		ValueSelectorBase.internal(string id, int16 xpos, int16 ypos, int16 max_width) {
			base(id);
			ui = @interface.menu_ui;
			this.xpos = xpos;
			this.ypos = ypos;
			max_height = (int16)@interface.screen_height / 2;
			max_text_width = max_width - 8;
			max_characters = max_text_width / ui.font_width();
			items = new ArrayList<G>();
			draw_rectangle = true;
			cancel_keys = new ArrayList<int>();
			_cancel_key_pressed = null;
		}

		public int16 xpos { get; set; }
		public int16 ypos { get; set; }
		public int height { get { return _height; } }
		public int width { get { return _width; } }
		public int16 max_height { get; set; }
		public bool draw_rectangle { get; set; }
		
		public uint item_count { get { return items.size; } }
		public bool can_select_single_item { get; set; }
		public bool wrap_selector { get; set; }
		
		public uint selected_index {
			get { return _selected_index; }
			set {
				if (items.size == 0)
				GLib.error("ValueSelector '%s' has no items.", id);
				if (value > items.size)
					_selected_index = items.size -1;
				else
					_selected_index = value;
			}
		}
		public G selected_item() { 
			if (items.size == 0)
				GLib.error("ValueSelector '%s' has no items.", id);
				
			return items[(int)_selected_index]; 
		}
		public string selected_item_name() {
			if (items.size == 0)
				GLib.error("ValueSelector '%s' has no items.", id);
				
			return get_item_name((int)_selected_index);
		}
		public bool was_canceled { get { return canceled; } }
		public KeySymbol? cancel_key_pressed() { return _cancel_key_pressed; }
		public void add_cancel_key(KeySymbol cancel_key) {
			cancel_keys.add(cancel_key);
		}
		
		public void add_item(G item) {
			items.add(item);
		}
		public void set_items(Iterable<G> items) {
			this.items.clear();
			foreach(G item in items)
				add_item(item);			
		}
		public void set_items_array(G[] items) {
			this.items.clear();
			foreach(G item in items)
				add_item(item);
		}

		public uint run(uchar screen_alpha=128, uint32 rgb_color=0) {
			ensure_selection();	
			
			@interface.push_layer(this, screen_alpha, rgb_color);
			process_events();
			@interface.pop_layer();
			
			return _selected_index;	
		}
		public uint run_no_push() {
			ensure_selection();
			process_events();
			return _selected_index;
		}
		public void ensure_selection() {
			if (items.size < 2) {
				if (can_select_single_item == false)
					GLib.error("ValueSelector '%s' has too few items (%d). At least two are required for selection to make sense.", id, items.size);
				else if (items.size == 0)
					GLib.error("Value selector has no values.");
			}
			ensure_surface();
			update_item_name((int)_selected_index, true);			
		}
		public signal void selection_changed();
		
		protected abstract string get_item_name(int index);
		protected G get_item_at(int index) { return items[index]; }
		
		protected override void draw() {
			if (surface == null)
				return;
			
			uint top_index;
			uint bottom_index;
			get_display_range(selected_index, out top_index, out bottom_index);
			var items = (bottom_index - top_index) + 1;
			var height = (int16)((ui.font_height * items) + (ui.item_spacing * items) - ui.item_spacing);
			Rect source_r = {0, get_offset(top_index), (int16)_width, height};
												
			if (draw_rectangle){
				var outer_width = (int16)_width + (ui.value_control_spacing * 2);
				var outer_height = height + (ui.value_control_spacing * 2);
				// draw padding rectangle
				draw_rectangle_fill(xpos, ypos, outer_width, outer_height, ui.background_color);
				// draw selector
				blit_surface(surface, source_r, {xpos + ui.value_control_spacing, ypos + ui.value_control_spacing});
				// draw border 			
				draw_rectangle_outline(xpos, ypos, outer_width, outer_height, ui.item_color);
			} else {
				// draw selector
				blit_surface(surface, source_r, {xpos, ypos});
			}
		}
		
		void on_keydown_event(KeyboardEvent event) {
			if (process_unicode(event.keysym.unicode) == false)
				return;

			if (event.keysym.mod == KeyModifier.NONE) {
				if (cancel_keys.contains(event.keysym.sym)) {
					_selected_index = original_index;						
					canceled = true;
					_cancel_key_pressed = event.keysym.sym;
					quit_event_loop();
					return;
				}
				switch(event.keysym.sym) {
					case KeySymbol.RETURN:
					case KeySymbol.KP_ENTER:
					case KeySymbol.END:
						quit_event_loop();
						break;
					case KeySymbol.ESCAPE:
					case KeySymbol.HOME:
						_selected_index = original_index;
						canceled = true;
						quit_event_loop();
						break;
					case KeySymbol.UP:
						select_previous();
						break;
					case KeySymbol.DOWN:
						select_next();
						break;
					case KeySymbol.LEFT:
						select_previous_page();
						break;
					case KeySymbol.RIGHT:
						select_next_page();
						break;
					case KeySymbol.PAGEUP:
						select_first();
						break;
					case KeySymbol.PAGEDOWN:
						select_last();
						break;
					default:
						break;
				}
			}
		}
		bool process_unicode(uint16 unicode) {
			if (unicode <= uint8.MAX) {
				char c = (char)unicode;
				if (c.isalnum() == true) {
					select_next_starting_with(c);
					return false;
				}
			}
			return true;
		}

		void select_previous() {
			if (_selected_index == 0) {
				if (wrap_selector)		
					select_item(items.size - 1); // wrap around
				return;
			}
			select_item(_selected_index - 1);
		}
		void select_previous_page() {
			if (_selected_index < visible_items) {
				select_first();
				return;
			}
			select_item(_selected_index - visible_items);
		}
		void select_next() {
			if (selected_index == items.size - 1) {
				if (wrap_selector)
					select_item(0); // wrap around
				return;
			}
			
			select_item(_selected_index + 1);
		}
		void select_next_page() {
			if (_selected_index + visible_items >= items.size) {
				select_last();
				return;
			}
			select_item(_selected_index + visible_items);			
		}
		void select_first() { select_item(0); }
		void select_last() { select_item(items.size - 1); }		
		void select_item(uint index) {
			if (index == _selected_index || index >= items.size)
				return;
			
			update_item_name((int)_selected_index, false);
			update_item_name((int)index, true);
			_selected_index = index;
			selection_changed();
			update();
		}
		void select_next_starting_with(char c) {
			if (items.size == 0)
				return;
			uint test_index = _selected_index;
			for(int counter=1;counter<items.size;counter++) {
				test_index++;
				if (test_index >= items.size)
					test_index = 0;
				if (get_item_name((int)test_index).casefold().has_prefix(c.to_string().casefold()) == true) {
					select_item(test_index);
					return;
				}
			}			
		}
		
		void ensure_surface() {
			if (surface != null)
				return;
			update_selector_attributes();
			surface = ui.get_blank_background_surface(_width, _height);

			Rect rect = {0, 0};
			for(int index=0; index < items.size; index++) {
				render_item(index).blit(null, surface, rect);
				rect.y = (int16)(rect.y + ui.font_height + ui.item_spacing);
			}
		}
		void update_selector_attributes() {
			int16 item_height = ui.font_height + ui.item_spacing;
			int surface_items = items.size;
			_height = (item_height * surface_items);
			
			int max_name_chars = 0;
			for(int index=0; index<items.size; index++) {
				string name = get_item_name(index);
				if (name.length > max_name_chars)
					max_name_chars = name.length;
			}
			if (max_name_chars < max_characters)
				max_characters = max_name_chars;
			int name_area_width = ui.font_width(max_characters);
			_width = name_area_width;

			blank_name_area = ui.get_blank_item_surface(name_area_width);
			select_name_area = ui.get_blank_selected_item_surface(name_area_width);
			
			int screen_height = @interface.screen_height;
			visible_items = (int)max_height / (ui.font_height + ui.item_spacing);
			if (surface_items < visible_items)
				visible_items = surface_items;				
			window_height = (int16)(item_height * visible_items) + (ui.value_control_spacing * 2);

			// reposition to keep selector on screen, if necessary
			while (window_height + ypos > screen_height) {
				if (ypos < 0) {
					ypos = item_height - 1;
					visible_items--;
					window_height -= item_height;					
				} else {
					ypos -= item_height;
				}
			}
		}

		Surface render_item(int index) {
			return ui.render_text(get_display_name(index));
		}
		void update_item_name(int index, bool selected=false) {
			Rect rect = {0, get_offset(index)};
			if (selected == true) {
				select_name_area.blit(null, surface, rect);
				ui.render_text_selected(get_display_name(index)).blit(null, surface, rect);
			} else {
				blank_name_area.blit(null, surface, rect);
				ui.render_text(get_display_name(index)).blit(null, surface, rect);
			}
		}
		string get_display_name(int index) {
			string name = get_item_name(index);
			if (name.length > max_characters)
				return name.substring(0, max_characters);
			return name;
		}
		int16 get_offset(uint index) {
			return (int16)((ui.font_height * index) + (ui.item_spacing * index));
		}
		void get_display_range(uint center_index, out uint top_index, out uint bottom_index) {
			int top = (int)center_index - (visible_items / 2);
			if (top < 0)
				top = 0;
			int bottom = top + visible_items - 1;
			if (bottom >= items.size)
				bottom = items.size - 1;
			if ((bottom - top) < visible_items - 1)
				top = bottom - visible_items + 1;
			if (bottom < visible_items - 1 || top < 0)
				top = 0;			
			top_index = (uint)top;
			bottom_index = (uint)bottom;	
		}

	}
}
