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
	const string SELECTOR_ID = "selector";
	const string FILTER_LABEL = "filter: ";	
	
	GameBrowserUI ui;

	HeaderLayer header;
	StatusMessageLayer status_message;
	string? static_header_text;
	string? static_status_test;
	int16 selector_xpos;
	int16 selector_ypos;
	int16 selector_ymax;
    Selector selector;
    bool everything_active;
    bool platform_list_active;
    GameBrowserViewData? current_view_data;
    PlatformFolderData platform_folder_data;
    PlatformFolder? current_platform_folder;
    int current_platform_folder_index;
    Platform? current_platform;
    string? current_folder;
    bool category_active;
    string? current_category;

    public GameBrowser() {
		base("gamebrowser", @interface.game_browser_ui.background_color_rgb);
		ui = @interface.game_browser_ui;
		header = add_layer(new HeaderLayer("header")) as HeaderLayer;
		status_message = add_layer(new StatusMessageLayer("status-message")) as StatusMessageLayer;
		update_selector_ypos();
	}

	public void run() {
		platform_folder_data = Data.platforms().get_platform_folder_data();
		
		var pp = Data.platforms();
		pp.platform_rescanned.connect((platform, new_selection_id) => platform_rescanned(platform, new_selection_id));
		pp.platform_folders_changed.connect(() => platform_folders_changed());
		pp.platform_folder_scanned.connect((f) => game_folder_scanned(f));
		var mountset = Data.pnd_mountset();
		mountset.app_mounting.connect((mount_id) => {if (@interface.peek_layer() == null) status_message.right = "Mounting '%s'...".printf(mount_id);});
		mountset.app_mounted.connect((mount_id) => {if (@interface.peek_layer() == null) status_message.right = "";});
		mountset.app_unmounting.connect((mount_id) => {if (@interface.peek_layer() == null) status_message.right = "Unmounting '%s'...".printf(mount_id);});

		@interface.push_screen_layer(this, false);
		initialize_from_browser_state();
		Key.enable_unicode(1);

		ui.colors_updated.connect(update_colors);
		ui.header.font_updated.connect(update_font);
		ui.list.font_updated.connect(update_font);
		ui.footer.font_updated.connect(update_font);
		ui.appearance_updated.connect(() => {
			update_colors();
			update_font();
		});
        
        process_events();
        
		update_browser_state();
		Data.save_browser_state();
		if (Data.pnd_mountset().has_mounted == true) {
			status_message.set("Unmounting PNDs...");
			Data.pnd_mountset().unmount_all();
		}
		foreach(var handler in selector_handlers)
			selector.disconnect(handler);

		@interface.pop_screen_layer();		
	}
	
	Enumerable<Platform> get_current_platforms() {
		if (current_platform != null && platform_list_active == false)
			return new Enumerable<PlatformNode>(current_platform_folder.platforms).select<Platform>(n=>n.platform);
		return Data.platforms().get_all_platforms();
	}
	void update_colors() {
		this.set_rgb_color(ui.background_color_rgb);
		header.set_rgb_color(ui.background_color_rgb);
		status_message.set_rgb_color(ui.background_color_rgb);
		update(false);
	}
	void update_font() {
		clear();
		header = new HeaderLayer("header");
		replace_layer(header.id, header);
		set_header();
		status_message = new StatusMessageLayer("status-message");
		replace_layer(status_message.id, status_message);
		update_selector_ypos();
		update(false);
	}
	void update_selector_ypos() {
		selector_xpos = ui.list.spacing.left + 20;
		selector_ypos = header.ypos + (int16)header.height + ui.list.spacing.top;
		selector_ymax = status_message.ypos - ui.list.spacing.bottom;
		if (selector != null) { 
			selector.xpos = selector_xpos;
			selector.ypos = selector_ypos;
			selector.ymax = selector_ymax;
		}
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
		if (apply_all_games_state() == false && apply_category_state() == false)
			apply_platform_state();
	}
	bool apply_category_state(bool active=false) {
		var category_state = Data.browser_state().category_state;
		if (category_state == null)
			return false;
		
		if (active == true || category_state.active == true) {
			current_view_data = category_state.get_view();
			category_active = true;
			current_category = category_state.category_path;
			change_selector();
			
			int index = 0;
			if (category_state.item_index > 0)
				index = category_state.item_index;
			if (selector.select_item(index) == false)
				selector.ensure_selection();		
			if (category_state.filter != null)
				selector.filter(category_state.filter);
			return true;
		}
		return false;
	}
	bool apply_all_games_state(bool active=false) {
		var all_games = Data.browser_state().all_games;
		if (all_games  == null)
			return false;
			
		current_view_data = all_games.get_view();

		if (active == true || all_games.active == true) {
			everything_active = true;
			change_selector();
			
			int index = 0;
			if (all_games.item_index > 0)
				index = all_games.item_index;
			if (selector.select_item(index) == false)
				selector.ensure_selection();		
			if (all_games.filter != null)
				selector.filter(all_games.filter);
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
		string? filter = null;
		int item_index = -1;
		if (selector is PlatformFolderSelector || selector is PlatformSelector) {
			item_index = state.platform_folder_item_index;
		} else {
			filter = state.get_current_platform_filter();
			item_index = state.get_current_platform_item_index();
		}
		if (item_index >= selector.item_count)
			item_index = selector.item_count - 1;
		if (item_index < 0)
			item_index = 0;
		if (selector.select_item(item_index) == false)
			selector.ensure_selection();
		if (filter != null)
			selector.filter(filter);			
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
			state.all_games.active = false;
		if (category_active == true)
			state.apply_category_state(category_active, current_category, selector.selected_index, selector.get_filter_pattern());
		else
			state.category_state.active = false;
	}
	
	//
	// layer updates
	void set_header(bool flip=false) {
		if (static_header_text != null) {
			header.set_text(static_header_text, null, null, flip);
			return;
		}
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
					right = game.parent.unique_display_name().strip();
				}
			}
		} else if (category_active == true) {
			var category_selector = selector as GameCategorySelector;
			if (category_selector != null) {
				left = category_selector.active_category_path ?? "Categories";
				var game = category_selector.selected_game();
				if (game != null)
					right = game.platform.name;				
			}			
		} else if (current_platform != null) {
			left = current_platform.name;
			var gps = selector as GamePlatformSelector;
			if (gps != null) {
				var game = gps.selected_game();
				if (game != null)
					right = game.parent.unique_display_name().strip();
			} else {
				right = current_platform.get_folder_display_path(current_folder);
			}
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
				everything_selector = new EverythingSelector(SELECTOR_ID, selector_xpos, selector_ypos, selector_ymax, current_view_data);
			new_selector = everything_selector;
		} else if (this.category_active == true) {
			on_selector_loading();
			var category_selector = selector as GameCategorySelector;			
			if (category_selector == null)
				category_selector = new GameCategorySelector(SELECTOR_ID, selector_xpos, selector_ypos, selector_ymax, current_category);
			new_selector = category_selector;
		} else {
			if (this.current_folder != null) {
				on_selector_loading();
				if (Data.preferences().show_platform_game_folders == true) {
					var folder = current_platform.get_folder(current_folder);
					if (folder == null)
						folder = current_platform.get_root_folder();
					new_selector = new GameFolderSelector(folder, SELECTOR_ID, selector_xpos, selector_ypos, selector_ymax);
				} else {
					new_selector = new GamePlatformSelector(SELECTOR_ID, selector_xpos, selector_ypos, selector_ymax, current_platform);
				}
			} else if (this.current_platform_folder != null) {
				new_selector = new PlatformFolderSelector(this.current_platform_folder, SELECTOR_ID, selector_xpos, selector_ypos, selector_ymax);
			} else if (platform_list_active == false && this.platform_folder_data.folders.size > 0) {
				new_selector = new PlatformFolderSelector.root(SELECTOR_ID, selector_xpos, selector_ypos, selector_ymax);
			} else {
				new_selector = new PlatformSelector(SELECTOR_ID, selector_xpos, selector_ypos, selector_ymax);
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
		if (everything_active == true || category_active == true || Data.preferences().show_platform_game_folders == false)
			set_header();
		set_status(false);
	}
	void set_status(bool flip=true) {
		if (static_status_test != null) {
			status_message.set(static_status_test, null, null, flip);
			return;
		}
		if (@interface.peek_layer() != null)
			return; // another layer has focus, don't bother updating status
		string center = "%d / %d".printf(selector.selected_display_index() + 1, selector.display_item_count);
		string? right = null;
		string? active_pattern = selector.get_filter_pattern();
		if (active_pattern != null)
			right = "%s%s".printf(FILTER_LABEL, active_pattern);
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
		if (@interface.peek_layer() != null)
			update(false); // let the other focussed layer flip the screen
		else
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
							selector.ensure_selection();
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
						selector.ensure_selection();
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
	void platform_rescanned(Platform platform, string? new_selection_id) {
		if (everything_active || category_active) {
			return; // handled by AllGames.cache_updated() signal
		}
		
		if (current_platform != null && current_platform == platform && current_folder != null) {
			
			var gps = selector as GamePlatformSelector;
			if (gps != null) {
				gps.rebuild(new_selection_id);
				return;
			}
			
			current_folder = current_platform.get_nearest_folder_path(current_folder);
			var gfs = selector as GameFolderSelector;
			if (gfs != null) {
				var new_folder = current_platform.get_folder(current_folder);
				if (new_folder == null)
					new_folder = current_platform.get_root_folder();
				gfs.set_folder(new_folder, new_selection_id);
			} else {
				change_selector();
				selector.ensure_selection();
			}			
		} else if (current_platform_folder != null) {
			foreach(var platform_node in current_platform_folder.platforms) {
				if (platform_node.platform == platform) {
					selector.rebuild();
					break;
				}				
			}
		}
	}
		
	//
	// events
    void on_keydown_event (KeyboardEvent event) {
		if (event.keysym.mod == KeyModifier.LALT) {
			switch(event.keysym.sym) {
				case KeySymbol.a:
					new Layers.GameBrowser.MenuOverlay(new ObjectMenu("Edit current appearance", null, Data.preferences().appearance)).run();
					flip();
					return;
				case KeySymbol.b:
					new Layers.GameBrowser.MenuOverlay(new ObjectMenu("Edit current browser appearance", null, Data.preferences().appearance.game_browser)).run();
					flip();
					return;
				case KeySymbol.m:
					new Layers.GameBrowser.MenuOverlay(new ObjectMenu("Edit current menu appearance", null, Data.preferences().appearance.menu)).run();
					flip();
					return;
				default:
					break;
			}
		}
		
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
				case KeySymbol.BACKSPACE:
					filter_remove_char();
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
				//select_next_starting_with(c);
				filter_add_char(c);
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
//~ 	void select_next_starting_with(char c) {
//~ 		if (last_pressed_alphanumeric == c) {
//~ 			last_pressed_alphanumeric_repeat_count++;
//~ 		} else {
//~ 			last_pressed_alphanumeric = c;
//~ 			last_pressed_alphanumeric_repeat_count = 0;
//~ 		}
//~ 		if (last_pressed_alphanumeric_repeat_count > 0) {
//~ 			if (selector.select_item_starting_with(last_pressed_alphanumeric.to_string(), last_pressed_alphanumeric_repeat_count) == true)
//~ 				return;			
//~ 			last_pressed_alphanumeric_repeat_count = 0;
//~ 		}
//~ 		selector.select_item_starting_with(last_pressed_alphanumeric.to_string());
//~ 	}
//~ 	char last_pressed_alphanumeric = 0;
//~ 	int last_pressed_alphanumeric_repeat_count;

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

		var category_selector = selector as GameCategorySelector;
		if (category_selector != null) {
			var selected_path = category_selector.selected_category_path();
			if (selected_path != null) {
				current_category = selected_path;
				category_selector.change_category(current_category);
				return;
			}
			var game = category_selector.selected_game();
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
				selector.ensure_selection();
				var filter = state.get_current_platform_filter();
				if (filter != null)
					selector.filter(filter);
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
			selector.ensure_selection();
			var filter = state.get_current_platform_filter();
			if (filter != null)
				selector.filter(filter);
			return;
		}

		var gps = selector as GamePlatformSelector;
		if (gps != null) {
			var game = gps.selected_game();
			if (game != null)
				run_game(game);
			return;
		}
		
		var gsf = selector as GameFolderSelector;
		if (gsf != null) {
			var item = gsf.selected_item();
			var folder = item as GameFolder;
			if (folder != null) {
				var filter = selector.get_filter_pattern();
				current_folder = folder.unique_name();
				change_selector();
				selector.ensure_selection();
				if (filter != null)
					selector.filter(filter);
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
			var new_root = chooser.run(Data.preferences().rom_select_path());
			Data.preferences().update_most_recent_rom_path(chooser.most_recent_path);
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
		var gps = selector as GamePlatformSelector;
		if (gps != null) {
			Data.browser_state().apply_platform_state(current_platform, current_folder,
					selector.selected_index, selector.get_filter_pattern());
			current_folder = null;
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
		var gfs = selector as GameFolderSelector;
		if (gfs != null) {
			if (gfs.folder.parent == null) {
				Data.browser_state().apply_platform_state(current_platform, current_folder,
					selector.selected_index, selector.get_filter_pattern());
				current_folder = null;
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
			current_folder = gfs.folder.parent.unique_name();
			var filter = selector.get_filter_pattern();
			change_selector();
			int index=0;
			foreach(var subfolder in gfs.folder.child_folders()) {
				if (subfolder.unique_name() == previous_folder)
					break;
				index++;
			}
			selector.select_item(index);
			if (filter != null)
				selector.filter(filter);
			return;
		}
		var category_selector = selector as GameCategorySelector;
		if (category_selector != null) {
			var previous_category = category_selector.active_category_path;
			if (previous_category == null)
				return;
			current_category = category_selector.parent_category_path();
			category_selector.change_category(current_category);
			category_selector.select_category_path(previous_category);			
		}
	}

	void filter_add_char(char c) {
		var filter = selector.get_filter_pattern();
		if (filter == null)
			filter = "";
		filter = "%s%c".printf(filter, c);
		update_filter(filter);
		drain_events();
	}
	void filter_remove_char() {
		var filter = selector.get_filter_pattern();		
		if (filter == null)
			return;
		if (filter.length == 1) {
			filter = null;			
		} else {
			filter = filter.substring(0, filter.length - 1);
		}
		update_filter(filter);
		drain_events();
	}
	void filter_selector() {		
		status_message.set();

		var label = @interface.game_browser_ui.footer.render_text(FILTER_LABEL);
		Rect label_rect = {600 - (int16)label.w, status_message.ypos};
		blit_surface(label, null, label_rect);
		this.add_layer(new Layers.SurfaceLayer.direct("filter_label", label, label_rect.x, label_rect.y));		

		var controls = @interface.menu_ui.controls;
		var footer_center = (int16)(status_message.ypos + (status_message.height / 2));
		var entry_height = (int16)(controls.font_height + (controls.value_control_spacing * 2));
		int16 entry_ypos = (int16)(footer_center - (entry_height / 2));
		
		var entry = new TextEntry("selection_filter", 600, entry_ypos, 200, selector.get_filter_pattern());
		entry.text_changed.connect((text) => {
			var new_filter = text.strip();
			if (new_filter == "")
				new_filter = null;
			update_filter(new_filter, false);
		});
		var new_pattern = entry.run();
		if (new_pattern == null || new_pattern.strip() == "")
			new_pattern = null;
		
		this.remove_layer("filter_label");
		update_filter(new_pattern);
	}
	void update_filter(string? new_filter, bool flip=true) {
		if (new_filter != null)
			selector.filter(new_filter, flip);
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
		string? active_category = current_category;
		GameItem? selected_game = null;
		if (everything_active == true) {
			selected_game = (selector as EverythingSelector).selected_game();
			if (selected_game != null) {
				active_platform = selected_game.platform;
				active_folder = selected_game.parent.unique_name();
				active_folder_item_index = selected_game.parent.index_of(selected_game);
				active_category = selected_game.parent.unique_display_name();				
			}
		} else if (category_active == true) {
			selected_game = (selector as GameCategorySelector).selected_game();
			if (selected_game != null) {
				active_platform = selected_game.platform;
				active_folder = selected_game.parent.unique_name();
				active_folder_item_index = selected_game.parent.index_of(selected_game);
			}
		}
		var gps = selector as GamePlatformSelector;
		if (gps != null) {
			selected_game = gps.selected_game();
		} else {
			var gfs = selector as GameFolderSelector;
			if (gfs != null)
				selected_game = gfs.selected_item() as GameItem;
		}
		if (selected_game != null)
			active_category = selected_game.parent.unique_display_name();
		if (active_category == "")
			active_category = AllGames.UNCATEGORIZED_CATEGORY_NAME;
			
		var resolved_view_data = current_view_data;		
		if (everything_active == false && category_active == false) {
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
		
		if (new_view.involves_everything == false && new_view.view_type != GameBrowserViewType.CATEGORY) {
			everything_active = false;
			category_active = false;
			if (new_view.view_type == GameBrowserViewType.PLATFORM) {
				if (active_platform == null || (ensure_platform_root_rolder(active_platform) == false))
					return null;
				if ((active_folder == null && active_platform != null) || Data.preferences().show_platform_game_folders == false)
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
				if (Data.preferences().show_platform_game_folders == true) {
					Data.browser_state().current_platform = current_platform.id;
					if (current_folder != null)
						Data.browser_state().apply_platform_state(current_platform, current_folder, active_folder_item_index, null);
					
					apply_platform_state();
					selector.update();
				} else {
					change_selector();
					if (selected_game == null || (selector as GamePlatformSelector).select_game(selected_game) == false);
						selector.ensure_selection();
				}
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
		current_category = null;
		if (new_view.involves_everything == true) {
			category_active = false;
			if (everything_active == false) {
				Data.browser_state().apply_all_games_state(true, 0, null, new_view);
				apply_all_games_state();
				if (selected_game != null)
					(selector as EverythingSelector).select_game(selected_game);
				else
					GLib.message("game is null switching to everything selector");
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
		} else {
			everything_active = false;
			if (category_active == false) {
				Data.browser_state().apply_category_state(true, active_category, 0, null);
				apply_category_state();
				if (selected_game != null)
					(selector as GameCategorySelector).select_game(selected_game);
			} else {
				if (category_active == false) {
					category_active = true;
					current_category = active_category;
					change_selector();
					selector.update();
					if (selected_game != null)
						(selector as GameCategorySelector).select_game(selected_game);
				}
				current_view_data = new_view;
			}
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
		GameItem? selected_game = null;
		var active_platform = current_platform;
		var active_folder = current_folder;
		int active_folder_item_index = 0;
		if (everything_active == true) {
			selected_game = (selector as EverythingSelector).selected_game();
			if (selected_game != null) {
				active_platform = selected_game.platform;
				active_folder = selected_game.parent.unique_name();
				active_folder_item_index = selected_game.parent.index_of(selected_game);
			}
		} else if (category_active == true) {
			selected_game = (selector as GameCategorySelector).selected_game();
			if (selected_game != null) {
				active_platform = selected_game.platform;
				active_folder = selected_game.parent.unique_name();
				active_folder_item_index = selected_game.parent.index_of(selected_game);
			}
		}
		
		if (active_platform == null && everything_active == false && category_active == false) {
			var pfs = selector as PlatformFolderSelector;
			if (pfs != null) {
				var platform_node = pfs.selected_node() as PlatformNode;
				if (platform_node != null)
					active_platform = platform_node.platform;
				else {
					var folder_node = pfs.selected_node() as PlatformFolder;
					if (folder_node != null)
						active_platform = folder_node.get_all_platforms().first();
				}
			} else {
				var ps = selector as PlatformSelector;
				if (ps != null)
					active_platform = ps.selected_platform();
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
		if (new_platform == null || (ensure_platform_root_rolder(new_platform) == false) ||
		   (new_platform == active_platform && everything_active == false && category_active == false))
			return null;
		
		if (everything_active || category_active)
			update_browser_state();
		everything_active = false;
		category_active = false;
		
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
		if (Data.preferences().show_platform_game_folders == false) {
			Data.browser_state().current_platform = current_platform.id;
			if (new_platform == active_platform)
				Data.browser_state().apply_platform_state(current_platform, active_folder, active_folder_item_index, null);		
			apply_platform_state();
			selector.update();
		} else {
			current_folder = active_folder;
			change_selector();
			selector.update();
			if (selected_game == null || (selector as GamePlatformSelector).select_game(selected_game) == false);
				selector.ensure_selection();
		}
 		return null;
	}


	//
	// commands: menus
    void show_main_menu() {
		var overlay = new Layers.GameBrowser.MenuOverlay(new Menus.Concrete.MainMenu());
		overlay.add_cancel_key(KeySymbol.RSHIFT); // pandora L
		overlay.add_cancel_key(KeySymbol.RCTRL); // pandora R
		overlay.add_cancel_key(KeySymbol.SPACE);
		
		static_header_text = "Header";
		static_status_test = " Footer";
		set_header(false);
		set_status(false);		
		
		var cancel_key_pressed = overlay.run();
		
		static_header_text = null;
		static_status_test = null;
		set_header(false);
		set_status(false);
		
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
		if (category_active == true) {
			var game = (selector as GameCategorySelector).selected_game();
			if (game != null)
				show_game_menu(game);
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
		
		var gps = selector as GamePlatformSelector;
		if (gps != null) {
			var game = gps.selected_game();
			if (game != null)
				show_game_menu(game);
			return;
		}
		
		var gfs = selector as GameFolderSelector;
		if (gfs != null) {
			var item = gfs.selected_item();
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
			show_menu_overlay(new Menus.Concrete.GameMenu(game, new GameNodeMenuData(selector)));
	}
	void show_folder_menu(GameFolder folder) {
		show_menu_overlay(new Menus.Concrete.GameFolderMenu(folder, new GameNodeMenuData(selector)));
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
