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

		const uint8 MAX_NAME_LENGTH = 40;
		const uint8 MAX_VALUE_LENGTH = 40;

		MenuHeaderLayer header;
		MenuMessageLayer message;
		int16 selector_ypos;
		int16 selector_max_height;
		MenuSelector selector;
		GLib.Queue<MenuSelector> menu_stack;
		Layer? additional_layer;

		public MenuBrowser(Menu menu) {
			if (menu.items.size == 0)
				GLib.error("Menu '%s' has no items.", menu.name);
			base("menubrowser", @interface.game_browser_ui.background_color_rgb);
			menu_stack = new GLib.Queue<MenuSelector>();
			header = add_layer(new MenuHeaderLayer("header")) as MenuHeaderLayer;
			message = add_layer(new MenuMessageLayer("status")) as MenuMessageLayer;
			selector_ypos = header.ypos + (int16)header.height + @interface.get_monospaced_font_height();
			selector_max_height = message.ypos - selector_ypos;
			selector = add_layer(get_selector(menu)) as MenuSelector;
		}

		public void run() {
			@interface.push_screen_layer(this);
			
			set_header();			
			add_additional_layer(selector.menu);
			
			selector.ensure_initial_selection(false);
			set_initial_help();
			
			process_events();
			
			@interface.pop_screen_layer();
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
			draw_rectangle_fill(upper_left.x, upper_left.y, width, height, @interface.black_color);
			
			draw_horizontal_line(upper_left.x, upper_right.x, upper_left.y, @interface.white_color);
			draw_horizontal_line(upper_left.x, upper_right.x, header_bottom_y + 1, @interface.white_color);
			draw_vertical_line(upper_left.x, upper_left.y, lower_left.y, @interface.white_color);
			draw_vertical_line(upper_right.x, upper_right.y, lower_left.y, @interface.white_color);
			draw_horizontal_line(lower_left.x, lower_right.x, lower_left.y, @interface.white_color);			
		}

		MenuSelector get_selector(Menu menu) {
			var new_selector = new MenuSelector(SELECTOR_ID, SELECTOR_XPOS, selector_ypos, menu, selector_max_height, MAX_NAME_LENGTH, MAX_VALUE_LENGTH);
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
			selector.ensure_initial_selection(false);
			set_initial_help();
			add_additional_layer(menu);
			selector.select_first();
			menu_changed(menu);
		}
		void pop_menu() {
			if (menu_stack.length == 0) {
				quit_event_loop();
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
