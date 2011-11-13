using SDL;
using SDLTTF;
using Data;
using Data.GameList;
using Menus;
using Menus.Fields;

public class GameBrowser
{
	bool event_loop_done;

	int16 pos_y_status_message;
	Surface blank_header;
	Surface blank_status;

    Selector selector;
    Selector existing_selector;
    EverythingSelector everything_selector;
    bool everything_active;
    Gee.List<Platform> platforms;
    Platform current_platform;
    int current_platform_index;
    string current_filter;
	GameFolder current_folder;

    public GameBrowser() {
		current_platform_index = -1;
		pos_y_status_message = 470 - @interface.font_height;
		blank_header = @interface.get_blank_background_surface(760, @interface.font_height);
		blank_status = @interface.get_blank_background_surface(780, @interface.font_height);
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

	//
	// browser state
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
		if (apply_all_games_state() == false)
			apply_platform_state();
	}
	bool apply_all_games_state(bool active=false) {
		var all_games = Data.browser_state().all_games;

		if (all_games != null && (active == true || all_games.active == true)) {
			everything_active = true;
			everything_selector = new EverythingSelector();
			selector = everything_selector;
			if (all_games != null) {
				if (all_games.filter != null)
					selector.filter(all_games.filter);
				if (all_games.item_index > 0)
					selector.select_item(all_games.item_index);
				else
					selector.select_first();
			}
			return true;
		}
		return false;
	}
	void apply_platform_state() {
		var state = Data.browser_state();
		if (current_platform == null) {
			current_folder = null;
			selector = new PlatformSelector();
		} else {
			current_folder = current_platform.get_folder(state.get_current_platform_folder_id() ?? "");
			if (current_folder == null)
				current_folder = current_platform.get_root_folder();
			selector = new GameFolderSelector(current_folder);
		}
		var filter = state.get_current_platform_filter();
		if (filter != null)
			selector.filter(filter);
		int item_index = state.get_current_platform_item_index();
		if (item_index > 0)
			selector.select_item(item_index);
		else
			selector.select_first();
	}
	void update_browser_state() {
		var state = Data.browser_state();
		state.current_platform = (current_platform != null) ? current_platform.id : null;
		if (current_platform != null)
			state.apply_platform_state(current_platform, (current_folder != null) ? current_folder.unique_id() : null, selector.selected_index, selector.get_filter_pattern());
		if (everything_selector != null)
			state.apply_all_games_state(everything_active, everything_selector.selected_index, everything_selector.get_filter_pattern());
		else
			state.apply_all_games_state(false, 0, null);
	}

	//
	// screen updates
	void redraw_screen() {
		@interface.screen_fill(null, @interface.background_color_rgb);
		set_header();
		redraw_selector();
	}
	void set_header() {
		Rect rect = {20, 20};
		@interface.screen_blit(blank_header, null, rect);

		string left = null;
		string center = null;
		string right = null;
		Surface rendered_text;
		if (everything_active == true) {
			left = "All Games";
			var game = everything_selector.selected_game();
			if (game != null) {
				center = game.platform().name;
				if (game.parent.parent != null)
					right = game.parent.unique_id().strip();
			}
		}
		else if (current_platform != null) {
			left = current_platform.name;
			right = current_folder.unique_id().strip();
		}
		if (left != null) {
			@interface.screen_blit(@interface.render_text_selected_fast(left), null, rect);
		}
		if (center != null) {
			rendered_text = @interface.render_text_selected_fast(center);
			rect = {(int16)(390 - rendered_text.w/2), 20};
			@interface.screen_blit(rendered_text, null, rect);
		}
		if (right != null && right != "") {
			rendered_text = @interface.render_text_selected_fast(right);
			rect = {(int16)(780 - rendered_text.w), 20};
			@interface.screen_blit(rendered_text, null, rect);
		}
	}
	void redraw_selector() {
		selector.blit_to_screen(100, 60);
		update_selection_message();
    }

