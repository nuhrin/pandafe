using SDL;
using SDLTTF;
using Data;
using Data.GameList;

public class GameBrowser
{
	Preferences preferences;
	unowned SDL.Screen screen;
	const int FONT_SIZE = 16;
    const int DELAY = 10;
    const int VISIBLE_WITDH = 440;
    const int VISIBLE_ITEMS = 15;
	bool event_loop_done;
	Font font;
	Color background_color;
	uint32 background_color_rgb;
	Color selected_item_color;

    Selector selector;
    Gee.List<Platform> platforms;
    Platform current_platform;
    int current_platform_index;
	GameFolder current_folder;

    public GameBrowser(SDL.Screen* screen) {
		preferences = Data.preferences();
		this.screen = screen;
		font = new Font(preferences.font, FONT_SIZE);
		if (font == null) {
			GLib.error("Error loading font: %s", SDL.get_error());
		}
		current_platform_index = -1;
		background_color = preferences.background_color_sdl();
		background_color_rgb = this.screen.format.map_rgb(background_color.r, background_color.g, background_color.b);
		selected_item_color = preferences.selected_item_color_sdl();
	}

	public void run() {
		platforms = Data.platforms();
		initialize_from_browser_state();
		redraw_screen();
        while(event_loop_done == false) {
            process_events();
            SDL.Timer.delay(DELAY);
        }
		update_browser_state();
		Data.save_browser_state();
		if (Data.pnd_mountset().has_mounted == true) {
			show_status_message("Unmounting PNDs...");
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
			selector = new PlatformSelector(this.screen.format, this.font, VISIBLE_WITDH, VISIBLE_ITEMS);
		} else {
			current_folder = current_platform.get_folder(state.get_current_platform_folder_id() ?? "");
			if (current_folder == null)
				current_folder = current_platform.get_root_folder();
			selector = new GameFolderSelector(current_folder, this.screen.format, this.font, VISIBLE_WITDH, VISIBLE_ITEMS);
		}
		int item_index = state.get_current_platform_item_index();
		if (item_index > 0)
			selector.select_item(item_index);
		else
			selector.select_item(0);
	}
	void update_browser_state() {
		var state = Data.browser_state();
		state.current_platform = (current_platform != null) ? current_platform.id : null;
		if (current_platform != null)
			state.apply_platform_state(current_platform, (current_folder != null) ? current_folder.unique_id() : null, selector.selected_index);
	}

	void redraw_screen() {
		screen.fill(null, background_color_rgb);
		_set_header();
		redraw_selector();
	}
	void _set_header() {
		Rect clear_rect = {20, 20, 760};
		screen.fill(clear_rect, background_color_rgb);

		string platform_name = (current_platform != null) ? current_platform.name : null;
		if (platform_name != null) {
			Rect platform_rect = {20, 20};
			font.render_shaded(platform_name, selected_item_color, background_color).blit(null, screen, platform_rect);
		}

		string folder_id = (current_folder != null) ? current_folder.unique_id().strip() : "";
		if (folder_id != null && folder_id != "") {
			var rendered_folder_id = font.render_shaded(folder_id, selected_item_color, background_color);
			Rect folder_id_rect = {(int16)(780 - rendered_folder_id.w), 20};
			rendered_folder_id.blit(null, screen, folder_id_rect);
		}
	}
	void redraw_selector() {
		selector.blit_to(screen, 100, 60);
		screen.flip();
    }
	void show_status_message(string message) {
		Rect rect = {10, 420, 460};
		font.render_shaded(message, selected_item_color, background_color).blit(null, screen, rect);
		screen.flip();
	}
	void clear_status_message() {
		Rect rect = {10, 420, 790, 60};
		screen.fill(rect, background_color_rgb);
		screen.flip();
	}

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
			}
        }
    }
    void drain_events() {
		Event event = Event();
        while(Event.poll(event) == 1);
	}
    void on_keyboard_event (KeyboardEvent event) {
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
				case KeySymbol.c:
					do_configuration();
					drain_events();
					break;
				case KeySymbol.p:
					edit_current_platform();
					drain_events();
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

    void do_configuration() {
		show_status_message("running main configuration...");
		ConfigGui.run();
		font = new Font(preferences.font, FONT_SIZE);
		selector.update_colors();
		selector.update_font(font);
		redraw_screen();
	}
	void edit_current_platform() {
		if (current_platform != null) {
			show_status_message("editing platform %s...".printf(current_platform.name));
			ConfigGui.edit_platform(current_platform);
			clear_status_message();
		}
	}
	void edit_current_program() {
		if (current_platform != null) {
			var program = current_platform.default_program;
			if (program != null) {
				show_status_message("editing program %s...".printf(program.name));
				ConfigGui.edit_program(current_platform, program);
				clear_status_message();
			}
		}
	}

	void select_previous() {
		if (selector.select_previous())
			redraw_selector();
	}
	void select_previous_page() {
		if (selector.select_previous_by(10))
			redraw_selector();
	}
	void select_next() {
		if (selector.select_next())
			redraw_selector();
	}
	void select_next_page() {
		if (selector.select_next_by(10))
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

    void activate_selected() {
		if (selector.selected_index == -1)
			return;

		var platform_selector = selector as PlatformSelector;
		if (platform_selector != null) {
			current_platform = platform_selector.selected_platform();
			current_folder = current_platform.get_root_folder();
			selector = new GameFolderSelector(current_folder, this.screen.format, this.font, VISIBLE_WITDH, VISIBLE_ITEMS);
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
				selector = new GameFolderSelector(current_folder, this.screen.format, this.font, VISIBLE_WITDH, VISIBLE_ITEMS);
				selector.select_item(0);
				redraw_screen();
				return;
			}
			var game = item as GameItem;
			if (game != null) {
				show_status_message("running '%s'...".printf(item.unique_id()));
				game.run();
				clear_status_message();
			}
		}
	}

	void go_back() {
		var game_selector = selector as GameFolderSelector;
		if (game_selector != null) {
			if (current_folder.parent == null) {
				current_folder = null;
				selector = new PlatformSelector(this.screen.format, this.font, VISIBLE_WITDH, VISIBLE_ITEMS);
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
			selector = new GameFolderSelector(current_folder, this.screen.format, this.font, VISIBLE_WITDH, VISIBLE_ITEMS);
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

}
