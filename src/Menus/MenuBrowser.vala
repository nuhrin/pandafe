using SDL;
using SDLTTF;

namespace Menus
{
	public class MenuBrowser
	{
		int16 pos_y_status_message;
		Surface blank_header_area;
		Surface blank_message_area;
		unowned Font font;
		int16 font_height;

		bool event_loop_done;
		GLib.Queue<MenuSelector> menu_stack;
		MenuSelector selector;
		uint8 max_name_length;
		uint8 max_value_length;

		public MenuBrowser(Menu menu, uint8 max_name_length, uint8 max_value_length) {
			if (menu.items.size == 0)
				GLib.error("Menu '%s' has no items.", menu.name);
			font = @interface.get_monospaced_font();
			font_height = @interface.get_monospaced_font_height();
			pos_y_status_message = 470 - (font_height * 2);
			blank_header_area = @interface.get_blank_surface(760, font_height);
			blank_message_area = @interface.get_blank_surface(780, font_height * 2);
			menu_stack = new GLib.Queue<MenuSelector>();
			selector = new MenuSelector(menu, max_name_length, max_value_length);
			selector.select_first();
			this.max_name_length = max_name_length;
			this.max_value_length = max_value_length;
		}

		public void run() {
			redraw_screen();
			while(event_loop_done == false) {
				process_events();
				@interface.execute_idle_loop_work();
			}
		}

		//
		// screen updates
		void redraw_screen() {
			@interface.screen_fill(null, 0);
			set_header();
			redraw_selector();
		}
		void set_header() {
			Rect rect = {20, 20};
			@interface.screen_blit(blank_header_area, null, rect);

			var rendered_text = font.render(selector.menu_name, @interface.white_color);
			rect = {(int16)(390 - rendered_text.w/2), 20};
			@interface.screen_blit(rendered_text, null, rect);
		}
		void redraw_selector() {
			selector.blit_to_screen(100, 60);
			//update_selection_message();
			@interface.screen_flip();
		}
		void redraw_item() {
			selector.update_selected_item_value();
			redraw_selector();
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
						this.event_loop_done = true;
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
			if (selector.select_previous())
				redraw_selector();
		}
		void select_next() {
			if (selector.select_next())
				redraw_selector();
		}
		void select_first() {
			if (selector.select_first())
				redraw_selector();
		}
		void select_last() {
			if (selector.select_last())
				redraw_selector();
		}
		void select_next_starting_with(char c) {
			if (last_pressed_alphanumeric == c) {
				last_pressed_alphanumeric_repeat_count++;
			} else {
				last_pressed_alphanumeric = c;
				last_pressed_alphanumeric_repeat_count = 0;
			}
			if (last_pressed_alphanumeric_repeat_count > 0) {
				if (selector.select_item_starting_with(last_pressed_alphanumeric.to_string(), last_pressed_alphanumeric_repeat_count) == true) {
					redraw_selector();
					return;
				}
				last_pressed_alphanumeric_repeat_count = 0;
			}
			if(selector.select_item_starting_with(last_pressed_alphanumeric.to_string()) == true)
				redraw_selector();
		}
		char last_pressed_alphanumeric = 0;
		int last_pressed_alphanumeric_repeat_count;

		//
		// commands: misc
		void activate_selected() {


		}

		void go_back() {
			if (menu_stack.length == 0) {
				event_loop_done = true;
				return;
			}
			selector = menu_stack.pop_head();
			redraw_screen();
		}


	}
}