	//
	// status messages
	void update_selection_message() {
		if (everything_active == true)
			set_header();
		clear_status_messages();
		string center = "%d / %d".printf(selector.selected_display_index() + 1, selector.display_item_count);
		string? right = null;
		string? active_pattern = selector.get_filter_pattern();
		if (active_pattern != null)
			right = "\"%s\"".printf(active_pattern);
		push_status_message(null, center, right);
	}
	void push_status_message(string? left=null, string? center=null, string? right=null) {
		if (status_message_stack == null)
			status_message_stack = new GLib.Queue<StatusMessage>();
		if (status_message_stack.is_empty() == false)
			wipe_status_message();
		status_message_stack.push_head(new StatusMessage(left, center, right));
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
		Rect rect = {10, pos_y_status_message};
		@interface.screen_blit(blank_status, null, rect);
	}
	void write_status_message() {
		var sm = status_message_stack.peek_head();
		Surface rendered_message;
		Rect rect;
		if (sm.left != null) {
			rendered_message = @interface.render_text_selected_fast(sm.left);
			rect = {10, pos_y_status_message};
			@interface.screen_blit(rendered_message, null, rect);
		}
		if (sm.center != null) {
			rendered_message = @interface.render_text_selected_fast(sm.center);
			rect = {(int16)(390 - rendered_message.w/2), pos_y_status_message};
			@interface.screen_blit(rendered_message, null, rect);
		}
		if (sm.right != null) {
			rendered_message = @interface.render_text_selected_fast(sm.right);
			rect = {(int16)(790 - rendered_message.w), pos_y_status_message};
			@interface.screen_blit(rendered_message, null, rect);
		}
	}
	class StatusMessage : Object {
		public StatusMessage(string? left=null, string? center=null, string? right=null) {
			this.left = left;
			this.center = center;
			this.right = right;
		}
		public string? left;
		public string? center;
		public string? right;
	}
	GLib.Queue<StatusMessage> status_message_stack;

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

