/* ListEditorBase.vala
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
using Gee;
using Menus;
using Layers.MenuBrowser;

namespace Layers.Controls.List
{
	public abstract class ListEditorBase<G> : ScreenLayer, EventHandler
	{
		const int16 SELECTOR_XPOS = 100;
		const int16 MENU_SELECTOR_XPOS = 80;
		
		Menus.MenuUI ui;
		bool move_active;
		bool menu_active;
		bool save_requested;
		MenuHeaderLayer header;
		MenuMessageLayer message;
		int16 selector_ypos;
		int16 menu_selector_ypos;
		ListItemSelector selector;
		MenuSelector menu_selector;
		Gee.List<G> _list;
		ArrayList<ListItem<G>> _items;
		
		protected ListEditorBase(string id, string title, string? help=null, Gee.List<G> list=new ArrayList<G>()) {
			base(id, @interface.game_browser_ui.background_color_rgb);
			ui = @interface.menu_ui;
			_list = list;
			header = add_layer(new MenuHeaderLayer("header")) as MenuHeaderLayer;
			header.set_text(null, title, null, false);
			message = add_layer(new MenuMessageLayer("status")) as MenuMessageLayer;	
			if (help != null)
				message.help = help;
			var menu = new Menus.Menu("");
			var cancel_text = get_cancel_item_text();
			if (cancel_text != null)
				menu.add_item(new Menus.MenuItem.cancel_item(cancel_text));
			var save_text = get_save_item_text();
			if (save_text != null)
				menu.add_item(new Menus.MenuItem.save_item(save_text));
			selector_ypos = header.ypos + (int16)header.height + ui.font_height;
			int16 menu_selector_max_height = (int16)((ui.font_height + ui.item_spacing) * menu.item_count);
			menu_selector_ypos = message.ypos - menu_selector_max_height;
			int16 menu_selector_max_width = (int16)(header.xpos + header.width - MENU_SELECTOR_XPOS - ui.font_width());
			menu_selector = add_layer(new MenuSelector("list_menu_selector", MENU_SELECTOR_XPOS, menu_selector_ypos, menu, menu_selector_max_height, menu_selector_max_width)) as MenuSelector;
			menu_selector.wrap_selector = false;
			
		}		
		
		public void set_header(string? left, string? center, string? right) {
			header.set_text(left, center, right);
		}
		
		public Gee.List<G> list { get { return _list; } }
		protected Gee.List<ListItem<G>> items { get { return _items; } }
		
		public bool run() {
			ensure_items();
			selector = add_layer(new ListItemSelector("list_item_selector", SELECTOR_XPOS, selector_ypos, menu_selector_ypos - selector_ypos, _items)) as ListItemSelector;
			@interface.push_screen_layer(this);
			selector.select_first();
			process_events();
			@interface.pop_screen_layer();
			
			if (save_requested) {
				_list.clear();
				foreach(var item in _items)
					_list.add(item.value);
				return true;
			}
			
			return false;
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
			
			draw_horizontal_line(upper_left.x, upper_right.x, upper_left.y, ui.item_color);
			draw_horizontal_line(upper_left.x, upper_right.x, header_bottom_y + 1, ui.item_color);
			draw_vertical_line(upper_left.x, upper_left.y, lower_left.y, ui.item_color);
			draw_vertical_line(upper_right.x, upper_right.y, lower_left.y, ui.item_color);
			draw_horizontal_line(lower_left.x, lower_right.x, lower_left.y, ui.item_color);			
		}
		
		protected abstract ListItem<G> get_list_item(G item);
		protected abstract bool create_item(Rect selected_item_rect, out G item);
		protected abstract bool edit_list_item(ListItem<G> item, uint index);
		protected virtual bool confirm_deletion() { return false; }
		protected virtual bool on_delete(ListItem<G> item) { return true; }
		protected virtual bool can_edit(ListItem<G> item) { return true; }
		protected virtual bool can_delete(ListItem<G> item) { return true; }
		protected virtual bool can_insert() { return true; }
		protected virtual string? get_cancel_item_text() { return MenuItemActionType.CANCEL.name(); }
		protected virtual string? get_save_item_text() { return MenuItemActionType.SAVE.name(); }
		protected bool save_on_return { get; set; }
		
		protected Rect get_selected_item_rect() {
			return selector.get_selected_item_rect();
		}
		
		void ensure_items() {
			if (_items != null)
				return;
			_items = new ArrayList<ListItem<G>>();
			foreach(var item in _list)
				_items.add(get_list_item(item));
		}
	
		//
		// events
		void on_keydown_event (KeyboardEvent event) {
			if (process_unicode(event.keysym.unicode) == false)
				return;

			if (event.keysym.mod == KeyModifier.NONE) {
				switch(event.keysym.sym) {
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
					case KeySymbol.PAGEUP: // pandora Y
						focus_list();
						drain_events();
						break;
					case KeySymbol.PAGEDOWN: // pandora X
						focus_menu();
						drain_events();
						break;
					case KeySymbol.SPACE:
					case KeySymbol.TAB:
						toggle_focus();
						drain_events();
						break;
					case KeySymbol.RETURN:
					case KeySymbol.KP_ENTER:
					case KeySymbol.END: // pandora B					
						drain_events();
						if (move_active == true) {
							selector.move_finish();
							move_active = false;
							break;
						}
						activate_selected();
						drain_events();
						break;
					case KeySymbol.HOME: // pandora A
					case KeySymbol.ESCAPE:
						if (move_active == true) {
							selector.move_cancel();
							move_active = false;
							break;
						}
						if (save_on_return == true)
							save_requested = true;
						quit_event_loop();
						break;
					default:
						break;
				}
				return;
			}
		}
		bool process_unicode(uint16 unicode) {
			if (menu_active || process_unicode_disabled)
				return true;

			if (unicode <= uint8.MAX) {
				char c = (char)unicode;
				if (c.isalnum() == true) {
					select_next_starting_with(c);
					return false;
				}
			}
			return true;
		}
		bool process_unicode_disabled;

		//
		// commands: selection
		void select_previous() {
			if (menu_active)
				menu_selector.select_previous();
			else
				selector.select_previous();
		}
		void select_previous_page() {
			if (menu_active == false)
				selector.select_previous_page();
		}
		void select_next() {
			if (menu_active)
				menu_selector.select_next();
			else
				selector.select_next();
		}
		void select_next_page() {
			if (menu_active == false)
				selector.select_next_page();
		}
		void select_next_starting_with(char c) {
			if (last_pressed_alphanumeric == c) {
				last_pressed_alphanumeric_repeat_count++;
			} else {
				last_pressed_alphanumeric = c;
				last_pressed_alphanumeric_repeat_count = 0;
			}
			if (last_pressed_alphanumeric_repeat_count > 0) {
				if (selector.select_item_starting_with(last_pressed_alphanumeric.to_string(), last_pressed_alphanumeric_repeat_count) == true)
					return;				
				last_pressed_alphanumeric_repeat_count = 0;
			}
			selector.select_item_starting_with(last_pressed_alphanumeric.to_string());
		}
		char last_pressed_alphanumeric = 0;
		int last_pressed_alphanumeric_repeat_count;

		//
		// commands: misc
		void focus_list() {
			if (menu_active == false)
				return;
			menu_active = false;
			menu_selector.hide_selection(false);
			selector.show_selection();
		}
		void focus_menu() {
			if (menu_active == true)
				return;
			menu_active = true;
			selector.hide_selection(false);
			menu_selector.show_selection();
		}
		void toggle_focus() {
			if (menu_active)
				focus_list();
			else
				focus_menu();
		}
		void activate_selected() {
			if (menu_active) {
				// menu_item selected
				MenuItemActionType action = menu_selector.selected_item().action;
				switch(action) {
					case MenuItemActionType.CANCEL:
						quit_event_loop();
						break;
					case MenuItemActionType.SAVE:
						save_requested = true;
						quit_event_loop();
						break;
					default:
						break;										
				}
				return;
			}
			// item selected
			ListItemActionType action = ListItemActionType.INSERT_BELOW;
			Rect rect = selector.get_selected_item_rect();
			if (selector.item_count > 0) {
				var selected_item = selector.selected_item();
				bool move_ok = (selector.item_count > 1);
				action = new ListItemActionSelector("item_action_selector", rect.x + (int16)rect.w, rect.y, 
					can_edit(selected_item), can_delete(selected_item), move_ok, can_insert())
					.run();				
			}
			switch(action) {
				case ListItemActionType.EDIT:
					if (edit_list_item((ListItem<G>)selector.selected_item(), selector.selected_index) == true) {
						selector.reset();
						update();						
					}
					break;
				case ListItemActionType.INSERT_ABOVE:
					G item;
					if (create_item(rect, out item) == false)
						break;
					var list_item = get_list_item(item);
					selector.insert_item_before_selected(list_item);
					update();
					if (can_edit(list_item) == true) {
						var index = selector.selected_index;										
						if (edit_list_item(list_item, index) == true) {
							selector.reset();
						} else {
							selector.remove_selected_item();
						}
						update();
					}					
					break;
				case ListItemActionType.INSERT_BELOW:
					G item;
					if (create_item(rect, out item) == false)
						break;
					var list_item = get_list_item(item);
					selector.insert_item_after_selected(list_item);
					update();
					if (can_edit(list_item) == true) {
						var index = selector.selected_index;
						if (edit_list_item(list_item, index) == true) {
							selector.reset();
							update();
						} else {
							selector.remove_selected_item();
							selector.select_item(index, false);
							update();
						}
					}
					break;
				case ListItemActionType.MOVE:
					selector.move_start();
					move_active = true;
					break;				
				case ListItemActionType.DELETE:
					// todo: confirmation "dialog"
					if (confirm_deletion() == true) {
						if (new DeleteConfirmation("delete_confirmation", rect.x + (int16)rect.w, rect.y).run() == false)
							break;
					}
					if (on_delete(selector.selected_item()) == true) {
						selector.remove_selected_item();
						update();
					}					
					break;
				default:
					break;
			}

		}
	}
}
