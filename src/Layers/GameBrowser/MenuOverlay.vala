/* MenuOverlay.vala
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
using Menus;
using Menus.Fields;

namespace Layers.GameBrowser
{
	public class MenuOverlay : Layer, EventHandler
	{
		const int SELECTOR_MIN_WIDTH = 150;
		const int16 SELECTOR_YPOS = 100;
		const string SELECTOR_ID = "menu_overlay_selector";

		const uint8 MAX_NAME_LENGTH = 40;
		const uint8 MAX_VALUE_LENGTH = 40;
		
		MenuHeaderLayer header;
		MenuMessageLayer message;
		int16 selector_max_height;
		MenuSelector selector;
		GLib.Queue<MenuSelector> menu_stack;
		Rect upper_left;
		Rect upper_right;
		Rect lower_left;
		Rect lower_right;
		int16 header_bottom_y;
		
		ArrayList<int> cancel_keys;
		KeySymbol? cancel_key_pressed;
		
		public MenuOverlay(Menus.Menu menu, KeySymbol? cancel_key=KeySymbol.SPACE) {
			if (menu.items.size == 0)
				GLib.error("Menu '%s' has no items.", menu.name);
			base("menuoverlay_"+menu.name);
			cancel_keys = new ArrayList<int>();
			if (cancel_key != null)
				cancel_keys.add(cancel_key);
			cancel_key_pressed = null;
			menu_stack = new GLib.Queue<MenuSelector>();
			header = add_layer(new MenuHeaderLayer("header")) as MenuHeaderLayer;
			message = add_layer(new MenuMessageLayer("status")) as MenuMessageLayer;			
			message.centered = true;
			selector_max_height = (int16)(@interface.screen_height - SELECTOR_YPOS - message.height - 10);
			selector = add_layer(get_selector(menu)) as MenuSelector;
			upper_left={header.xpos - 1, header.ypos - 1};
			upper_right={header.xpos + (int16)header.width + 1, upper_left.y};
			lower_left={message.xpos - 1, message.ypos + (int16)message.height + 1};
			lower_right={message.xpos + (int16)message.width + 1, lower_left.y};
			header_bottom_y=header.ypos + (int16)header.height;
		}

		public KeySymbol? run(uchar screen_alpha=0, uint32 rgb_color=0) {
			@interface.push_layer(this, screen_alpha, rgb_color);
			
			set_header();
			selector.ensure_initial_selection(false);
			set_initial_help();
			process_events();
			
			@interface.pop_layer();
			return cancel_key_pressed;
		}
		
		public void add_cancel_key(KeySymbol key) {
			cancel_keys.add(key);
		}
		
		public Menus.Menu current_menu { get { return selector.menu; } }
		public signal void menu_changed(Menus.Menu menu);
		
		public Rect get_selector_rect() {
			return { selector.xpos, selector.ypos, (int16)selector.width };
		}
		
		protected override void draw() {
			int16 box_left_x = selector.xpos - 20;
			int16 width = (int16)@interface.screen_width - selector.xpos;
			int16 height = (int16)(@interface.screen_height - header.height - message.height);
			draw_rectangle_fill(box_left_x, 20, width, height, @interface.black_color);
			
			draw_horizontal_line(upper_left.x, upper_right.x, upper_left.y, @interface.white_color);
			draw_vertical_line(upper_left.x, upper_left.y, header_bottom_y + 1, @interface.white_color);
			draw_horizontal_line(upper_left.x, box_left_x, header_bottom_y + 1, @interface.white_color);
			draw_vertical_line(box_left_x, header_bottom_y + 1, message.ypos - 1, @interface.white_color);
			draw_vertical_line(upper_right.x, upper_right.y, lower_right.y, @interface.white_color);
			draw_horizontal_line(lower_left.x, box_left_x, message.ypos - 1, @interface.white_color);
			draw_vertical_line(lower_left.x, message.ypos - 1, lower_left.y, @interface.white_color);
			draw_horizontal_line(lower_left.x, lower_right.x, lower_left.y, @interface.white_color);
		}

		MenuSelector get_selector(Menus.Menu menu) {
			var new_selector = new MenuSelector(SELECTOR_ID, 0, 0, menu, selector_max_height, MAX_NAME_LENGTH, MAX_VALUE_LENGTH);	
			update_selector_pos(new_selector);		
			new_selector.changed.connect(() => on_selector_changed());
			new_selector.refreshed.connect(() => update_selector_pos(new_selector));
			menu.message.connect((message) => on_message(message));
			menu.error.connect((error) => on_error(error));
			menu.field_error.connect((field, index, error) => on_field_error(field, index, error));
			menu.clear_error.connect(() => clear_error());
			menu.refreshed.connect(() => refresh_menu(menu));
			return new_selector;
		}
		void update_selector_pos(MenuSelector selector) {
			selector.xpos = (int16)(@interface.screen_width - 25 - ((selector.width < SELECTOR_MIN_WIDTH) ? SELECTOR_MIN_WIDTH : selector.width));
			selector.ypos = SELECTOR_YPOS;			
		}
		
		//
		// screen updates
		void push_menu(Menus.Menu menu) {
			menu_stack.push_head(selector);
			selector = get_selector(menu);
			replace_layer(SELECTOR_ID, selector);
			clear();
			set_header();
			selector.ensure_initial_selection(false);
			set_initial_help();
			screen.update(false);
			update();
			menu_changed(menu);
		}
		void pop_menu() {
			if (menu_stack.length == 0) {
				quit_event_loop();
				return;
			}
			selector = menu_stack.pop_head();
			replace_layer(SELECTOR_ID, selector);
			clear();
			set_header();
			message.reset();
			screen.update(false);
			update();
			menu_changed(selector.menu);
		}		
		void refresh_menu(Menus.Menu menu) {
			if (menu == selector.menu) {			
				clear();
				set_header();
				message.reset();
				screen.update(false);
				update();
			}
		}
		void set_header() {
			header.set_text(null, selector.menu_title, null, false);
		}
		void set_initial_help() {
			message.reset(false);
			string? help = selector.menu.initial_help();
			if (help == null)
				help = selector.selected_item().help;
			message.help = help;			
		}
		void on_selector_changed() {
			message.help = selector.selected_item().help;
		}
		void on_message(string message) {
			this.message.message = message;
		}		
		void clear_message() {
			message.message = null;
		}
		void on_error(string error) {
			message.error = error;
		}
		void on_field_error(MenuItemField field, int index, string error) {
			if (message.error == null)
				message.error = error;
		}
		void clear_error() {
			message.error = null;
		}		
		void redraw_item() {
			selector.update_selected_item_value();
			screen.flip();
		}

		//
		// events
		void on_keydown_event (KeyboardEvent event) {
			if (process_unicode(event.keysym.unicode) == false)
				return;

			// allow menu item to process keyboard
			if (selector.selected_item().process_keydown_event(event) == true) {
				redraw_item();
				return;
			}

			if (event.keysym.mod == KeyModifier.NONE) {
				if (cancel_keys.contains(event.keysym.sym)) {
					if (selector.menu.cancel() == true) {
						quit_event_loop();
						cancel_key_pressed = event.keysym.sym;
					}
					return;
				}
				switch(event.keysym.sym) {
					case KeySymbol.UP:
						select_previous();
						break;
					case KeySymbol.DOWN:
						select_next();
						break;
					case KeySymbol.LEFT:
						select_first();
						break;
					case KeySymbol.RIGHT:
						select_last();
						break;
					case KeySymbol.PAGEUP: // pandora Y
						select_first();
						break;
					case KeySymbol.PAGEDOWN: // pandora X
						select_last();
						break;
					case KeySymbol.RETURN:
					case KeySymbol.KP_ENTER:
					case KeySymbol.END: // pandora B
						activate_selected();
						drain_events();
						break;
					case KeySymbol.HOME: // pandora A
						go_back();
						drain_events();
						break;
					case KeySymbol.ESCAPE:
						go_back();
						drain_events();
						break;
					default:
						break;
				}
				return;
			}
		}
		void on_keyup_event (KeyboardEvent event) {
			// allow menu item to process keyboard
			if (selector.selected_item().process_keyup_event(event) == true) {
				redraw_item();
				return;
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

		//
		// commands: selection
		void select_previous() {
			selector.select_previous();
			clear_message();
		}
		void select_next() {
			selector.select_next();
			clear_message();
		}
		void select_first() {
			selector.select_first();
			clear_message();
		}
		void select_last() {
			selector.select_last();
			clear_message();
		}
		void select_next_starting_with(char c) {
			clear_message();
			selector.select_item_starting_with(c.to_string());
		}

		//
		// commands: misc
		void activate_selected() {
			clear_message();
			var selected_item = selector.selected_item();
			var selected_menu = selected_item as Menus.Menu;
			if (selected_menu != null) {
				push_menu(selected_menu);
				return;
			}
			var submenu = selected_item as SubMenuItem;
			if (submenu != null) {
				push_menu(submenu.menu);
				return;
			}			
			message.error = null;
			selected_item.activate(selector);			
			switch(selected_item.action) {				
				case MenuItemActionType.CANCEL:
					if (selector.menu.cancel() == true)
						pop_menu();				
					break;
				case MenuItemActionType.SAVE:
					if (selector.menu.save() == true)
						pop_menu();					
					break;
				case MenuItemActionType.QUIT:
					if (selector.menu.cancel() == true)
						quit_event_loop();
					break;
				case MenuItemActionType.SAVE_AND_QUIT:
					if (selector.menu.save() == true)
						quit_event_loop();
					break;
				default:
					break;					
			}

		}

		void go_back() {
			if (selector.menu.cancel() == true)
				pop_menu();
		}


	}
}
