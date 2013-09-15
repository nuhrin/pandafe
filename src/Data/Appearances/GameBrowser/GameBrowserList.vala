/* GameBrowserList.vala
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

using Menus;
using Menus.Fields;

namespace Data.Appearances.GameBrowser
{
	public class GameBrowserList : GameBrowserFontAreaBase<GameBrowserList>
	{	
		const string DEFAULT_ITEM_COLOR = "#178ECB";
		const string DEFAULT_SELECTED_ITEM_COLOR = "#0F3854";
		const string DEFAULT_SELECTED_ITEM_BACKGROUND_COLOR = "#178ECB";
		
		construct {
			spacing = new GameBrowserListSpacing.default();
		}
		public GameBrowserList.default() {
			base.default();
			spacing = new GameBrowserListSpacing.default();
			item_color = build_color(DEFAULT_ITEM_COLOR);
			selected_item_color = build_color(DEFAULT_SELECTED_ITEM_COLOR);
			selected_item_background_color = build_color(DEFAULT_SELECTED_ITEM_BACKGROUND_COLOR);
		}
		
		public GameBrowserListSpacing spacing { get; set; }
		public Data.Color item_color { get; set; }
		public Data.Color selected_item_color { get; set; }
		public Data.Color selected_item_background_color { get; set; }
		
		public SDL.Color item_color_sdl() { return resolve_sdl_color(item_color, DEFAULT_ITEM_COLOR);  }
		public SDL.Color selected_item_color_sdl() { return resolve_sdl_color(selected_item_color, DEFAULT_SELECTED_ITEM_COLOR);  }
		public SDL.Color selected_item_background_color_sdl() { return resolve_sdl_color(selected_item_background_color, DEFAULT_SELECTED_ITEM_BACKGROUND_COLOR);  }
				
		public override GameBrowserList copy() {
			var copy = new GameBrowserList();
			copy_font_to(copy);
			
			copy.spacing = spacing.copy();

			if (item_color != null)
				copy.item_color = item_color.copy();
			if (selected_item_color != null)
				copy.selected_item_color = selected_item_color.copy();
			if (selected_item_background_color != null)
				copy.selected_item_background_color = selected_item_background_color.copy();
				
			return copy;			
		}
		public override void copy_from(GameBrowserList other) {
			copy_font_from(other);
			spacing.copy_from(other.spacing);
			item_color = other.item_color;
			selected_item_color = other.selected_item_color;
			selected_item_background_color = other.selected_item_background_color;
		}
		
		protected override void attribute_changed() { @interface.game_browser_ui.list.update_font(this); }
		protected override void color_changed() { @interface.game_browser_ui.list.update_colors(this); }
		protected override void appearance_changed() { @interface.game_browser_ui.list.update_appearance(this, true); }
		protected override string get_appearance_description() { return "Game Browser List"; }
		
		protected override void build_area_fields(MenuBuilder builder)
		{
			add_appearance_field<GameBrowserListSpacing>(builder, "spacing", "Spacing", "List Spacing", spacing);
			
			builder.add_separator();
			
			add_color_field(builder, "item_color", "Item", "Item Color", item_color, DEFAULT_ITEM_COLOR);
			add_color_field(builder, "selected_item_color", "Selected", "Selected Item Color", selected_item_color, DEFAULT_SELECTED_ITEM_COLOR);
			add_color_field(builder, "selected_item_background_color", "Selected BG", "Selected Item Background Color", selected_item_background_color, DEFAULT_SELECTED_ITEM_BACKGROUND_COLOR);						
		}
		protected override void cleanup_area_fields() {
		}
	}
}
