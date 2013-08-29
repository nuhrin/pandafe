/* Preferences.vala
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

using Gee;
using Catapult;
using Fields;
using Menus;
using Menus.Fields;

namespace Data
{
	public class Preferences : Entity, MenuObject
	{		
		internal const string ENTITY_ID = "preferences";
		const string FALLBACK_ROM_SELECT_PATH = "/media/mmcblk0p1/pandora/roms";

		public Appearance appearance { get; set; }
		public string? default_rom_select_path { get; set; }
		public string? most_recent_rom_path { get; set; }
		
		public string? rom_select_path() { return default_rom_select_path ?? most_recent_rom_path ?? FALLBACK_ROM_SELECT_PATH; }
		public void update_most_recent_rom_path(string? new_path) {
			if (new_path == null || default_rom_select_path != null)
				return;
			most_recent_rom_path = new_path;
			Data.save_preferences();
		}
		
		// yaml
		protected override string generate_id() { return ENTITY_ID; }

		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			if (appearance == null)
				appearance = new Appearance.default();
			
			return base.build_yaml_node(builder);
		}
		protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			base.apply_yaml_node(node, parser);
			if (appearance == null)
				appearance = new Appearance.default();
		}
		
		// menu
		protected void build_menu(MenuBuilder builder) {
			appearance_field = new AppearanceField("appearance", "Appearance", "Configure font and colors", appearance);
			appearance_field.appearance_changed.connect((a) => {
				@interface.game_browser_ui.update_appearance(a.game_browser);
				@interface.menu_ui.update_appearance(a.menu);
			});
//~ 			appearance_field.menu_appearance_changed.connect((ma) => {
//~ 				@interface.menu_ui.set_appearance(ma);
//~ 				//@interface.peek_layer().update();
//~ 			});
			builder.add_field(appearance_field);			
			builder.add_folder("default_rom_select_path", "Default Rom Path", "Used as starting path when selecting platform roms for the first time.", default_rom_select_path);
		}
		protected bool save_object(Menus.Menu menu) {
			if (default_rom_select_path != null)
				most_recent_rom_path = null;
			Data.save_preferences();
			return true;
		}		
		protected void release_fields(bool was_saved) {
 			if (appearance_field.has_changes() == true && was_saved == false) {
 				@interface.game_browser_ui.update_appearance(appearance.game_browser);
 				@interface.menu_ui.update_appearance(appearance.menu);
			}
			appearance_field = null;
		}		
		AppearanceField appearance_field;
	}
}
