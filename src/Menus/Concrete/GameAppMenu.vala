/* GameAppMenu.vala
 * 
 * Copyright (C) 2013 nuhrin
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

using Fields;
using Menus.Fields;
using Data.GameList;
using Data.Platforms;
using Data.Pnd;
using Layers.Controls;

namespace Menus.Concrete
{
	public class GameAppMenu : Menu  
	{	
		GameItem game;
		GameNodeMenuData menu_data;
		AppItem? app;
		public GameAppMenu(GameItem game, GameNodeMenuData menu_data, string? help=null) {
			if (game.platform.platform_type != PlatformType.NATIVE)
				GLib.error("GameAppMenu is only applicable to games from the Native Platform");
			base("Manage App", help);
			this.game = game;
			this.menu_data = menu_data;
			this.app = (game.platform as NativePlatform).get_game_app(game);
			this.title = "Manage App: " + ((app != null) ? app.menu_title() : game.name);
		}

		protected override void populate_items(Gee.List<MenuItem> items) { 			
			items.add(new RenameItem(game, menu_data, app));
			items.add(new MoveItem(game, app));
			items.add(new MenuItemSeparator());
			items.add(new EditOVRItem(game, app));
			items.add(new MenuItemSeparator());
			items.add(new DeleteItem(game, app));
			if (app != null) {
				items.add(new MenuItemSeparator());
				items.add(new AppTerminalFolderItem(app));
				items.add(new AppFileManagerFolderItem(app));
			}
		}
		
		class RenameItem : MenuItem
		{
			GameItem game;
			GameNodeMenuData menu_data;
			AppItem? app;
			public RenameItem(GameItem game, GameNodeMenuData menu_data, AppItem? app) {
				base("Rename", "Change the app title (via .ovr file)");
				this.game = game;
				this.menu_data = menu_data;
				this.app = app;
			}
			public override void activate(MenuSelector selector) {
				if (app == null) {
					selector.menu.error("App '%s' not found".printf(game.name));
					return;
				}
				if (FileUtils.test(app.get_fullpath(), FileTest.EXISTS) == false) {
					selector.menu.error("PND does not exist");
					return;
				}
				AppOverride? app_override = null;
				try {
					app_override = new Data.Pnd.AppOverride(app);									
				} catch(GLib.Error e) {
					selector.menu.error(e.message);
					return;
				}
				
				unowned SDL.Rect rect = menu_data.selected_item_rect();			
				int16 width = selector.xpos - @interface.menu_ui.controls.value_control_spacing - rect.x;
				var entry = new Layers.Controls.TextEntry.browser("app_rename", rect.x, rect.y, width, app.title);
				string? new_title = entry.run_no_pop();
				if (new_title == app.title) {
					@interface.pop_layer();
					return;
				}
				
				selector.menu.message("Renaming...");
				
				app_override.title = new_title;
				if (app_override.save() == false) {
					@interface.pop_layer(false);
					selector.menu.error("Error saving ovr update");
					return;
				}
				
				Data.platforms().rescan_folder(game.parent, game.unique_id());
				
				@interface.pop_layer(false);
				selector.menu.quit();
			}
		}
			
		class MoveItem : MenuItem
		{
			GameItem game;
			AppItem? app;
			public MoveItem(GameItem game, AppItem? app) {
				base("Change Category", "Change the app subcategory (via .ovr file)");
				this.game = game;
				this.app = app;
			}
			public override void activate(MenuSelector selector) { 
				if (app == null) {
					selector.menu.error("App '%s' not found".printf(game.name));
					return;
				}
				if (FileUtils.test(app.get_fullpath(), FileTest.EXISTS) == false) {
					selector.menu.error("PND does not exist");
					return;
				}
				AppOverride? app_override = null;
				try {
					app_override = new Data.Pnd.AppOverride(app);									
				} catch(GLib.Error e) {
					selector.menu.error(e.message);
					return;
				}
				
				var rect = selector.get_selected_item_rect();
				var current_category = game.parent.display_name();
				if (current_category == "")
					current_category = null;
				var category_selector = new Layers.Controls.GameCategorySelector("game_category_selector", rect.x, rect.y, 200, current_category);
				var category_overlay = new Layers.GameBrowser.SelectorOverlay<string>.from_selector("Change Category: " + app.menu_title(), null, category_selector);
				
				var overlay_layer = @interface.pop_layer(false);
				category_overlay.run_no_pop();
				
				if (
				    category_selector.was_canceled == true ||
				    (current_category == null && category_selector.no_category_selected == true) ||
				    (current_category == category_selector.selected_item())
				) {
					@interface.pop_layer(false);
					@interface.push_layer(overlay_layer);
					return;
				}
				
				category_overlay.set_message("Changing category...");
				
				string? new_category = null;				
				if (category_selector.no_category_selected == false)
					new_category = category_selector.selected_item();				
				
				app_override.sub_category = new_category;
				if (app_override.save() == false) {
					@interface.pop_layer(false);
					@interface.push_layer(overlay_layer, 0, 0, false);
					selector.menu.error("Error saving ovr update");
					return;
				}				
				
				var new_folder_relative = new_category ?? "";
				var new_folder_depth = new_folder_relative.split("/").length;
				var scan_target_node = game.parent;
				while(new_folder_depth <= scan_target_node.depth() && scan_target_node.parent != null)
					scan_target_node = scan_target_node.parent;
				Data.platforms().rescan_folder(scan_target_node, game.unique_id());
				
				@interface.pop_layer(false);
				selector.menu.quit();
			}
		}
		class EditOVRItem : MenuItem
		{
			GameItem game;
			AppItem? app;
			public EditOVRItem(GameItem game, AppItem? app) {
				base("Edit OVR", "Edit full override information (.ovr)");				
				this.game = game;
				this.app = app;
			}
			public override void activate(MenuSelector selector) { 
				if (app == null) {
					selector.menu.error("App '%s' not found".printf(game.name));
					return;
				}
				if (FileUtils.test(app.get_fullpath(), FileTest.EXISTS) == false) {
					selector.menu.error("PND does not exist");
					return;
				}
				
				AppOverride? app_override = null;
				try {
					app_override = new Data.Pnd.AppOverride(app);									
				} catch(GLib.Error e) {
					selector.menu.error(e.message);
					return;
				}
				
				var original_mount_id = app.mount_id;
				var app_edit_menu = new ObjectMenu("App Override: " + app.menu_title(), null, app_override);
				var browser = new MenuBrowser(app_edit_menu);
				browser.run_no_pop();
				
				if (app_edit_menu.was_saved == false) {
					@interface.pop_screen_layer();
					return;
				}
							
				if (app.mount_id != original_mount_id && Data.pnd_mountset().is_id_mounted(original_mount_id)) {
					browser.set_message("Unmounting %s...".printf(original_mount_id));
					// hack around GameBrowser behavior, to prevent screen flip
						@interface.push_layer(new Layers.DummyLayer(), 0, 0, false);
					Data.pnd_mountset().unmount_by_id(original_mount_id);
					browser.set_message("Saving...");
				}

				Data.platforms().rescan_folder(game.platform.get_root_folder(), game.unique_id());
				
				@interface.pop_screen_layer();
				selector.menu.quit();				
			}
		}
		class DeleteItem : MenuItem
		{
			GameItem game;
			AppItem? app;
			public DeleteItem(GameItem game, AppItem? app) {
				base("Delete PND", "Delete the app pnd file");				
				this.game = game;
				this.app = app;
			}
			public override void activate(MenuSelector selector) {
				if (app == null) {
					selector.menu.error("App '%s' not found".printf(game.name));
					return;
				}
				if (FileUtils.test(app.get_fullpath(), FileTest.EXISTS) == false) {
					selector.menu.error("PND does not exist");
					return;
				}
				
				var rect = selector.get_selected_item_rect();
				var delete_selector = new DeleteConfirmation("confirm_game_delete", rect.x, rect.y);
				var delete_overlay = new Layers.GameBrowser.SelectorOverlay<string>.from_selector("Delete: " + app.get_fullpath(), null, delete_selector);
				var overlay_layer = @interface.pop_layer(false);
				delete_overlay.run_no_pop();
				
				if (delete_selector.confirm_selected() == false) {
					@interface.pop_layer(false);
					@interface.push_layer(overlay_layer);
					return;
				}
								
				// unmount the pnd, if necessary
				if (Data.pnd_mountset().is_pnd_mounted(app) == true) {
					delete_overlay.set_message("Unmounting...");				
					if (Data.pnd_mountset().unmount(app) == false) {
						@interface.pop_layer(false);
						@interface.push_layer(overlay_layer, 0, 0, false);
						selector.menu.error(app.get_fullpath() + ": unable to unmount");
						return;
					}
				}
				
				delete_overlay.set_message("Deleting...");
				
				// remove the pnd
				var filename = app.get_fullpath();
				var file = File.new_for_path(filename);
				try {
					if (file.delete() == false)
						throw new FileError.FAILED("unable to delete file");					
				} catch (GLib.Error e) {
					@interface.pop_layer(false);
					@interface.push_layer(overlay_layer, 0, 0, false);
					selector.menu.error("%s: %s".printf(filename, e.message));
					return;
				}
				
				// update the pnd_cache and runtime data
				bool updated = false;
				var pnd = Data.pnd_data().get_pnd(filename);
				if (pnd != null) {
					if (Data.pnd_data().remove_pnd_item(pnd) == true) {
						Data.programs().rebuild_program_apps();
						updated = true;
					}
				}
				if (updated == false)
					Data.rescan_pnd_data();				
				game.platform.reset_runtime_data();		
				Data.platforms().rescan_folder(game.parent);
								
				@interface.pop_layer(false);
				selector.menu.quit();				
			}
		}
		public class AppTerminalFolderItem : FolderItem
		{
			public AppTerminalFolderItem(AppItem? app, string? app_title=null) {
				base("Terminal", "Open terminal in", app, app_title);
			}
			protected override void open_command(string path) { Spawning.open_terminal(path); }
		}
		public class AppFileManagerFolderItem : FolderItem
		{
			public AppFileManagerFolderItem(AppItem? app, string? app_title=null) {
				base("File Manager", "Open file manager in", app, app_title);
			}
			protected override void open_command(string path) { Spawning.open_file_manager(path); }
		}
		public abstract class FolderItem : MenuItem, SubMenuItem
		{
			string help_prefix;
			AppItem? app;
			string? app_title;
			Menu _menu;
			protected FolderItem(string name, string help_prefix, AppItem? app, string? app_title=null) {
				base(name, help_prefix + " ...");
				this.help_prefix = help_prefix;
				this.app = app;
				this.app_title = app_title ?? app.menu_title();
			}
			protected abstract void open_command(string path);
			
			public bool on_activation(MenuSelector selector) { 
				if (app == null) {
					selector.menu.error("App not found");
					return false;
				}
				if (FileUtils.test(app.get_fullpath(), FileTest.EXISTS) == false) {
					selector.menu.error("PND does not exist");
					return false;
				}
				
				_menu = new FolderMenu("%s: %s".printf(name, app_title), this);
				return true;
			}
			public Menu menu { get { return _menu;} }
			string get_help_text(string path) { return "%s %s".printf(help_prefix, path); }
			
			class FolderMenu : Menu
			{
				weak FolderItem item;
				public FolderMenu(string name, FolderItem item) {
					base(name);
					this.item = item;
				}
				
				protected override void populate_items(Gee.List<MenuItem> items) {
					var appdata_path = MountSet.get_appdata_path(item.app);
					if (appdata_path != null)
						items.add(get_item("AppData", appdata_path));
					items.add(new MountFolderItem("Mount", item));
					items.add(get_item("PND", Path.get_dirname(item.app.get_fullpath())));
				}
				MenuItem get_item(string name, string path) {
					return new MenuItem.custom(name, item.get_help_text(path), "", () => {
						item.open_command(path);
					});
				}
				
				class MountFolderItem : MenuItem
				{
					weak FolderItem item;
					string path;
					public MountFolderItem(string name, FolderItem item) {
						var path = MountSet.get_mount_path(item.app);
						base(name, item.get_help_text(path));
						this.path = path;
						this.item = item;
					}
					public override void activate(MenuSelector selector) {
						var app = item.app;
						var mountset = Data.pnd_mountset();
						if (mountset.is_pnd_mounted(app) == false) {
							if (mountset.is_mounted(app) == true) {
								selector.menu.message("Unmounting '%s'...".printf(app.menu_title()));
								if (mountset.unmount(app) == false) {
									selector.menu.error("Unable to unmount %s.".printf(app.menu_title()));
									return;
								}
							}
							selector.menu.message("Mounting '%s'...".printf(app.menu_title()));
							if (Data.pnd_mountset().mount(app) == false) {
								selector.menu.error("Unable to mount %s.".printf(app.menu_title()));
								return;
							}
							selector.menu.message("");
						}
						item.open_command(path);
					}
				}
			}
		}
		
	}
}
