/* MenuBrowser.vala
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
using Layers;
using Layers.MenuBrowser;

namespace Menus
{
	public class MenuBrowser : ScreenLayer, EventHandler
	{
		const int16 SELECTOR_XPOS = 100;
		const string SELECTOR_ID = "selector";

		const uint8 MAX_NAME_LENGTH = 30;

		Menus.MenuUI.ControlsUI ui;
		MenuHeaderLayer header;
		MenuMessageLayer message;
		int16 selector_ypos;
		int16 selector_max_height;
		MenuSelector selector;
		GLib.Queue<MenuSelector> menu_stack;
		Layer? additional_layer;

		public MenuBrowser(Menu menu) {
			if (menu.item_count == 0)
				GLib.error("Menu '%s' has no items.", menu.name);
			base("menubrowser", @interface.game_browser_ui.background_color_rgb);
			ui = @interface.menu_ui.controls;
			menu_stack = new GLib.Queue<MenuSelector>();
			header = add_layer(new MenuHeaderLayer("header")) as MenuHeaderLayer;
			message = add_layer(new MenuMessageLayer("status")) as MenuMessageLayer;
			selector_ypos = header.ypos + (int16)header.height + ui.font_height;
			selector_max_height = message.ypos - selector_ypos;
			selector = add_layer(get_selector(menu)) as MenuSelector;
		}

		public void run() {
			run_no_pop();
			@interface.pop_screen_layer();
		}
		public void run_no_pop() {
			connect_selector_signals();
			@interface.push_screen_layer(this);
			
			set_header();			
			add_additional_layer(selector.menu);
			
			selector.ensure_initial_selection(false);
			set_initial_help();
			
			process_events();
			
			disconnect_selector_signals();
		}
		public void set_message(string message) {
			this.message.message = message;
		}
		public void clear_message() {
			message.message = null;
		}
		
		public signal void menu_changed(Menu menu);
		
		public Rect get_selector_rect() {
			return { SELECTOR_XPOS, selector_ypos, (int16)selector.width };
		}

		protected override void draw() {
			Rect upper_left={header.xpos - 1, header.ypos - 1};
			Rect upper_right={header.xpos + (int16)header.width + 1, upper_left.y};
			Rect lower_left={message.xpos - 1, message.ypos + (int16)message.height + 1};
			Rect lower_right={message.xpos + (int16)message.width + 1, lower_left.y};
			int16 header_bottom_y=header.ypos + (int16)header.height;
			int16 width = upper_right.x - upper_left.x;
			int16 height = lower_left.y - upper_left.y;
			draw_rectangle_fill(upper_left.x, upper_left.y, width, height, ui.background_color);
			
			draw_horizontal_line(upper_left.x, upper_right.x, upper_left.y, ui.border_color);
			draw_horizontal_line(upper_left.x, upper_right.x, header_bottom_y + 1, ui.border_color);
			draw_vertical_line(upper_left.x, upper_left.y, lower_left.y, ui.border_color);
			draw_vertical_line(upper_right.x, upper_right.y, lower_left.y, ui.border_color);
			draw_horizontal_line(lower_left.x, lower_right.x, lower_left.y, ui.border_color);			
		}

		MenuSelector get_selector(Menu menu) {
			int16 max_width = (int16)(@interface.screen_width - SELECTOR_XPOS - 20 - ui.value_control_spacing);
			return new MenuSelector(SELECTOR_ID, SELECTOR_XPOS, selector_ypos, menu, selector_max_height, max_width, MAX_NAME_LENGTH);			
		}
		void connect_selector_signals() {
			selector_handlers.add(selector.changed.connect(() => on_selector_changed()));
			menu_handlers.add(selector.menu.message.connect((message) => on_message(message)));
			menu_handlers.add(selector.menu.error.connect((error) => on_error(error)));
			menu_handlers.add(selector.menu.field_error.connect((field, index, error) => on_field_error(field, index, error)));
			menu_handlers.add(selector.menu.clear_error.connect(() => clear_error()));
			menu_handlers.add(selector.menu.refreshed.connect(() => refresh_menu(selector.menu)));			
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
		
		//
		// screen updates
		void push_menu(Menu menu) {
			if (RuntimeEnvironment.dev_mode)
				Menus.MenuItem.register_watch(menu.name);			
			disconnect_selector_signals();
			remove_additional_layer();
			menu_stack.push_head(selector);
			selector = get_selector(menu);
			connect_selector_signals();
			replace_layer(SELECTOR_ID, selector);
			clear();
			set_header();
			selector.ensure_initial_selection(false);
			set_initial_help();
			add_additional_layer(menu);
			selector.select_first();
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
			disconnect_selector_signals();
			remove_additional_layer();
			selector = menu_stack.pop_head();
			connect_selector_signals();
			replace_layer(SELECTOR_ID, selector);
			clear();
			set_header();
			message.reset();
			add_additional_layer(selector.menu);
			selector.update();
			menu_changed(selector.menu);
			if (RuntimeEnvironment.dev_mode)
				Menus.MenuItem.unregister_watch(watch);
		}
		void refresh_menu(Menu menu) {
			if (menu == selector.menu) {
				message.reset();
				update();
			}
		}
		void add_additional_layer(Menu menu) {			
			additional_layer = menu.additional_menu_browser_layer;
			if (additional_layer != null) {
				push_layer(additional_layer);
				additional_layer.update(false);
			}
		}
		void remove_additional_layer() {
			if (additional_layer != null)
				remove_layer(additional_layer.id);			
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
			set_message(message);
		}
		void on_error(string error) {
			message.error = error;
		}
		void on_field_error(Fields.MenuItemField field, int index, string error) {
			if (message.error == null)
				message.error = error;
		}
		void clear_error() {
			message.error = null;
		}
		void redraw_item() {
			selector.update_selected_item_value();
			flip();
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
				switch(event.keysym.sym) {
					case KeySymbol.UP:
						select_previous();
						break;
					case KeySymbol.DOWN:
						select_next();
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
			var selected_menu = selected_item as Menu;
			if (selected_menu != null) {
				push_menu(selected_menu);
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
