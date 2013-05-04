/* GameBrowser.vala
 * 
 * Copyright (C) 2012 nuhrin
 * 
 * This file is part of Pandafe.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *      nuhrin <nuhrin@oceanic.to>
 */

using SDL;
using SDLTTF;
using Catapult;
using Data;
using Data.GameList;
using Data.Platforms;
using Layers.Controls;
using Layers.GameBrowser;
using Menus;
using Menus.Fields;

public class GameBrowser : Layers.ScreenLayer, EventHandler
{
	const int16 SELECTOR_XPOS = 75;
	const string SELECTOR_ID = "selector";
	const string FILTER_LABEL = "filter: ";	
	
	GameBrowserUI ui;

	HeaderLayer header;
	StatusMessageLayer status_message;
	int16 selector_ypos;
    Selector selector;
    bool everything_active;
    bool platform_list_active;
    GameBrowserViewData? current_view_data;
    PlatformFolderData platform_folder_data;
    PlatformFolder? current_platform_folder;
    int current_platform_folder_index;
    Platform? current_platform;
    string current_filter;
	string? current_folder;

    public GameBrowser() {
		base("gamebrowser", @interface.game_browser_ui.background_color_rgb);
		ui = @interface.game_browser_ui;
		header = add_layer(new HeaderLayer("header")) as HeaderLayer;
		status_message = add_layer(new StatusMessageLayer("status-message")) as StatusMessageLayer;
		update_selector_ypos();
	}

	public void run() {
		platform_folder_data = Data.platforms().get_platform_folder_data();
		
		ui.colors_updated.connect(update_colors);
		ui.font_updated.connect(update_font);
		var pp = Data.platforms();
		pp.platform_rescanned.connect((p) => platform_rescanned(p));
		pp.platform_folders_changed.connect(() => platform_folders_changed());
		pp.platform_folder_scanned.connect((f) => game_folder_scanned(f));
		var mountset = Data.pnd_mountset();
		mountset.pnd_mounting.connect((name) => {if (@interface.peek_layer() == null) status_message.right = "Mounting '%s'...".printf(name);});
		mountset.pnd_mounted.connect((name) => {if (@interface.peek_layer() == null) status_message.right = "";});
		mountset.pnd_unmounting.connect((name) => {if (@interface.peek_layer() == null) status_message.right = "Unmounting '%s'...".printf(name);});

		@interface.push_screen_layer(this, false);
		initialize_from_browser_state();
		Key.enable_unicode(1);
        
        process_events();
        
		update_browser_state();
		Data.save_browser_state();
		if (Data.pnd_mountset().has_mounted == true) {
			status_message.set("Unmounting PNDs...");
			Data.pnd_mountset().unmount_all();
		}
		@interface.pop_screen_layer();
	}
	
	Enumerable<Platform> get_current_platforms() {
		if (current_platform != null && platform_list_active == false)
			return new Enumerable<PlatformNode>(current_platform_folder.platforms).select<Platform>(n=>n.platform);
		return Data.platforms().get_all_platforms();
	}
	void update_colors() {
		header.set_rgb_color(ui.background_color_rgb);
		status_message.set_rgb_color(ui.background_color_rgb);
		this.set_rgb_color(ui.background_color_rgb);
	}
	void update_font() {
		clear();
		header = new HeaderLayer("header");
		replace_layer(header.id, header);
		set_header();
		status_message = new StatusMessageLayer("status-message");
		replace_layer(status_message.id, status_message);
		update_selector_ypos();
	}
	void update_selector_ypos() {		
		selector_ypos = header.ypos + (int16)header.height + (int16)(ui.font_height * 1.5);
		if (selector != null)
			selector.ypos = selector_ypos;
	}
	
