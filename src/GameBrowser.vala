using SDL;
using SDLTTF;
using Data;
using Data.GameList;

public class GameBrowser
{
	unowned SDL.Screen screen;
	const string FONT_PATH = "/usr/share/fonts/truetype/ttf-dejavu/DejaVuSansMono.ttf";
	const int FONT_SIZE = 16;
    const int DELAY = 10;
    const int VISIBLE_WITDH = 440;
    const int VISIBLE_ITEMS = 15;
	Font font;
	bool done;

    Selector selector;
    Platform current_platform;
	GameFolder current_folder;

    public GameBrowser(SDL.Screen* screen) {
		this.screen = screen;
		font = new Font(FONT_PATH, FONT_SIZE);
		if (font == null)
			GLib.error("Error loading font: %s", SDL.get_error());
	}

	public void run() {
		initialize_from_browser_state();
		update_screen();
        while(done == false) {
            process_events();
            SDL.Timer.delay(DELAY);
        }
		update_browser_state();
	}

	void initialize_from_browser_state() {
		var state = Data.browser_state();
		current_platform = null;
		if (state.platform != null) {
			foreach(var platform in Data.platforms()) {
				if (platform.name == state.platform) {
					current_platform = platform;
					break;
				}
			}
		}
		if (current_platform == null) {
			current_folder = null;
			selector = new PlatformSelector(this.screen.format, this.font, VISIBLE_WITDH, VISIBLE_ITEMS);
		} else {
			current_folder = current_platform.get_folder(state.folder_id);
			if (current_folder == null)
				current_folder = current_platform.get_root_folder();
			selector = new GameFolderSelector(current_folder, this.screen.format, this.font, VISIBLE_WITDH, VISIBLE_ITEMS);
		}
		if (state.item_index > 0)
			selector.select_item(state.item_index);
		else
			selector.select_item(0);
	}
	void update_browser_state() {
		var state = Data.browser_state();
		state.platform = (current_platform != null) ? current_platform.name : null;
		state.folder_id = (current_folder != null) ? current_folder.unique_id() : null;
		state.item_index = selector.selected_index;
		Data.save_browser_state();
	}

	void update_screen() {
		selector.blit_to(screen, 100, 60);
		screen.flip();
    }
    void process_events() {
        Event event = Event ();
        while (Event.poll (event) == 1) {
            switch (event.type) {
            case EventType.QUIT:
                this.done = true;
                break;
            case EventType.KEYDOWN:
                this.on_keyboard_event (event.key);
                break;
            }
        }
    }
    void on_keyboard_event (KeyboardEvent event) {
		switch(event.keysym.sym) {
			case KeySymbol.c:
				ConfigGui.run();
				break;
			case KeySymbol.q:
				this.done = true;
				break;
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
				activate_selected();
				break;
			case KeySymbol.ESCAPE:
				if (current_platform == null) {
					this.done = true;
					return;
				}
				go_back();
				break;
			default:
				break;
		}
    }

	void select_previous() {
		if (selector.select_previous())
			update_screen();
	}
	void select_previous_page() {
		if (selector.select_previous_by(10))
			update_screen();
	}
	void select_next() {
		if (selector.select_next())
			update_screen();
	}
	void select_next_page() {
		if (selector.select_next_by(10))
			update_screen();
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
			update_screen();
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
				update_screen();
				return;
			}
			var game = item as GameItem;
			if (game != null) {
				debug("running game '%s'...", item.unique_id());
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
				update_screen();
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
			update_screen();
			return;
		}
	}

//~     private static bool is_alt_enter (Key key) {
//~         return ((key.mod & KeyModifier.LALT)!=0)
//~             && (key.sym == KeySymbol.RETURN
//~                     || key.sym == KeySymbol.KP_ENTER);
//~     }
}
