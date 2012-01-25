using SDL;
using SDLTTF;
using Data;
using Data.GameList;
using Layers.Controls;
using Layers.GameBrowser;
using Menus;
using Menus.Fields;

public class GameBrowser : Layers.ScreenLayer
{
	const int16 SELECTOR_XPOS = 100;
	const int16 SELECTOR_YPOS = 60;
	const string SELECTOR_ID = "selector";
	
	bool event_loop_done;

	GameBrowserUI ui;

	HeaderLayer header;
	StatusMessageLayer status_message;
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
		base("gamebrowser", @interface.game_browser_ui.background_color_rgb);
		ui = @interface.game_browser_ui;
		current_platform_index = -1;
		header = add_layer(new HeaderLayer("header")) as HeaderLayer;
		status_message = add_layer(new StatusMessageLayer("status-message")) as StatusMessageLayer;		
	}

	public void run() {
		platforms = Data.platforms();
		initialize_from_browser_state();
		@interface.push_screen_layer(this, false);
		ui.colors_updated.connect(update_colors);
		ui.font_updated.connect(update_font);
		Data.Provider.instance().platforms_changed.connect(update_platforms);
		flip();
		Key.enable_unicode(1);
        while(event_loop_done == false) {
            process_events();
            @interface.execute_idle_loop_work();
        }
		update_browser_state();
		Data.save_browser_state();
		if (Data.pnd_mountset().has_mounted == true) {
			status_message.push("Unmounting PNDs...");
			Data.pnd_mountset().unmount_all();
		}
		@interface.pop_screen_layer();
	}
	
	void update_colors() {
		header.set_rgb_color(ui.background_color_rgb);
		status_message.set_rgb_color(ui.background_color_rgb);
		this.set_rgb_color(ui.background_color_rgb);
	}
	void update_font() {
	}
	void update_platforms() {
		string? current_id = (current_platform != null) ? current_platform.id : null;
		platforms = Data.platforms();
		current_platform = null;
		current_platform_index = -1;
		if (current_id != null) {
			for(int index=0; index<platforms.size; index++) {
				var platform = platforms[index];
				if (platform.id == current_id) {
					current_platform = platform;
					current_platform_index = index;
					break;
				}
			}
		}
		if (current_platform != null && current_folder != null) {
			var unique_id = current_folder.unique_id();
			var new_folder = current_platform.get_folder(unique_id);
			if (new_folder == null)
				new_folder = current_platform.get_root_folder();
			current_folder = new_folder;
		} else {
			current_folder = null;
		}
		
		if (everything_selector != null)
			everything_selector.rebuild();
		if (everything_active && existing_selector != null) {
			var gfs = existing_selector as GameFolderSelector;
			if (gfs != null) {
				if (current_folder != null)
					gfs.folder = current_folder;
				else
					existing_selector = null;
			} else {
				existing_selector.rebuild();
			}			
		}
		change_selector();
		selector.update();
		debug("update_platforms() finish");
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
			change_selector();
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
		} else {
			current_folder = current_platform.get_folder(state.get_current_platform_folder_id() ?? "");
			if (current_folder == null)
				current_folder = current_platform.get_root_folder();			
		}
		change_selector();
		var filter = state.get_current_platform_filter();
		if (filter != null)
			selector.filter(filter);
		int item_index = state.get_current_platform_item_index();
		if (item_index < 0)
			item_index = 0;
		if (selector.select_item(item_index) == false)
			selector.update();
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
	// layer updates
	void set_header() {		
		string left = null;
		string center = null;
		string right = null;
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
		header.set_text(left, center, right, false);
	}
	void change_selector() {
		Selector new_selector = null;
		if (this.everything_active == true) {
			if (everything_selector == null) {
				everything_selector = new EverythingSelector(SELECTOR_ID, SELECTOR_XPOS, SELECTOR_YPOS);
				everything_selector.changed.connect(() => on_selector_changed());
			}
			new_selector = everything_selector;
		} else if (this.current_folder == null) {
			new_selector = new PlatformSelector(SELECTOR_ID, SELECTOR_XPOS, SELECTOR_YPOS);
			new_selector.changed.connect(() => on_selector_changed());
		} else {
			new_selector = new GameFolderSelector(this.current_folder, SELECTOR_ID, SELECTOR_XPOS, SELECTOR_YPOS);
			new_selector.changed.connect(() => on_selector_changed());
		}
		
		if (this.selector == null)
			add_layer(new_selector);
		else
			replace_layer(SELECTOR_ID, new_selector);
		
		this.selector = new_selector;
		clear();
		set_header();
	}
	void on_selector_changed() {
		if (everything_active == true)
			set_header();
		status_message.clear();
		string center = "%d / %d".printf(selector.selected_display_index() + 1, selector.display_item_count);
		string? right = null;
		string? active_pattern = selector.get_filter_pattern();
		if (active_pattern != null)
			right = "\"%s\"".printf(active_pattern);
		status_message.push(null, center, right, false);
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
				case KeySymbol.PERIOD:
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
				case KeySymbol.SPACE:
					show_context_menu();
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
		if (event.keysym.sym != KeySymbol.PERIOD)
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
//~ 		status_message.push("running main configuration...");
//~ 		ConfigGui.run();
//~ 		ui.update_font_from_preferences();
//~ 		ui.update_colors_from_preferences();
//~ 		this.update();
		Menus.Concrete.MainConfiguration.run();
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
			//status_message.push("editing platform %s...".printf(platform.name));
			if (ObjectMenu.edit("Platform: " + platform.name, platform) == true)
				update_platforms();
			//ConfigGui.edit_platform(platform);
			//status_message.pop();
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
				//status_message.push("editing program %s...".printf(program.name));
				//ConfigGui.edit_program(current_platform, program);
				if (ObjectMenu.edit("Program: " + program.name, program) == true) {
					try {
						Data.data_interface().save(platform);
					} catch(GLib.Error e) {
						debug("Error saving platform '%s': %s", platform.name, e.message);
					}
				}
				//status_message.pop();
			}
		}
	}

	//
	// commands: selection
	void select_previous() {
		selector.select_previous();
	}
	void select_previous_page() {
		selector.select_previous_by(@interface.SELECTOR_VISIBLE_ITEMS);
	}
	void select_next() {
		selector.select_next();
	}
	void select_next_page() {
		selector.select_next_by(@interface.SELECTOR_VISIBLE_ITEMS);
	}
	void select_first() {
		selector.select_first();
	}
	void select_last() {
		selector.select_last();
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
		selector.update();
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
		selector.update();
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
		if (selector.selected_index == -1)
			return;

		if (everything_active == true) {
			var game = everything_selector.selected_game();
			if (game != null) {
				status_message.push("running '%s'...".printf(game.unique_id()));
				game.run();
				status_message.pop();
			}
			return;
		}

		var platform_selector = selector as PlatformSelector;
		if (platform_selector != null) {
			current_platform = platform_selector.selected_platform();
			current_folder = current_platform.get_root_folder();
			change_selector();
			var state = Data.browser_state();
			Data.browser_state().current_platform = current_platform.id;
			current_filter = state.get_current_platform_filter();
			if (current_filter != null)
				selector.filter(current_filter);
			selector.select_item(0);
			return;
		}

		var game_selector = selector as GameFolderSelector;
		if (game_selector != null) {
			var item = game_selector.selected_item();
			var folder = item as GameFolder;
			if (folder != null) {
				current_folder = folder;
				change_selector();
				if (current_filter != null)
					selector.filter(current_filter);
				selector.select_item(0);
				return;
			}
			var game = item as GameItem;
			if (game != null) {
				status_message.push("running '%s'...".printf(item.unique_id()));
				game.run();
				status_message.pop();
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
				int index=0;
				foreach(var platform in Data.platforms()) {
					if (platform.name == current_platform.name)
						break;
					index++;
				}
				current_platform = null;
				change_selector();
				selector.select_item(index);				
				return;
			}
			var current_id = current_folder.unique_id();
			current_folder = current_folder.parent;
			change_selector();
			if (current_filter != null)
				selector.filter(current_filter);
			int index=0;
			foreach(var subfolder in current_folder.child_folders()) {
				if (subfolder.unique_id() == current_id)
					break;
				index++;
			}
			selector.select_item(index);			
			return;
		}
	}

	void filter_selector() {
		status_message.flush();
		var entry = new TextEntry("selection_filter", 600, 450, 200, selector.get_filter_pattern(), "[-\\d\\.]", "^-?\\d*(\\.\\d*)?$");
		//var entry = new IntegerEntry("selection_filter", 600, 450, 200, 43, 5, 100, 25);
//~ 		entry.text_changed.connect((text) => {
//~ 			selector.filter(text);
//~ 			selector.update();
//~ 		});
		var new_pattern = entry.run();
		if (new_pattern != "") {
			selector.filter(new_pattern);
			current_filter = new_pattern;
		} else {
			selector.clear_filter();
			current_filter = null;
		}
		update();
	}

	void toggle_everything() {
		if (everything_active == false) {
			existing_selector = selector;
			if (everything_selector == null) {
				apply_all_games_state(true);
			} else {
				everything_active = true;
				change_selector();
				selector.update();
			}
			
		} else {
			everything_active = false;
			if (existing_selector == null) {
				apply_platform_state();
			} else {
				clear();			
				selector = existing_selector;
				replace_layer(SELECTOR_ID, selector);
				set_header();
				selector.update();			
			}
		}
	}

	void show_context_menu() {
		//Menus.Concrete.MainConfiguration.run();
		if (selector.selected_index == -1)
			return;
		
		var platform_selector = selector as PlatformSelector;
		if (platform_selector != null) {			
			show_platform_menu(platform_selector.selected_platform());
			return;
		}
		
		if (everything_active == true) {
			show_game_menu(everything_selector.selected_game());
			return;
		}
		
		var game_selector = selector as GameFolderSelector;
		if (game_selector != null) {
			var item = game_selector.selected_item();
			var folder = item as GameFolder;
			if (folder != null) {
				show_folder_menu(folder);
				return;
			}
			var game = item as GameItem;
			if (game != null) {
				show_game_menu(game);
				return;
			}
		}
				
	}
	void show_game_menu(GameItem? game) {
		if (game != null)
			show_menu_overlay(new Menus.Concrete.GameMenu(game));
	}
	void show_folder_menu(GameFolder folder) {
		show_menu_overlay(new Menus.Concrete.GameFolderMenu(folder));
	}
	void show_program_menu(Program program) {
	}
	void show_platform_menu(Platform? platform) {
		if (platform != null)
			show_menu_overlay(new Menus.Concrete.PlatformMenu(platform));
		
	}
	void show_menu_overlay(Menu menu) {
		new Layers.GameBrowser.MenuOverlay(menu, 100, 100).run();
	}
	
}
