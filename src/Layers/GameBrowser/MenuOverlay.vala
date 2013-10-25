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
		const string SELECTOR_ID = "menu_overlay_selector";
		const int16 HEADER_FOOTER_REVEAL_OFFSET = 100;
		const uint8 MAX_NAME_LENGTH = 30;

		Menus.MenuUI.ControlsUI ui;
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
		bool is_initialized;
		bool needs_header_footer_reveal;
		
		ArrayList<int> cancel_keys;
		KeySymbol? cancel_key_pressed;
		
		public MenuOverlay(Menus.Menu menu, KeySymbol? cancel_key=KeySymbol.SPACE) {
			if (menu.item_count == 0)
				GLib.error("Menu '%s' has no items.", menu.name);
			base("menuoverlay_"+menu.name);
			ui = @interface.menu_ui.controls;
			cancel_keys = new ArrayList<int>();
			if (cancel_key != null)
				cancel_keys.add(cancel_key);
			cancel_key_pressed = null;
			menu_stack = new GLib.Queue<MenuSelector>();
			header = add_layer(new MenuHeaderLayer("menu-header")) as MenuHeaderLayer;
			message = add_layer(new MenuMessageLayer("menu-status")) as MenuMessageLayer;			
			message.centered = true;
			update_positions();
			selector = add_layer(get_selector(menu)) as MenuSelector;			
			@interface.menu_ui.font_updated.connect(update_font);
			@interface.menu_ui.colors_updated.connect(update_colors);
			@interface.menu_ui.appearance_updated.connect(update_font);
		}

		public KeySymbol? run(uchar screen_alpha=0, uint32 rgb_color=0) {
			connect_selector_signals();
						
			set_header();
			selector.ensure_initial_selection(false);
			set_initial_help();
			is_initialized = true;
			
			@interface.push_layer(this, screen_alpha, rgb_color);			
			
			process_events();
			
			@interface.pop_layer(false);
			disconnect_selector_signals();
			while (menu_stack.length > 0) {
				selector = menu_stack.pop_head();
				selector.menu.cancel(true);
			}
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
			int16 box_left_x = selector.xpos - ui.value_control_spacing;
			int16 width = (int16)@interface.screen_width - box_left_x - 20;
			int16 height = (int16)(message.ypos - header.ypos - header.height);
			draw_rectangle_fill(box_left_x, (int16)(header.ypos + header.height), width, height, ui.background_color);
			
			draw_horizontal_line(upper_left.x, upper_right.x, upper_left.y, ui.border_color);
			draw_vertical_line(upper_left.x, upper_left.y, header_bottom_y, ui.border_color);
			draw_horizontal_line(upper_left.x, box_left_x, header_bottom_y, ui.border_color);
			draw_vertical_line(box_left_x, header_bottom_y, message.ypos - 1, ui.border_color);
			draw_vertical_line(upper_right.x, upper_right.y, lower_right.y, ui.border_color);
			draw_horizontal_line(lower_left.x, box_left_x, message.ypos - 1, ui.border_color);
			draw_vertical_line(lower_left.x, message.ypos - 1, lower_left.y, ui.border_color);
			draw_horizontal_line(lower_left.x, lower_right.x, lower_left.y, ui.border_color);
		}

		MenuSelector get_selector(Menus.Menu menu) {
			var new_selector = new MenuSelector(SELECTOR_ID, 0, 0, menu, selector_max_height, (int16)(@interface.screen_width / 2), MAX_NAME_LENGTH);	
			update_selector_pos(new_selector);					
			return new_selector;
		}
		void connect_selector_signals() {
			selector_handlers.add(selector.changed.connect(() => on_selector_changed()));
			selector_handlers.add(selector.refreshed.connect(() => update_selector_pos(selector)));
			menu_handlers.add(selector.menu.message.connect((message) => on_message(message)));
			menu_handlers.add(selector.menu.error.connect((error) => on_error(error)));
			menu_handlers.add(selector.menu.field_error.connect((field, index, error) => on_field_error(field, index, error)));
			menu_handlers.add(selector.menu.clear_error.connect(() => clear_error()));
			menu_handlers.add(selector.menu.refreshed.connect(() => refresh_menu(selector.menu)));
			menu_handlers.add(selector.menu.quit.connect(() => quit_event_loop()));
		}
		void disconnect_selector_signals() {
			foreach(var handler in menu_handlers)
				selector.menu.disconnect(handler);
			menu_handlers.clear();
				
			foreach(var handler in selector_handlers)
				selector.disconnect(handler);
			selector_handlers.clear();			
		}
		Gee.ArrayList<ulong> selector_handlers = new Gee.ArrayList<ulong>();
		Gee.ArrayList<ulong> menu_handlers = new Gee.ArrayList<ulong>();
	
		void update_selector_pos(MenuSelector selector) {
			selector.xpos = (int16)(@interface.screen_width - 20 - ui.value_control_spacing - ((selector.width < SELECTOR_MIN_WIDTH) ? SELECTOR_MIN_WIDTH : selector.width));
			selector.ypos = (int16)(header.ypos + header.height + ui.font_height);
		}
		void update_colors() {
			header.set_rgb_color(@interface.menu_ui.background_color_rgb);
			message.set_rgb_color(@interface.menu_ui.background_color_rgb);
			update(false);
		}
		void update_font() {
			clear();
			recreate_header();
			recreate_message();
			needs_header_footer_reveal = false;
			do_header_footer_reveal();
			update_positions();
			recreate_selectors();
			update(false);
			screen_update(false);
		}
		void recreate_header() {
			var left = header.left;
			var center = header.center;
			var right = header.right;			
			header = new MenuHeaderLayer("menu-header");
			header.set_text(left, center, right, false);
			replace_layer(header.id, header);
		}
		void recreate_message() {
			var centered = message.centered;
			var error = message.error;
			var msg = message.message;
			var help = message.help;
			message = new MenuMessageLayer("menu-status");
			message.centered = centered;
			message.set_text(error, msg, help);
			replace_layer(message.id, message);
		}
		void do_header_footer_reveal() {
			var do_reveal = (selector.menu.get_metadata("header_footer_reveal") == "true");
			if (do_reveal) {
				if (needs_header_footer_reveal == false) {
					header.resize(header.width - (int)HEADER_FOOTER_REVEAL_OFFSET, -1, header.xpos + HEADER_FOOTER_REVEAL_OFFSET, -1);
					message.resize(message.width - (int)HEADER_FOOTER_REVEAL_OFFSET, -1, message.xpos + HEADER_FOOTER_REVEAL_OFFSET, -1);
					upper_left.x += HEADER_FOOTER_REVEAL_OFFSET;
					lower_left.x += HEADER_FOOTER_REVEAL_OFFSET;
					needs_header_footer_reveal = true;
				}
			} else {
				if (needs_header_footer_reveal == true) {
					header.resize(header.width + (int)HEADER_FOOTER_REVEAL_OFFSET, -1, header.xpos - HEADER_FOOTER_REVEAL_OFFSET, -1);
					message.resize(message.width + (int)HEADER_FOOTER_REVEAL_OFFSET, -1, message.xpos - HEADER_FOOTER_REVEAL_OFFSET, -1);					
					upper_left.x -= HEADER_FOOTER_REVEAL_OFFSET;
					lower_left.x -= HEADER_FOOTER_REVEAL_OFFSET;
					needs_header_footer_reveal = false;
				}
			}
		}
		void update_positions() {
			var selector_ypos = (int16)(header.ypos + header.height + ui.font_height); //SELECTOR_YPOS;	
			selector_max_height = (int16)(@interface.screen_height - selector_ypos - message.height - 10);
			upper_left={header.xpos - 1, header.ypos - 1};
			upper_right={header.xpos + (int16)header.width, upper_left.y};
			lower_left={message.xpos - 1, message.ypos + (int16)message.height};
			lower_right={message.xpos + (int16)message.width, lower_left.y};
			header_bottom_y=header.ypos + (int16)header.height;
		}
		void recreate_selectors() {
			for(uint index=0;index<menu_stack.length;index++) {
				var item = menu_stack.peek_nth(index);
				item.recreate(selector_max_height);
				update_selector_pos(item);
			}
			selector.recreate(selector_max_height);
			update_selector_pos(selector);
		}
		
		//
		// screen updates
		public void screen_update(bool flip=true) {
			var s = this.screen;
			if (s != null)
				s.update(flip);
		}
		void push_menu(Menus.Menu menu) {
			if (RuntimeEnvironment.dev_mode)
				Menus.MenuItem.register_watch(menu.name);
			is_initialized = false;
			disconnect_selector_signals();
			menu_stack.push_head(selector);
			selector = get_selector(menu);
			connect_selector_signals();
			replace_layer(SELECTOR_ID, selector);
			clear();
			set_header();
			selector.ensure_initial_selection(false);
			set_initial_help(false);
			screen_update(false);
			update();
			is_initialized = true;
			menu_changed(menu);
			if (RuntimeEnvironment.dev_mode)
				Menus.MenuItem.update_watch(menu.name);
		}
		void pop_menu() {
			if (menu_stack.length == 0) {
				quit_event_loop();
				return;
			}
			string watch = selector.menu.name;
			is_initialized = false;
			disconnect_selector_signals();
			selector = menu_stack.pop_head();			
			connect_selector_signals();
			replace_layer(SELECTOR_ID, selector);
			clear();
			set_header();
			message.reset(false);
			message.update_help(selector.selected_item().help, false);
			screen_update(false);
			update();
			is_initialized = true;
			menu_changed(selector.menu);
			if (RuntimeEnvironment.dev_mode)
				Menus.MenuItem.unregister_watch(watch);
		}		
		void refresh_menu(Menus.Menu menu) {
			if (menu == selector.menu) {			
				clear();
				set_header();
				message.reset();
				screen_update(false);
				update();
			}
		}
		void set_header() {
			do_header_footer_reveal();
			header.set_text(null, selector.menu_title, null, false);
		}
		void set_initial_help(bool flip_screen=true) {
			message.reset(false);
			string? help = selector.menu.initial_help();
			if (help == null)
				help = selector.selected_item().help;
			message.update_help(help, flip_screen);
		}
		void on_selector_changed() {
			if (is_initialized == false)
				return;
			message.update_help(selector.selected_item().help, false);
		}
		void on_message(string message) {
			this.message.message = message;
		}		
		void clear_message(bool flip=true) {
			message.update_message(null, flip);
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
			if (selector.selected_item().handles_keydown_event(event) == true) {
				if (selector.selected_item().process_keydown_event(event) == true)
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
			clear_message(false);
			selector.select_previous();
		}
		void select_next() {
			clear_message(false);
			selector.select_next();
		}
		void select_first() {
			clear_message(false);
			selector.select_first();
		}
		void select_last() {
			clear_message(false);
			selector.select_last();
		}
		void select_next_starting_with(char c) {
			clear_message(false);
			selector.select_item_starting_with(c.to_string());
		}

		//
		// commands: misc
		void activate_selected() {
			clear_message(false);
			var selected_item = selector.selected_item();
			var selected_menu = selected_item as Menus.Menu;
			if (selected_menu != null) {
				push_menu(selected_menu);
				return;
			}
			var submenu = selected_item as SubMenuItem;
			if (submenu != null) {
				if (submenu.on_activation(selector) == true)
					push_menu(submenu.menu);
				return;
			}			
			message.update_error(null, false);
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