	//
	// browser state
	void initialize_from_browser_state() {
		var state = Data.browser_state();
		current_view_data = null;
		current_platform_folder = null;
		current_platform = null;
		if (state.current_platform_folder != null) {
			if (state.current_platform_folder == "(list)")
				platform_list_active = true;
			else
				current_platform_folder = platform_folder_data.get_folder(state.current_platform_folder);
		}
		current_platform_folder_index = state.platform_folder_item_index;
		if (state.current_platform != null) {
			foreach(var platform in get_current_platforms()) {
				if (platform.id == state.current_platform) {
					current_platform = platform;
					break;
				}
			}
		}
		if (apply_all_games_state() == false)
			apply_platform_state();
	}
	bool apply_all_games_state(bool active=false) {
		var all_games = Data.browser_state().all_games;
		if (all_games  == null)
			return false;
			
		current_view_data = all_games.get_view();

		if (active == true || all_games.active == true) {
			everything_active = true;
			change_selector();
			
			if (all_games.filter != null)
				selector.filter(all_games.filter);
			int index = 0;
			if (all_games.item_index > 0)
				index = all_games.item_index;
			if (selector.select_item(index) == false)
				selector.ensure_selection();		
			return true;
		}
		return false;
	}
	void apply_platform_state() {
		var state = Data.browser_state();
		if (current_platform == null) {
			current_folder = null;			
		} else {
			current_folder = current_platform.get_nearest_folder_path(state.get_current_platform_folder_id() ?? "");			
		}
		change_selector();
		int item_index = -1;
		if (selector is PlatformFolderSelector || selector is PlatformSelector) {
			item_index = state.platform_folder_item_index;
		} else {
			var filter = state.get_current_platform_filter();
			if (filter != null)
				selector.filter(filter);
			item_index = state.get_current_platform_item_index();
		}
		if (item_index >= selector.item_count)
			item_index = selector.item_count - 1;
		if (item_index < 0)
			item_index = 0;
		if (selector.select_item(item_index) == false)
			selector.ensure_selection();
	}
	void update_browser_state() {
		var state = Data.browser_state();
		state.platform_folder_item_index = current_platform_folder_index;		
		state.current_platform_folder = (current_platform_folder != null) ? current_platform_folder.path() : null;
		state.current_platform = (current_platform != null) ? current_platform.id : null;
		if (platform_list_active)
			state.current_platform_folder = "(list)";
		if (current_platform != null)
			state.apply_platform_state(current_platform, current_folder, selector.selected_index, selector.get_filter_pattern());
		if (everything_active == true)
			state.apply_all_games_state(everything_active, selector.selected_index, selector.get_filter_pattern(), current_view_data);
		else
			state.apply_all_games_state(false, 0, null, null);
	}
	
	//
	// layer updates
	void set_header(bool flip=false) {
		string left = null;
		string center = null;
		string right = null;
		if (everything_active == true) {
			var everything_selector = selector as EverythingSelector;
			if (everything_selector != null) {
				left = everything_selector.view_name;
				var game = everything_selector.selected_game();
				if (game != null) {
					center = game.platform.name;
					if (game.parent.parent != null)
						right = game.parent.display_name().strip();
				}
			}
		}
		else if (current_platform != null) {
			left = current_platform.name;
			right = current_platform.get_folder_display_path(current_folder);
		} else {
			left = "Platforms";
			if (current_platform_folder != null)
				right = current_platform_folder.path();
		}
		header.set_text(left, center, right, flip);
	}
	void change_selector() {
		clear();
		set_header(true);
		Selector new_selector = null;
		if (selector != null) {
			foreach(var handler in selector_handlers)
				selector.disconnect(handler);
			selector_handlers.clear();
		}
		if (this.everything_active == true) {
			on_selector_loading();
			var everything_selector = selector as EverythingSelector;			
			if (everything_selector == null)
				everything_selector = new EverythingSelector(SELECTOR_ID, SELECTOR_XPOS, selector_ypos, current_view_data);
			new_selector = everything_selector;
		} else {
			if (this.current_folder != null) {
				on_selector_loading();
				var folder = current_platform.get_folder(current_folder);
				if (folder == null)
					folder = current_platform.get_root_folder();
				new_selector = new GameFolderSelector(folder, SELECTOR_ID, SELECTOR_XPOS, selector_ypos);				
			} else if (this.current_platform_folder != null) {
				new_selector = new PlatformFolderSelector(this.current_platform_folder, SELECTOR_ID, SELECTOR_XPOS, selector_ypos);
			} else if (platform_list_active == false && this.platform_folder_data.folders.size > 0) {
				new_selector = new PlatformFolderSelector.root(SELECTOR_ID, SELECTOR_XPOS, selector_ypos);
			} else {
				new_selector = new PlatformSelector(SELECTOR_ID, SELECTOR_XPOS, selector_ypos);
			}			
		}
		selector_handlers.add(new_selector.changed.connect(() => on_selector_changed()));
		selector_handlers.add(new_selector.loading.connect(() => on_selector_loading()));
		selector_handlers.add(new_selector.rebuilt.connect(() => on_selector_rebuilt(new_selector)));
		if (this.selector == null)
			add_layer(new_selector);
		else
			replace_layer(SELECTOR_ID, new_selector);
			
		this.selector = new_selector;
	}
	Gee.ArrayList<ulong> selector_handlers = new Gee.ArrayList<ulong>();
	
