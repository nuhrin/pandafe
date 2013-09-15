/* SelectorOverlay.vala
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
using Layers.MenuBrowser;
using Layers.Controls;

namespace Layers.GameBrowser
{
	public class SelectorOverlay<G> : Layer
	{
		Menus.MenuUI.ControlsUI ui;
		const int SELECTOR_MIN_WIDTH = 150;
		const int16 SELECTOR_YPOS = 95;
		const string SELECTOR_ID = "selector_overlay_selector";
		const uint8 MAX_NAME_LENGTH = 40;
		
		protected MenuHeaderLayer header;
		protected MenuMessageLayer message;
		ValueSelector<G> selector;
		Rect upper_left;
		Rect upper_right;
		Rect lower_left;
		Rect lower_right;
		int16 header_bottom_y;
		string? original_help;
		
		public SelectorOverlay(string title, string? help, owned MapFunc<string, G> getItemName, Iterable<G>? items=null, uint selected_index=0) {
			base("selector_overlay");
			ui = @interface.menu_ui.controls;
			header = add_layer(new MenuHeaderLayer("header")) as MenuHeaderLayer;
			header.set_text(null, title, null, false);
			message = add_layer(new MenuMessageLayer("status")) as MenuMessageLayer;			
			message.centered = true;
			message.help = help;
			original_help = help;
			upper_left={header.xpos - 1, header.ypos - 1};
			upper_right={header.xpos + (int16)header.width + 1, upper_left.y};
			lower_left={message.xpos - 1, message.ypos + (int16)message.height + 1};
			lower_right={message.xpos + (int16)message.width + 1, lower_left.y};
			header_bottom_y=header.ypos + (int16)header.height;
			selector = add_layer(get_selector((owned)getItemName, items, selected_index)) as ValueSelector<G>;			
		}

		public uint item_count { get { return selector.item_count; } }
		public bool can_select_single_item { 
			get { return selector.can_select_single_item; }
			set { selector.can_select_single_item = value; }
		}	
		public uint selected_index {
			get { return selector.selected_index; }
			set { selector.selected_index = value; }
		}
		public G selected_item() { return selector.selected_item(); }
		public string selected_item_name() { return selector.selected_item_name(); }
		public bool was_canceled { get { return selector.was_canceled; } }
		public KeySymbol? cancel_key_pressed() { return selector.cancel_key_pressed(); }
		public void add_cancel_key(KeySymbol cancel_key) { selector.add_cancel_key(cancel_key); }
		
		public void add_item(G item) {
			selector.add_item(item);
		}
		public void set_items(Iterable<G> items) {
			selector.set_items(items);
		}
		public void set_items_array(G[] items) {
			selector.set_items_array(items);
		}


		public uint run() {			
			selector.ensure_selection();
			
			@interface.push_layer(this);
			
			var selected_index = selector.run_no_push();
			
			@interface.pop_layer(false);
			
			return selected_index;
		}
		
		protected virtual string? get_selection_help(G selected_item) {
			return null;
		}
				
		protected override void draw() {
			int16 box_left_x = selector.xpos - 20;
			int16 width = (int16)@interface.screen_width - selector.xpos;
			int16 height = (int16)(@interface.screen_height - header.height - message.height);
			draw_rectangle_fill(box_left_x, 20, width, height, ui.background_color);
			
			draw_horizontal_line(upper_left.x, upper_right.x, upper_left.y, ui.border_color);
			draw_vertical_line(upper_left.x, upper_left.y, header_bottom_y + 1, ui.border_color);
			draw_horizontal_line(upper_left.x, box_left_x, header_bottom_y + 1, ui.border_color);
			draw_vertical_line(box_left_x, header_bottom_y + 1, message.ypos - 1, ui.border_color);
			draw_vertical_line(upper_right.x, upper_right.y, lower_right.y, ui.border_color);
			draw_horizontal_line(lower_left.x, box_left_x, message.ypos - 1, ui.border_color);
			draw_vertical_line(lower_left.x, message.ypos - 1, lower_left.y, ui.border_color);
			draw_horizontal_line(lower_left.x, lower_right.x, lower_left.y, ui.border_color);
		}
		
		ValueSelector<G> get_selector(owned MapFunc<string, G> getItemName, Iterable<G>? items=null, uint selected_index) {
			int16 max_width = ui.font_width(MAX_NAME_LENGTH) + 8;
			var selector = new ValueSelector<G>(SELECTOR_ID, 0, 0, max_width, (owned)getItemName, items, selected_index);
			selector.draw_rectangle = false;
			selector.xpos = (int16)(@interface.screen_width - 75 - ((selector.width < SELECTOR_MIN_WIDTH) ? SELECTOR_MIN_WIDTH : selector.width));
			selector.ypos = SELECTOR_YPOS;
			selector.max_height = message.ypos - 20 - SELECTOR_YPOS;
			selector.wrap_selector = true;
			selector.selection_changed.connect(change_help_text_on_selection_change);
			return selector;
		}
		
		void change_help_text_on_selection_change() {
			string? new_help = get_selection_help(selector.selected_item());
			if (new_help == null && message.help == original_help)
				return; // don't blank the original help if it hasn't been changed
			message.update_help(new_help, false);
		}

	}
}