		if (event.keysym.sym == KeySymbol.RSHIFT) {
			// pandora L
			L_pressed = true;
			if (R_pressed == true)
				L_R_both_pressed = true;
			return;
		}
		if (event.keysym.sym == KeySymbol.RCTRL) {
			// pandora R
			R_pressed = true;
			if (L_pressed == true)
				L_R_both_pressed = true;
			return;
		}

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
				case KeySymbol.END: // pandora B
					activate_selected();
					drain_events();
					break;
				case KeySymbol.HOME: // pandora A
					if (everything_active == true || current_platform == null) {
						this.event_loop_done = true;
						return;
					}
					go_back();
					break;
				case KeySymbol.PAGEUP: // pandora Y
					select_first();
					break;
				case KeySymbol.PAGEDOWN: // pandora X
					select_last();
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
				case KeySymbol.PERIOD:
					show_test_menu();
					drain_events();
					break;
				case KeySymbol.ESCAPE:
				case KeySymbol.q:
					this.event_loop_done = true;
					break;
				default:
					break;
			}
			return;
		}

		if ((event.keysym.mod & KeyModifier.SHIFT) != 0) {
			if (event.keysym.sym == KeySymbol.p) {
				edit_current_program();
				drain_events();
				return;
			}
		}
    }
    void on_keyup_event (KeyboardEvent event) {
		if (event.keysym.sym != KeySymbol.SPACE)
			process_unicode_disabled = false;

		if (event.keysym.sym == KeySymbol.RSHIFT) {
			// pandora L
			L_pressed = false;
			if (L_R_both_pressed == true) {
				if (R_pressed == true)
					return;
				L_R_both_pressed = false;
				toggle_everything();
				drain_events();
				return;
			}
			select_previous_platform();
			drain_events();
			return;
		}
		if (event.keysym.sym == KeySymbol.RCTRL) {
			// pandora R
			R_pressed = false;
			if (L_R_both_pressed == true) {
				if (L_pressed == true)
					return;
				L_R_both_pressed = false;
				toggle_everything();
				drain_events();
				return;
			}
			select_next_platform();
			drain_events();
			return;
		}
	}
	bool L_pressed;
	bool R_pressed;
	bool L_R_both_pressed;
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
	// commands: configuration
    void do_configuration() {
		push_status_message("running main configuration...");
		ConfigGui.run();
		@interface.update_from_preferences();
		redraw_screen();
	}
	void edit_current_platform() {
		Platform platform = null;
		if (everything_active == true) {
			var game = everything_selector.selected_game();
			if (game != null)
				platform = game.platform();
		} else if (current_platform != null) {
			platform = current_platform;
		}
		if (platform != null) {
			push_status_message("editing platform %s...".printf(platform.name));
			ConfigGui.edit_platform(platform);
			pop_status_message();
		}
	}
	void edit_current_program() {
		Platform platform = null;
		if (everything_active == true) {
			var game = everything_selector.selected_game();
			if (game != null)
				platform = game.platform();
		} else if (current_platform != null) {
			platform = current_platform;
		}
		if (platform != null) {
			var program = current_platform.default_program;
			if (program != null) {
				push_status_message("editing program %s...".printf(program.name));
				ConfigGui.edit_program(current_platform, program);
				pop_status_message();
			}
		}
	}

	//
	// commands: selection
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
		if (everything_active == true || current_platform == null)
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
		if (everything_active == true || current_platform == null)
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

	//
	// commands: misc
    void activate_selected() {
		if (selector.selected_index == -1)
			return;

		if (everything_active == true) {
			var game = everything_selector.selected_game();
			if (game != null) {
				push_status_message("running '%s'...".printf(game.unique_id()));
				game.run();
				pop_status_message();
			}
			return;
		}

		var platform_selector = selector as PlatformSelector;
		if (platform_selector != null) {
			current_platform = platform_selector.selected_platform();
			current_folder = current_platform.get_root_folder();
			selector = new GameFolderSelector(current_folder);
			var state = Data.browser_state();
			Data.browser_state().current_platform = current_platform.id;
			current_filter = state.get_current_platform_filter();
			if (current_filter != null)
				selector.filter(current_filter);
			selector.select_item(0);
			redraw_screen();
			return;
		}

		var game_selector = selector as GameFolderSelector;
		if (game_selector != null) {
			var item = game_selector.selected_item();
			var folder = item as GameFolder;
			if (folder != null) {
				current_folder = folder;
				selector = new GameFolderSelector(current_folder);
				if (current_filter != null)
					selector.filter(current_filter);
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
				Data.browser_state().apply_platform_state(current_platform, current_folder.unique_id(),
					selector.selected_index, selector.get_filter_pattern());
				current_folder = null;
				current_filter = null;
				selector = new PlatformSelector();
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
			selector = new GameFolderSelector(current_folder);
			if (current_filter != null)
				selector.filter(current_filter);
			int index=0;
			foreach(var subfolder in current_folder.child_folders()) {
				if (subfolder.unique_id() == current_id)
					break;
				index++;
			}
			selector.select_item(index);
			redraw_screen();
			return;
		}
	}

	void filter_selector() {
		int dim_percentage = 50;
		clear_status_messages();
		@interface.dim_screen(dim_percentage);
		var entry = new TextEntry(@interface, 600, 450, 200, selector.get_filter_pattern());
		entry.changed.connect((text) => {
			selector.filter(text);
			selector.dim(dim_percentage);
			selector.blit_to_screen(100, 60);
			@interface.screen_flip();
		});
		var new_pattern = entry.run();
		if (new_pattern != "") {
			selector.filter(new_pattern);
			current_filter = new_pattern;
		} else {
			selector.clear_filter();
			current_filter = null;
		}

		redraw_screen();
	}

	void toggle_everything() {
		if (everything_active == false) {
			existing_selector = selector;
			if (everything_selector == null)
				apply_all_games_state(true);
			else
				selector = everything_selector;
			everything_active = true;
		} else {
			if (existing_selector == null)
				apply_platform_state();
			else
				selector = existing_selector;
			everything_active = false;
		}
		redraw_screen();
	}

	void show_test_menu() {
		var browser = new MenuBrowser(GetTestMenu(), 40, 40);
		browser.run();
		redraw_screen();
	}

	Menu GetTestMenu() {
		var menu = new Menu("test");
		menu.add_item(new MenuItem("Configuration"));
		menu.add_item(new MenuItem("Edit Current Platform"));
		menu.add_item(new MenuItem("Edit Current Program"));
		menu.add_item(new BooleanField("flag", "Flag"));
		menu.add_item(new EnumField("node_type", "NodeType", null, Catapult.Yaml.NodeType.SCALAR));
		menu.add_item(new IntegerField("integer", "Integer", null, 5, 1, 10, 2));
		menu.add_item(new MenuItem("Return"));
		menu.add_item(new MenuItem("Quit"));

		return menu;
	}
}
