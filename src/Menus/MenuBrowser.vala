using SDL;
using SDLTTF;
using Layers;
using Layers.MenuBrowser;

namespace Menus
{
	public class MenuBrowser : ScreenLayer
	{
		const int16 SELECTOR_XPOS = 100;
		const int16 SELECTOR_YPOS = 60;
		const string SELECTOR_ID = "selector";

		uint8 max_name_length;
		uint8 max_value_length;

		bool event_loop_done;
		GLib.Queue<MenuSelector> menu_stack;
		MenuSelector selector;
		MenuHeaderLayer header;
		//int16 pos_y_status_message;
		//Surface blank_message_area;

		public MenuBrowser(Menu menu, uint8 max_name_length, uint8 max_value_length) {
			if (menu.items.size == 0)
				GLib.error("Menu '%s' has no items.", menu.name);
			base("menubrowser");
			this.max_name_length = max_name_length;
			this.max_value_length = max_value_length;
			//pos_y_status_message = 470 - (font_height * 2);
			//blank_message_area = @interface.get_blank_surface(780, font_height * 2);
			menu_stack = new GLib.Queue<MenuSelector>();
			header = add_layer(new MenuHeaderLayer("header")) as MenuHeaderLayer;
			selector = add_layer(get_selector(menu)) as MenuSelector;
		}

		public void run() {
			@interface.push_screen_layer(this);
			set_header();
			selector.select_first();
			while(event_loop_done == false) {
				process_events();
				@interface.execute_idle_loop_work();
			}
			@interface.pop_screen_layer();
		}
		
		public Rect get_selector_rect() {
			return { SELECTOR_XPOS, SELECTOR_YPOS, (int16)selector.width };
		}

		MenuSelector get_selector(Menu menu) {
			var new_selector = new MenuSelector(SELECTOR_ID, SELECTOR_XPOS, SELECTOR_YPOS, menu, max_name_length, max_value_length);
			new_selector.changed.connect(() => on_selector_changed());
			return new_selector;
		}
		
		//
		// screen updates
		void push_menu(Menu menu) {
			menu_stack.push_head(selector);
			selector = get_selector(menu);
			replace_layer(SELECTOR_ID, selector);
			clear();
			set_header();
			selector.select_first();
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
			selector.update();
		}
		void set_header() {
			header.set_text(null, selector.menu_name, null, false);
		}
		void on_selector_changed() {
		}
		void redraw_item() {
			selector.update_selected_item_value();
			flip();
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
