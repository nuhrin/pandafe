using SDL;
using SDLTTF;
using Data;
using Data.GameList;

public class GameBrowser
{
	InterfaceHelper @interface;

	bool event_loop_done;

	int16 pos_y_status_message;

    Selector selector;
    Gee.List<Platform> platforms;
    Platform current_platform;
    int current_platform_index;
	GameFolder current_folder;

    public GameBrowser(InterfaceHelper @interface) {
		this.@interface = @interface;
		current_platform_index = -1;
		pos_y_status_message = 470 - @interface.font_height;
	}

	public void run() {
		platforms = Data.platforms();
		initialize_from_browser_state();
		redraw_screen();
		Key.enable_unicode(1);
        while(event_loop_done == false) {
            process_events();
            @interface.execute_idle_loop_work();
        }
		update_browser_state();
		Data.save_browser_state();
		if (Data.pnd_mountset().has_mounted == true) {
			push_status_message("Unmounting PNDs...");
			Data.pnd_mountset().unmount_all();
		}
	}

	void initialize_from_browser_state() {
		var state = Data.browser_state();
		current_platform = null;
		if (state.current_platform != null) {
			for(int index=0; index<platforms.size; index++) {
				var platform = platforms[index];
				if (platform.id == state.current_platform) {
					current_platform = platform;
					current_platform_index = index;
					break;
				}
			}
		}
		apply_platform_state();
	}
	void apply_platform_state() {
		var state = Data.browser_state();
		if (current_platform == null) {
			current_folder = null;
			selector = new PlatformSelector(@interface);
		} else {
			current_folder = current_platform.get_folder(state.get_current_platform_folder_id() ?? "");
			if (current_folder == null)
				current_folder = current_platform.get_root_folder();
			selector = new GameFolderSelector(current_folder, @interface);
		}
		int item_index = state.get_current_platform_item_index();
		if (item_index > 0) {
			selector.select_item(item_index);
			update_selection_message();
		} else {
			selector.select_item(0);
		}
	}
	void update_browser_state() {
		var state = Data.browser_state();
		state.current_platform = (current_platform != null) ? current_platform.id : null;
		if (current_platform != null)
			state.apply_platform_state(current_platform, (current_folder != null) ? current_folder.unique_id() : null, selector.selected_index);
	}

	void redraw_screen() {
		@interface.screen_fill(null, @interface.background_color_rgb);
		_set_header();
		redraw_selector();
	}
	void _set_header() {
		Rect clear_rect = {20, 20, 760};
		@interface.screen_fill(clear_rect, @interface.background_color_rgb);

		string platform_name = (current_platform != null) ? current_platform.name : null;
		if (platform_name != null) {
			Rect platform_rect = {20, 20};
			@interface.screen_blit(@interface.render_text_selected(platform_name), null, platform_rect);
		}

		string folder_id = (current_folder != null) ? current_folder.unique_id().strip() : "";
		if (folder_id != null && folder_id != "") {
			var rendered_folder_id = @interface.render_text_selected(folder_id);
			Rect folder_id_rect = {(int16)(780 - rendered_folder_id.w), 20};
			@interface.screen_blit(rendered_folder_id, null, folder_id_rect);
		}
	}
	void redraw_selector() {
		selector.blit_to_screen(100, 60);
		update_selection_message();
    }

	void update_selection_message() {
		clear_status_messages();
		push_status_message("%d / %d".printf(selector.selected_index, selector.item_count - 1), true);
	}
	void push_status_message(string message, bool centered=false) {
		if (status_message_stack == null)
			status_message_stack = new GLib.Queue<StatusMessage>();
		if (status_message_stack.is_empty() == false)
			wipe_status_message();
		status_message_stack.push_head(new StatusMessage(message, centered));
		write_status_message();
		@interface.screen_flip();
	}
	void pop_status_message() {
		if (status_message_stack == null || status_message_stack.is_empty() == true)
			return;
		status_message_stack.pop_head();
		wipe_status_message();
		if (status_message_stack.is_empty() == false)
			write_status_message();
		@interface.screen_flip();
	}
	void clear_status_messages() {
		if (status_message_stack == null)
			return;
		status_message_stack.clear();
		wipe_status_message();
		@interface.screen_flip();
	}
	void wipe_status_message() {
		Rect rect = {10, pos_y_status_message, 780, @interface.font_height};
		@interface.screen_fill(rect, @interface.background_color_rgb);
	}
	void write_status_message() {
		var sm = status_message_stack.peek_head();
		var rendered_message = @interface.render_text_selected(sm.message);
		Rect rect;
		if (sm.is_centered == true)
			rect = {(int16)(390 - rendered_message.w/2), pos_y_status_message};
		else
			rect = {10, pos_y_status_message, 780};
		@interface.screen_blit(rendered_message, null, rect);
	}
	class StatusMessage : Object
	{
		public StatusMessage(string message, bool is_centered) {
			this.message = message;
			this.is_centered = is_centered;
		}
		public string message;
		public bool is_centered;
	}
	GLib.Queue<StatusMessage> status_message_stack;