	void on_selector_changed() {
		if (selector is PlatformFolderSelector)
			current_platform_folder_index = selector.selected_index;
		if (everything_active == true)
			set_header();
		set_status(false);
	}
	void set_status(bool flip=true) {
		string center = "%d / %d".printf(selector.selected_display_index() + 1, selector.display_item_count);
		string? right = null;
		string? active_pattern = selector.get_filter_pattern();
		if (active_pattern != null)
			right = "%s\"%s\"".printf(FILTER_LABEL, active_pattern);
		status_message.set(null, center, right, flip);
	}
	void on_selector_loading() {
		if (@interface.peek_layer() != null)
			return; // another layer has focus, don't bother reporting load
		status_message.set("Loading list...");
	}
	void on_selector_rebuilt(Selector selector) {
		if (this.selector != selector)
			return;
		set_header();
		selector.ensure_selection(false);
		update();
	}
	void game_folder_scanned(GameFolder folder) {
		if (@interface.peek_layer() != null)
			return; // another layer has focus, don't bother reporting scan
		status_message.set("Scanning", folder.platform.name, folder.unique_name());
	}
	void platform_folders_changed() {
		if (current_platform_folder == null) {
			if (current_platform == null) {
				// at root selector
				if (platform_folder_data.folders.size > 0) {
					// ensure PlatformFolderSelector
					if (selector is PlatformFolderSelector)
						selector.rebuild();
					else {
						var ps = selector as PlatformSelector;
						if (ps != null) {
							var platform = ps.selected_platform();
							change_selector();
							var pfs = selector as PlatformFolderSelector;
							if (pfs != null && platform != null)
								pfs.select_platform(platform);							
							selector.ensure_selection();
						} else {
							change_selector();
							selector.select_first();
						}
					}
				} else {
					// ensure PlatformSelector
					var pfs = selector as PlatformFolderSelector;
					if (pfs != null) {
						var platform = pfs.selected_platform();
						change_selector();
						var ps = selector as PlatformSelector;
						if (ps != null && platform != null)
							ps.select_platform(platform);
						selector.ensure_selection();
					} else if (selector is PlatformSelector) {
						selector.rebuild();
					} else {
						change_selector();
						selector.select_first();
					}
				}
			} else {
				if (platform_folder_data.folders.size > 0) {
					// freshly populated platform folder data. look for platform folder with the current platform
					var folder_with_platform = platform_folder_data.get_folder_with_platform(current_platform);
					if (folder_with_platform != null) {
						current_platform_folder = folder_with_platform;
						current_platform_folder_index = current_platform_folder.folders.size + current_platform_folder.index_of_platform(current_platform);
					}
				}
			}
			return;
		}			
		
		var existing_platform_folder = current_platform_folder;
		current_platform_folder = platform_folder_data.get_folder(existing_platform_folder.path());
		if (current_platform != null) {
			// does platform folder still have current platform?
			int found_platform_index = -1;
			if (current_platform_folder != null)
				found_platform_index = current_platform_folder.index_of_platform(current_platform);			
			if (found_platform_index != -1) {
				// yes
				current_platform_folder_index = current_platform_folder.folders.size + found_platform_index;
			} else {
				// no
				var folder_with_platform = platform_folder_data.get_folder_with_platform(current_platform);
				if (folder_with_platform != null) {
					// different folder has platform. change current platform folder to match
					current_platform_folder = folder_with_platform;
					current_platform_folder_index = current_platform_folder.folders.size + current_platform_folder.index_of_platform(current_platform);
				} else {
					// no platform folder has the current platform. bail on the platform selector
					current_platform_folder_index = 0;
					current_platform = null;
					current_folder = null;
					change_selector();
					selector.ensure_selection();
				}
			}			
		} else {
			if (current_platform_folder == existing_platform_folder && selector is PlatformFolderSelector) {
				selector.rebuild();				
			} else {
				change_selector();
				selector.ensure_selection();
			}			
		}
	}
	void platform_rescanned(Platform platform) {
		if (everything_active) {
			return; // handled by AllGames.cache_updated() signal
		}
		
		if (current_platform != null && current_platform == platform && current_folder != null) {
			current_folder = current_platform.get_nearest_folder_path(current_folder);
			GameFolderSelector gfs = selector as GameFolderSelector;
			if (gfs != null) {
				var new_folder = current_platform.get_folder(current_folder);
				if (new_folder == null)
					new_folder = current_platform.get_root_folder();
				gfs.folder = new_folder;
			} else {
				change_selector();
				selector.select_first();
			}			
		} else if (current_platform_folder != null) {
			foreach(var platform_node in current_platform_folder.platforms) {
				if (platform_node.platform == platform) {
					int index = selector.selected_index;
					selector.rebuild();
					selector.select_item(index);
					break;
				}				
			}
		}		
	}
		
