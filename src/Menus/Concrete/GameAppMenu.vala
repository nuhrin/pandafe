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
			this.title = "Manage App: " + get_app_name(game, app);			
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
				var full_path = Path.get_dirname(app.get_fullpath());
				items.add(new MenuItem.custom("Terminal", "Open terminal in " + full_path, "", () => {
					var result = Spawning.spawn_command("/usr/bin/terminal", full_path);
					if (result.success == false)
						result.show_result_dialog();
				}));
				items.add(new MenuItem.custom("File Manager", "Open file manager in " + full_path, "", () => {
					var result = Spawning.spawn_command("/usr/bin/thunar", full_path);
					if (result.success == false)
						result.show_result_dialog();
				}));
			}
		}
		
		static string get_app_name(GameItem game, AppItem? app) {
			if (app != null)
				return "%s, %s".printf(app.filename, app.id);
			
			return game.name;
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
				string? new_title = entry.run();
				if (new_title == app.title)
					return;
				
				selector.menu.message("Renaming...");
				
				app_override.title = new_title;
				if (app_override.save() == false) {
					selector.menu.error("Error saving ovr update");
					return;
				}
				
				Data.platforms().rescan_folder(game.parent, game.unique_id());
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
				var category_overlay = new Layers.GameBrowser.SelectorOverlay<string>.from_selector("Change Category: " + get_app_name(game, app), null, category_selector);
				
				var overlay_layer = @interface.pop_layer(false);
				category_overlay.run();
				@interface.push_layer(overlay_layer);
				
				if (category_selector.was_canceled == true)
					return;
				if (current_category == null && category_selector.no_category_selected == true)
					return;
				if (current_category == category_selector.selected_item())
					return;
				
				selector.menu.message("Changing category...");
				
				string? new_category = null;				
				if (category_selector.no_category_selected == false)
					new_category = category_selector.selected_item();				
				
				app_override.sub_category = new_category;
				if (app_override.save() == false) {
					selector.menu.error("Error saving ovr update");
					return;
				}				
				
				var new_folder_relative = new_category ?? "";
				var new_folder_depth = new_folder_relative.split("/").length;
				var scan_target_node = game.parent;
				while(new_folder_depth <= scan_target_node.depth() && scan_target_node.parent != null)
					scan_target_node = scan_target_node.parent;
				Data.platforms().rescan_folder(scan_target_node, game.unique_id());
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
				
				if (ObjectMenu.edit("App Override: %s, %s".printf(app.filename, app.id), app_override) == false)
					return;
				
				selector.menu.message("Updating..");
				
				Data.platforms().rescan_folder(game.platform.get_root_folder(), game.unique_id());
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
				delete_overlay.run();
				@interface.push_layer(overlay_layer);

				if (delete_selector.confirm_selected() == false)
					return;
				
				selector.menu.message("Deleting...");
				
				var filename = app.get_fullpath();
				var file = File.new_for_path(filename);
				try {
					if (file.delete() == false) {
						selector.menu.error(filename + ": unable to delete file");
						return;
					}					
				} catch (GLib.Error e) {
					selector.menu.error("%s: %s".printf(filename, e.message));
					return;
				}
				
				Data.platforms().rescan_folder(game.parent);
				selector.menu.quit();				
			}
		}
	}
}