    void process_events() {
        Event event = Event();
        while(Event.poll(event) == 1) {
            switch(event.type) {
				case EventType.QUIT:
					this.event_loop_done = true;
					break;
				case EventType.KEYDOWN:
					this.on_keyboard_event(event.key);
					break;
				case EventType.KEYUP:
					if (event.key.keysym.sym != KeySymbol.SPACE)
						process_unicode_disabled = false;
					break;
			}
        }
    }
    void drain_events() {
		Event event = Event();
        while(Event.poll(event) == 1);
	}
    void on_keyboard_event (KeyboardEvent event) {
		if (process_unicode(event.keysym.unicode) == false)
			return;

		if (event.keysym.mod == KeyModifier.NONE) {
			switch(event.keysym.sym) {
				case KeySymbol.SPACE:
					process_unicode_disabled = true;
					return;
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
				case KeySymbol.RETURN:
				case KeySymbol.KP_ENTER:
				case KeySymbol.PAGEDOWN: // pandora X
					activate_selected();
					drain_events();
					break;
				case KeySymbol.ESCAPE:
				case KeySymbol.HOME: // pandora A
					if (current_platform == null) {
						this.event_loop_done = true;
						return;
					}
					go_back();
					break;
				case KeySymbol.PAGEUP: // pandora X
					select_first();
					break;
				case KeySymbol.END: // pandora B
					select_last();
					break;
				case KeySymbol.RSHIFT: // pandora R
					select_next_platform();
					drain_events();
					break;
				case KeySymbol.RCTRL: // pandora L
					select_previous_platform();
					drain_events();
					break;
				case KeySymbol.SLASH:
					filter_selector();
					break;
				case KeySymbol.c:
					do_configuration();
					drain_events();
					break;
				case KeySymbol.p:
					edit_current_platform();
					drain_events();
					break;
				case KeySymbol.s:
					apply_list_filter();
					break;
				case KeySymbol.q:
					this.event_loop_done = true;
					break;
				default:
					break;
			}
		} else if ((event.keysym.mod & KeyModifier.SHIFT) != 0) {
			if (event.keysym.sym == KeySymbol.p) {
				edit_current_program();
				drain_events();
			}
//~ 			if (event.keysym.sym == KeySymbol.RETURN || event.keysym.sym == KeySymbol.KP_ENTER) {
//~ 				WindowManager.toggle_fullscreen(screen);
//~ 			}
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

    void do_configuration() {
		push_status_message("running main configuration...");
		ConfigGui.run();
		@interface.update_from_preferences();
		redraw_screen();
	}
	void edit_current_platform() {
		if (current_platform != null) {
			push_status_message("editing platform %s...".printf(current_platform.name));
			ConfigGui.edit_platform(current_platform);
			pop_status_message();
		}
	}
	void edit_current_program() {
		if (current_platform != null) {
			var program = current_platform.default_program;
			if (program != null) {
				push_status_message("editing program %s...".printf(program.name));
				ConfigGui.edit_program(current_platform, program);
				pop_status_message();
			}
		}
	}

	void select_previous() {
		if (selector.select_previous())
			redraw_selector();
	}
	void select_previous_page() {
		if (selector.select_previous_by(@interface.SELECTOR_VISIBLE_ITEMS))
			redraw_selector();
	}
	void select_next() {
		if (selector.select_next())
			redraw_selector();
	}
	void select_next_page() {
		if (selector.select_next_by(@interface.SELECTOR_VISIBLE_ITEMS))
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
	void select_next_platform() {
		if (current_platform == null)
			return;
		update_browser_state();
		current_platform_index++;
		if (current_platform_index >= platforms.size)
			current_platform_index = 0;
		current_platform = platforms[current_platform_index];
		Data.browser_state().current_platform = current_platform.id;
		apply_platform_state();
		redraw_screen();
	}
	void select_previous_platform() {
		if (current_platform == null)
			return;
		update_browser_state();
		current_platform_index--;
		if (current_platform_index < 0)
			current_platform_index = platforms.size - 1;
		current_platform = platforms[current_platform_index];
		Data.browser_state().current_platform = current_platform.id;
		apply_platform_state();
		redraw_screen();
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

	void apply_list_filter() {
		selector.filter("ar$");
	}

    void activate_selected() {
		if (selector.selected_index == -1)
			return;

		var platform_selector = selector as PlatformSelector;
		if (platform_selector != null) {
			current_platform = platform_selector.selected_platform();
			current_folder = current_platform.get_root_folder();
			selector = new GameFolderSelector(current_folder, @interface);
			selector.select_item(0);
			redraw_screen();
			return;
		}

		var game_selector = selector as GameFolderSelector;
		if (game_selector != null) {
			if (game_selector.is_go_back_selected() == true) {
				go_back();
				return;
			}
			var item = game_selector.selected_item();
			var folder = item as GameFolder;
			if (folder != null) {
				current_folder = folder;
				selector = new GameFolderSelector(current_folder, @interface);
				selector.select_item(0);
				redraw_screen();
				return;
			}
			var game = item as GameItem;
			if (game != null) {
				push_status_message("running '%s'...".printf(item.unique_id()));
				game.run();
				pop_status_message();
			}
		}
	}

	void go_back() {
		var game_selector = selector as GameFolderSelector;
		if (game_selector != null) {
			if (current_folder.parent == null) {
				current_folder = null;
				selector = new PlatformSelector(@interface);
				int index=0;
				foreach(var platform in Data.platforms()) {
					if (platform.name == current_platform.name)
						break;
					index++;
				}
				current_platform = null;
				selector.select_item(index);
				redraw_screen();
				return;
			}
			var current_id = current_folder.unique_id();
			current_folder = current_folder.parent;
			selector = new GameFolderSelector(current_folder, @interface);
			int index=0;
			foreach(var subfolder in current_folder.child_folders()) {
				if (subfolder.unique_id() == current_id)
					break;
				index++;
			}
			selector.select_item(index+1);
			redraw_screen();
			return;
		}
	}

	void filter_selector() {
		var active_pattern = selector.get_filter_pattern();
		var entry = new TextEntry(@interface, 200, active_pattern);
		@interface.dim_screen(75);
		var new_pattern = entry.run(300, 200);
		if (active_pattern != new_pattern) {
			if (new_pattern != "")
				selector.filter(new_pattern);
			else
				selector.clear_filter();
		}

		redraw_screen();
	}
}
