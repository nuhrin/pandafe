using SDL;
using SDLTTF;
using Layers.MenuBrowser;
using Menus;
using Menus.Fields;

namespace Layers.GameBrowser
{
	public class MenuOverlay : Layer
	{
		const int SELECTOR_MIN_WIDTH = 150;
		const int16 SELECTOR_YPOS = 100;
		const string SELECTOR_ID = "overlay_selector";

		uint8 max_name_length;
		uint8 max_value_length;

		bool event_loop_done;
		GLib.Queue<MenuSelector> menu_stack;
		MenuSelector selector;
		MenuHeaderLayer header;
		MenuMessageLayer message;
		Rect upper_left;
		Rect upper_right;
		Rect lower_left;
		Rect lower_right;
		int16 header_bottom_y;
		
		public MenuOverlay(Menu menu, uint8 max_name_length, uint8 max_value_length) {
			if (menu.items.size == 0)
				GLib.error("Menu '%s' has no items.", menu.name);
			base("menubrowser");
			this.max_name_length = max_name_length;
			this.max_value_length = max_value_length;
			menu_stack = new GLib.Queue<MenuSelector>();
			header = add_layer(new MenuHeaderLayer("header")) as MenuHeaderLayer;
			message = add_layer(new MenuMessageLayer("status")) as MenuMessageLayer;			
			message.centered = true;
			selector = add_layer(get_selector(menu)) as MenuSelector;
			upper_left={header.xpos - 1, header.ypos - 1};
			upper_right={header.xpos + (int16)header.width + 1, upper_left.y};
			lower_left={message.xpos - 1, message.ypos + (int16)message.height + 1};
			lower_right={message.xpos + (int16)message.width + 1, lower_left.y};
			header_bottom_y=header.ypos + (int16)header.height;
		}

		public void run() {
			@interface.push_layer(this);//, 150);
			set_header();			
			selector.select_first();
			while(event_loop_done == false) {
				process_events();
				@interface.execute_idle_loop_work();
			}
			@interface.pop_layer();
		}
		
		public signal void menu_changed(Menu menu);
		
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

		MenuSelector get_selector(Menu menu) {
			var new_selector = new MenuSelector(SELECTOR_ID, 0, 0, menu, max_name_length, max_value_length);	
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
		void push_menu(Menu menu) {
			menu_stack.push_head(selector);
			selector = get_selector(menu);
			replace_layer(SELECTOR_ID, selector);
			clear();
			set_header();
			message.reset();
			selector.select_first();
			screen.update(false);
			update();
			menu_changed(menu);
		}
		void pop_menu() {
			if (menu_stack.length == 0) {
				event_loop_done = true;
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
		void refresh_menu(Menu menu) {
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
		void on_selector_changed() {
			message.help = selector.selected_item().help;
		}
		void on_message(string message) {
			this.message.message = message;
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
		void process_events() {
			Event event;
			while(Event.poll(out event) == 1) {
				switch(event.type) {
					case EventType.QUIT:
						this.event_loop_done = true;
						break;
					case EventType.KEYDOWN:
						this.on_keydown_event(event.key);
						break;
					case EventType.KEYUP:
						this.on_keyup_event(event.key);
						break;
				}
			}
		}
		void drain_events() {
			Event event;
			while(Event.poll(out event) == 1);
		}
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
					case KeySymbol.SPACE:
						if (selector.menu.cancel() == true)
							event_loop_done = true;
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
			if (process_unicode_disabled)
				return true;

			if (unicode <= uint8.MAX) {
				char c = (char)unicode;
				if (c.isalnum() == true) {
					//debug("'%c' pressed", c);
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
			selector.select_previous();
		}
		void select_next() {
			selector.select_next();
		}
		void select_first() {
			selector.select_first();
		}
		void select_last() {
			selector.select_last();
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
		void activate_selected() {
			var selected_item = selector.selected_item();
			var selected_menu = selected_item as Menu;
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
						event_loop_done = true;
					break;
				case MenuItemActionType.SAVE_AND_QUIT:
					if (selector.menu.save() == true)
						event_loop_done = true;					
					break;
				default:
					selected_item.activate(selector);
					break;					
			}

		}

		void go_back() {
			if (selector.menu.cancel() == true)
				pop_menu();
		}


	}
}