	//
	// events
    void on_keydown_event (KeyboardEvent event) {
		if (process_unicode(event.keysym.unicode) == false)
			return;

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
				case KeySymbol.END: // pandora B
					activate_selected();
					drain_events();
					break;
				case KeySymbol.HOME: // pandora A
					go_back();
					drain_events();
					break;
				case KeySymbol.PAGEUP: // pandora Y
					select_first();
					break;
				case KeySymbol.PAGEDOWN: // pandora X
					select_last();
					break;
				case KeySymbol.COMMA:
				case KeySymbol.SLASH:
					filter_selector();
					break;
				case KeySymbol.LCTRL: // pandora Select
				case KeySymbol.PERIOD:
					show_main_menu();					
					break;
				case KeySymbol.SPACE:
					show_context_menu();
					break;
				case KeySymbol.RSHIFT: // pandora L
					show_change_view_overlay();
					break;
				case KeySymbol.RCTRL: // pandora R
					show_change_platform_overlay();
					break;
				case KeySymbol.ESCAPE:
					do_quit();
					break;
				default:
					break;
			}
			return;
		}
    }
    void handle_pandora_keyup_event() {
		var current_overlay = @interface.peek_layer() as MenuOverlay;
		if (current_overlay != null && current_overlay.current_menu is Menus.Concrete.ExitMenu)
			return; // already showing the exit menu
			
		@interface.pandora_keyup_event_handled = true;
		new MenuOverlay(new Menus.Concrete.ExitMenu(), null).run(200);
		var current_layer = @interface.peek_layer();
		if (current_layer != null)
			current_layer.update();
		@interface.pandora_keyup_event_handled = false;
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
	}
	void select_previous_page() {
		selector.select_previous_page();
	}
	void select_next() {
		selector.select_next();
	}
	void select_next_page() {
		selector.select_next_page();
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
		if (selector.selected_index == -1)
			return;

		if (everything_active == true) {
			var game = (selector as EverythingSelector).selected_game();
			if (game != null)
				run_game(game);
			return;
		}

		var platform_folder_selector = selector as PlatformFolderSelector;
		if (platform_folder_selector != null) {
			var node = platform_folder_selector.selected_node();
			var folder_node = node as PlatformFolder;
			if (folder_node != null) {
				current_platform_folder = folder_node;
				change_selector();
				selector.ensure_selection();
				return;
			}
			var platform_node = node as PlatformNode;
			if (platform_node != null) {
				if (ensure_platform_root_rolder(platform_node.platform) == false)
					return;
				current_platform = platform_node.platform;
				current_folder = "";
				change_selector();
				var state = Data.browser_state();
				state.current_platform = current_platform.id;
				current_filter = state.get_current_platform_filter();
				if (current_filter != null)
					selector.filter(current_filter);
				selector.ensure_selection();
				return;
			}
		}

		var platform_selector = selector as PlatformSelector;
		if (platform_selector != null) {
			var selected_platform = platform_selector.selected_platform();
			if (ensure_platform_root_rolder(selected_platform) == false)
				return;
			current_platform = selected_platform;
			current_folder = "";
			change_selector();
			var state = Data.browser_state();
			state.current_platform = current_platform.id;
			current_filter = state.get_current_platform_filter();
			if (current_filter != null)
				selector.filter(current_filter);
			selector.ensure_selection();
			return;
		}

		var game_selector = selector as GameFolderSelector;
		if (game_selector != null) {
			var item = game_selector.selected_item();
			var folder = item as GameFolder;
			if (folder != null) {
				current_folder = folder.unique_name();
				change_selector();
				if (current_filter != null)
					selector.filter(current_filter);
				selector.ensure_selection();
				return;
			}
			var game = item as GameItem;
			if (game != null)
				run_game(game);							
		}
	}
	
	bool ensure_platform_root_rolder(Platform platform) {
		var rom_platform = platform as RomPlatform;
		if (rom_platform == null)
			return true;
			
		var rom_folder_root = rom_platform.rom_folder_root;
		if (rom_folder_root == null || rom_folder_root.strip() == "" || FileUtils.test(rom_folder_root, FileTest.IS_DIR) == false) {
			var chooser = new FolderChooser("rom_folder_chooser", "Choose %s Rom Folder".printf(platform.name));
			var new_root = chooser.run(Data.preferences().default_rom_path);
			if (new_root == null)
				return false;
			rom_platform.rom_folder_root = new_root;
			string? error;
			if (Data.platforms().save_platform(platform, platform.id, out error, f=> status_message.set("Scanning", platform.name, f.unique_name())) == false) {
				status_message.set(error);
				return false;
			}
			status_message.clear();
		}		
		return true;
	}
	
	void run_game(GameItem game) {
		status_message.set("running '%s'...".printf(game.unique_name()));				
		
		var program = game.get_program();
		bool show_output = (program != null && program.default_settings.show_output == true);
		
		var result = game.run();
		set_status();
		
		var successful = (result.success == true || (result.exit_status != 0 && program != null && program.expected_exit_code == result.exit_status));
		if (successful == true)
			Data.increment_game_run_count(game);
		
		if (successful == false || show_output == true) {
			if (result.error_message != null && status_message.text_will_fit("Error: " + result.error_message)) {
				status_message.set("Error: " + result.error_message);
			} else {
				string program_name = (program != null) ? program.name : "program";
				string primary_message = (successful == false)
					? "Error running " + program_name
					: program_name + " Output";
				result.show_result_dialog(primary_message, 
					"\t<i>%s</i>".printf(game.unique_name()));				
			}
		}
		
		if (everything_active)
			(selector as EverythingSelector).game_run_completed();		
	}

	void go_back() {
		var platform_folder_selector = selector as PlatformFolderSelector;
		if (platform_folder_selector != null) {
			if (current_platform_folder == null)
				return;
			var current_name = current_platform_folder.name;
			current_platform_folder = current_platform_folder.parent;
			var folders = (current_platform_folder != null)
				? current_platform_folder.folders
				: platform_folder_data.folders;
			int index=0;
			foreach(var folder in folders) {
				if (folder.name == current_name)
					break;
				index++;
			}
			change_selector();
			selector.select_item(index);
			return;
		}
		var game_selector = selector as GameFolderSelector;
		if (game_selector != null) {
			if (game_selector.folder.parent == null) {
				Data.browser_state().apply_platform_state(current_platform, current_folder,
					selector.selected_index, selector.get_filter_pattern());
				current_folder = null;
				current_filter = null;
				var platform = current_platform;
				current_platform = null;
				change_selector();
				var platform_selector = selector as PlatformSelector;
				if (platform_selector != null)
					platform_selector.select_platform(platform);
				else
					selector.select_item_starting_with(platform.name);
				return;
			}
			var previous_folder = current_folder;
			current_folder = game_selector.folder.parent.unique_name();
			change_selector();
			int index=0;
			foreach(var subfolder in (selector as GameFolderSelector).folder.child_folders()) {
				if (subfolder.unique_name() == previous_folder)
					break;
				index++;
			}
			if (current_filter != null)
				selector.filter(current_filter);
			selector.select_item(index);			
			return;
		}
	}

	void filter_selector() {
		status_message.set();
		
		var font_height = @interface.get_monospaced_font_height();
		if (ui.font_height > font_height)
			font_height = ui.font_height;			
		int16 entry_ypos = (int16)(@interface.screen_height - font_height - 10);
		
		var label = @interface.game_browser_ui.render_text_selected(FILTER_LABEL);
		Rect label_rect = {600 - (int16)label.w, entry_ypos+5};
		blit_surface(label, null, label_rect);
		
		var existing_filter = selector.get_filter_pattern();
		
		var entry = new TextEntry("selection_filter", 600, entry_ypos, 200, selector.get_filter_pattern());
		var new_pattern = entry.run();
		if (new_pattern == null || new_pattern.strip() == "")
			new_pattern = null;
		
		if (new_pattern == existing_filter)
			return;		
		current_filter = new_pattern;
		
		if (current_filter != null)
			selector.filter(current_filter);
		else
			selector.clear_filter();		
	}

	void do_quit() {
		if (MainClass.was_run_as_gui == true) {
			show_menu_overlay(new Menus.Concrete.ExitMenu());
		} else {
			quit_event_loop();
		}		
	}

	//
	// commands: choosers
	void show_change_view_overlay() {
		var cancel_key_pressed = choose_view();
		if (cancel_key_pressed == KeySymbol.RCTRL) // pandora R
			show_change_platform_overlay();
		else if (cancel_key_pressed == KeySymbol.SPACE)
			show_context_menu();
		else if (cancel_key_pressed == KeySymbol.LCTRL) // pandora Select
			show_main_menu();
		else
			flip();
	}
	KeySymbol? choose_view() {
		Platform? active_platform = current_platform;
		var active_folder = current_folder;
		int active_folder_item_index = 0;
		if (everything_active == true) {
			var selected_game = (selector as EverythingSelector).selected_game();
			if (selected_game != null) {
				active_platform = selected_game.platform;
				active_folder = selected_game.parent.unique_name();
				active_folder_item_index = selected_game.parent.index_of(selected_game);
			}
		}
		GameItem? selected_game = null;
		var game_selector = selector as GameFolderSelector;
		if (game_selector != null)
			selected_game = game_selector.selected_item() as GameItem;
		
		var resolved_view_data = current_view_data;		
		if (everything_active == false) {
			if (active_platform != null) {
				resolved_view_data = new GameBrowserViewData(GameBrowserViewType.PLATFORM);
			} else {
				var pfs = selector as PlatformFolderSelector;
				if (pfs != null) {
					var platform_node = pfs.selected_node() as PlatformNode;
					if (platform_node != null)
						active_platform = platform_node.platform;
					resolved_view_data = new GameBrowserViewData(GameBrowserViewType.PLATFORM_FOLDER);				
				} else {
					var ps = selector as PlatformSelector;
					if (ps != null)
						active_platform = ps.selected_platform();
					resolved_view_data = new GameBrowserViewData(GameBrowserViewType.PLATFORM_LIST);
				}
			}
		}
		
		var change_view_menu = new Menus.Concrete.ChangeViewMenu(resolved_view_data, active_platform);
		var overlay = new Layers.GameBrowser.MenuOverlay(change_view_menu, KeySymbol.SPACE);
		overlay.add_cancel_key(KeySymbol.RCTRL); // pandora R
		overlay.add_cancel_key(KeySymbol.LCTRL); // pandora Select
		var cancel_key_pressed = overlay.run();
		if (cancel_key_pressed != null)
			return cancel_key_pressed;			
		var new_view = change_view_menu.selected_view;
		if (new_view == null || new_view == resolved_view_data || new_view.equals(resolved_view_data) == true)
			return null;
		
		if (new_view.involves_everything == false) {
			everything_active = false;
			if (new_view.view_type == GameBrowserViewType.PLATFORM) {
				if (active_platform == null)
					return null;
				if (active_folder == null && active_platform != null)
					active_folder = "";
				
				if (current_platform != null && current_folder != null) {
					Data.browser_state().apply_platform_state(current_platform, current_folder,
						selector.selected_index, selector.get_filter_pattern());
				}
				
				current_platform_folder = null;
				current_platform_folder_index = 0;
				if (platform_folder_data.folders.size > 0 && platform_list_active == false) {					
					current_platform_folder = platform_folder_data.get_folder_with_platform(active_platform);
					if (current_platform_folder != null) {
						int found_platform_index = current_platform_folder.index_of_platform(active_platform);			
						if (found_platform_index != -1)				
							current_platform_folder_index = current_platform_folder.folders.size + found_platform_index;
					} else if (active_platform.platform_type == PlatformType.NATIVE) {
						current_platform_folder_index = platform_folder_data.folders.size;
					}			
				} else {
					var platforms = Data.platforms().get_all_platforms().to_list();
					for(int index=0;index<platforms.size;index++) {
						if (platforms[index] == active_platform) {
							current_platform_folder_index = index;
							break;
						}
					}
				}
				
				current_platform = active_platform;
				current_folder = active_folder;
				Data.browser_state().current_platform = current_platform.id;
				if (current_folder != null)
					Data.browser_state().apply_platform_state(current_platform, current_folder, active_folder_item_index, null);
				
				apply_platform_state();
				selector.update();
			}					
			else if (new_view.view_type == GameBrowserViewType.PLATFORM_LIST) {
				platform_list_active = true;
				current_platform_folder = null;
				current_platform_folder_index = 0;
				if (active_platform != null) {
					var platforms = Data.platforms().get_all_platforms().to_list();
					for(int index=0;index<platforms.size;index++) {
						if (platforms[index] == active_platform) {
							current_platform_folder_index = index;
							break;
						}
					}
				}
				current_platform = null;
				current_folder = null;
				change_selector();
				if (selector.select_item(current_platform_folder_index) == false)
					selector.ensure_selection();
			}
			else if (new_view.view_type == GameBrowserViewType.PLATFORM_FOLDER) {
				platform_list_active = false;
				current_platform_folder = null;
				current_platform_folder_index = 0;
				if (active_platform != null) {
					if (platform_folder_data.folders.size > 0) {
						current_platform_folder = platform_folder_data.get_folder_with_platform(active_platform);
						if (current_platform_folder != null) {
							int found_platform_index = current_platform_folder.index_of_platform(active_platform);
							if (found_platform_index != -1)				
								current_platform_folder_index = current_platform_folder.folders.size + found_platform_index;
						} else if (active_platform.platform_type == PlatformType.NATIVE) {
							current_platform_folder_index = platform_folder_data.folders.size;
						}
					}
				}
				current_platform = null;
				current_folder = null;
				change_selector();
				if (selector.select_item(current_platform_folder_index) == false)
					selector.ensure_selection();
			}
			return null;
		}		
		
		current_folder = null;
		current_platform = null;
		current_platform_folder = null;
		current_platform_folder_index = 0;
		
		if (everything_active == false) {
			Data.browser_state().apply_all_games_state(true, 0, null, new_view);
			apply_all_games_state();
			if (selected_game != null)
				(selector as EverythingSelector).select_game(selected_game);
		} else {
			if (everything_active == false) {
				everything_active = true;
				change_selector();
				selector.update();				
				if (selected_game != null)
					(selector as EverythingSelector).select_game(selected_game);
			}
			current_view_data = new_view;
			(selector as EverythingSelector).change_view(current_view_data);
		}
		return null;
	}
	void show_change_platform_overlay() {
		var cancel_key_pressed = choose_platform();
		if (cancel_key_pressed == KeySymbol.RSHIFT) // pandora L
			show_change_view_overlay();
		else if (cancel_key_pressed == KeySymbol.SPACE)
			show_context_menu();
		else if (cancel_key_pressed == KeySymbol.LCTRL) // pandora Select
			show_main_menu();
		else
			flip();
	}
	KeySymbol? choose_platform() {
		var active_platform = current_platform;
		var active_folder = current_folder;
		int active_folder_item_index = 0;
		if (everything_active == true) {
			var selected_game = (selector as EverythingSelector).selected_game();
			if (selected_game != null) {
				active_platform = selected_game.platform;
				active_folder = selected_game.parent.unique_name();
				active_folder_item_index = selected_game.parent.index_of(selected_game);
			}
		}
						
		var platform_overlay = new PlatformSelectorOverlay(active_platform);
		platform_overlay.add_cancel_key(KeySymbol.RSHIFT); // pandora L
		platform_overlay.add_cancel_key(KeySymbol.LCTRL); // pandora Select
		platform_overlay.add_cancel_key(KeySymbol.SPACE);
		platform_overlay.run();
		if (platform_overlay.was_canceled)
			return platform_overlay.cancel_key_pressed();
		
		var new_platform = platform_overlay.selected_item();
		if (new_platform == null || (ensure_platform_root_rolder(new_platform) == false ) || (new_platform == active_platform && everything_active == false))
			return null;
		
		everything_active = false;		
		
		if (current_platform != null && current_folder != null) {
			Data.browser_state().apply_platform_state(current_platform, current_folder,
				selector.selected_index, selector.get_filter_pattern());
		}
				
		current_platform_folder = null;
		current_platform_folder_index = 0;
		if (platform_folder_data.folders.size > 0) {
			current_platform_folder = platform_folder_data.get_folder_with_platform(new_platform);
			if (current_platform_folder != null) {
				int found_platform_index = current_platform_folder.index_of_platform(new_platform);			
				if (found_platform_index != -1)				
					current_platform_folder_index = current_platform_folder.folders.size + found_platform_index;
			} 
		}
		
		current_platform = new_platform;
		Data.browser_state().current_platform = current_platform.id;
		if (new_platform == active_platform)
			Data.browser_state().apply_platform_state(current_platform, active_folder, active_folder_item_index, null);		
 		apply_platform_state();
 		selector.update();
 		return null;
	}


	//
	// commands: menus
    void show_main_menu() {
		var overlay = new Layers.GameBrowser.MenuOverlay(new Menus.Concrete.MainMenu());
		overlay.add_cancel_key(KeySymbol.RSHIFT); // pandora L
		overlay.add_cancel_key(KeySymbol.RCTRL); // pandora R
		overlay.add_cancel_key(KeySymbol.SPACE);
		var cancel_key_pressed = overlay.run();
		if (cancel_key_pressed == KeySymbol.RSHIFT)
			show_change_view_overlay();
		else if (cancel_key_pressed == KeySymbol.RCTRL)
			show_change_platform_overlay();
		else if (cancel_key_pressed == KeySymbol.SPACE)
			show_context_menu();
		else
			flip();
	}
	
	void show_context_menu() {
		//Menus.Concrete.MainConfiguration.run();
		if (selector.selected_index == -1) {
			if (current_platform != null)
				show_platform_menu(current_platform);			
			return;
		}

		if (everything_active == true) {
			show_game_menu((selector as EverythingSelector).selected_game());
			return;
		}		
		
		var platform_folder_selector = selector as PlatformFolderSelector;
		if (platform_folder_selector != null) {
			var node = platform_folder_selector.selected_node();
			var folder_node = node as PlatformFolder;
			if (folder_node != null) {
				show_menu_overlay(new Menus.Concrete.PlatformFolderMenu(folder_node));
				return;
			}
			var platform_node = node as PlatformNode;
			if (platform_node != null) {
				show_platform_menu(platform_node.platform, platform_folder_selector.folder);
			}
			return;
		}
		
		var platform_selector = selector as PlatformSelector;
		if (platform_selector != null) {
			show_platform_menu(platform_selector.selected_platform());
			return;
		}
		
		var game_selector = selector as GameFolderSelector;
		if (game_selector != null) {
			var item = game_selector.selected_item();
			if (item == null && current_platform != null) {
				show_platform_menu(current_platform);
				return;
			}
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
	void show_platform_menu(Platform? platform, PlatformFolder? platform_folder=null) {
		if (platform != null)
			show_menu_overlay(new Menus.Concrete.PlatformMenu(platform, null, platform_folder));
		
	}
	void show_menu_overlay(Menus.Menu menu) {		
		var overlay = new Layers.GameBrowser.MenuOverlay(menu);
		overlay.add_cancel_key(KeySymbol.RSHIFT); // pandora L
		overlay.add_cancel_key(KeySymbol.RCTRL); // pandora R
		overlay.add_cancel_key(KeySymbol.LCTRL); // pandora Select
		var cancel_key_pressed = overlay.run();
		if (cancel_key_pressed == KeySymbol.RSHIFT)
			show_change_view_overlay();
		else if (cancel_key_pressed == KeySymbol.RCTRL)
			show_change_platform_overlay();
		else if (cancel_key_pressed == KeySymbol.LCTRL)
			show_main_menu();
		else
			flip();
	}	
}
