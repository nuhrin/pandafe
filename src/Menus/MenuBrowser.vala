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

		const uint8 MAX_NAME_LENGTH = 40;
		const uint8 MAX_VALUE_LENGTH = 40;

		bool event_loop_done;
		GLib.Queue<MenuSelector> menu_stack;
		MenuSelector selector;
		MenuHeaderLayer header;
		MenuMessageLayer message;
		Layer? additional_layer;
		//int16 pos_y_status_message;
		//Surface blank_message_area;

		public MenuBrowser(Menu menu) {
			if (menu.items.size == 0)
				GLib.error("Menu '%s' has no items.", menu.name);
			base("menubrowser");
			//pos_y_status_message = 470 - (font_height * 2);
			//blank_message_area = @interface.get_blank_surface(780, font_height * 2);
			menu_stack = new GLib.Queue<MenuSelector>();
			header = add_layer(new MenuHeaderLayer("header")) as MenuHeaderLayer;
			message = add_layer(new MenuMessageLayer("status")) as MenuMessageLayer;			
			selector = add_layer(get_selector(menu)) as MenuSelector;
		}

		public void run() {
			@interface.push_screen_layer(this);
			set_header();			
			add_additional_layer(selector.menu);
			selector.select_first();
			while(event_loop_done == false) {
				process_events();
				@interface.execute_idle_loop_work();
			}
			@interface.pop_screen_layer();
		}
		
		public signal void menu_changed(Menu menu);
		
		public Rect get_selector_rect() {
			return { SELECTOR_XPOS, SELECTOR_YPOS, (int16)selector.width };
		}

		MenuSelector get_selector(Menu menu) {
			var new_selector = new MenuSelector(SELECTOR_ID, SELECTOR_XPOS, SELECTOR_YPOS, menu, MAX_NAME_LENGTH, MAX_VALUE_LENGTH);
			new_selector.changed.connect(() => on_selector_changed());
			menu.message.connect((message) => on_message(message));
			menu.error.connect((error) => on_error(error));
			menu.field_error.connect((field, index, error) => on_field_error(field, index, error));
			menu.clear_error.connect(() => clear_error());
			menu.refreshed.connect(() => refresh_menu(menu));
			return new_selector;
		}
		
		//
		// screen updates
		void push_menu(Menu menu) {
			remove_additional_layer();
			menu_stack.push_head(selector);
			selector = get_selector(menu);
			replace_layer(SELECTOR_ID, selector);
			clear();
			set_header();
			message.reset();
			add_additional_layer(menu);
			selector.select_first();
			menu_changed(menu);
		}
		void pop_menu() {
			if (menu_stack.length == 0) {
				event_loop_done = true;
				return;
			}
			remove_additional_layer();
			selector = menu_stack.pop_head();
			replace_layer(SELECTOR_ID, selector);
			clear();
			set_header();
			message.reset();
			add_additional_layer(selector.menu);
			selector.update();
			menu_changed(selector.menu);
		}
		void refresh_menu(Menu menu) {
			if (menu == selector.menu) {
				selector.update();
				message.reset();
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
			clear_message();
			var selected_item = selector.selected_item();
			var selected_menu = selected_item as Menu;
			if (selected_menu != null) {
				push_menu(selected_menu);
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
