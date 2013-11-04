/* MenuList.vala
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

namespace Data.Appearances.Menu
{
	public class MenuControls : MenuFontAreaBase<MenuControls>
	{	
		construct {
		}
		public MenuControls.default() {
			base.default();
			item_spacing = AppearanceDefaults.MENU_ITEM_SPACING;
			item_color = build_color(AppearanceDefaults.MENU_ITEM_COLOR);
			selected_item_color = build_color(AppearanceDefaults.MENU_SELECTED_ITEM_COLOR);
			selected_item_background_color = build_color(AppearanceDefaults.MENU_SELECTED_ITEM_BACKGROUND_COLOR);
			text_cursor_color = build_color(AppearanceDefaults.MENU_TEXT_CURSOR_COLOR);
		}
		
		public int item_spacing { get; set; }
		public Data.Color item_color { get; set; }
		public Data.Color selected_item_color { get; set; }
		public Data.Color selected_item_background_color { get; set; }
		public Data.Color text_cursor_color { get; set; }
		
		public int16 item_spacing_resolved() { return (int16)((item_spacing > 0) ? item_spacing : AppearanceDefaults.MENU_ITEM_SPACING); }
		public SDL.Color item_color_sdl() { return resolve_sdl_color(item_color, AppearanceDefaults.MENU_ITEM_COLOR);  }
		public SDL.Color selected_item_color_sdl() { return resolve_sdl_color(selected_item_color, AppearanceDefaults.MENU_SELECTED_ITEM_COLOR);  }
		public SDL.Color selected_item_background_color_sdl() { return resolve_sdl_color(selected_item_background_color, AppearanceDefaults.MENU_SELECTED_ITEM_BACKGROUND_COLOR);  }
		public SDL.Color text_cursor_color_sdl() { return resolve_sdl_color(text_cursor_color, AppearanceDefaults.MENU_TEXT_CURSOR_COLOR); }
		
		public override MenuControls copy() {
			var copy = new MenuControls();
			copy_font_to(copy);
			copy.item_spacing = item_spacing;

			if (item_color != null)
				copy.item_color = item_color.copy();
			if (selected_item_color != null)
				copy.selected_item_color = selected_item_color.copy();
			if (selected_item_background_color != null)
				copy.selected_item_background_color = selected_item_background_color.copy();
			if (text_cursor_color != null)
				copy.text_cursor_color = text_cursor_color.copy();
				
			return copy;			
		}
		public override void copy_from(MenuControls other) {
			copy_font_from(other);
			item_spacing = other.item_spacing;
			item_color = other.item_color;
			selected_item_color = other.selected_item_color;
			selected_item_background_color = other.selected_item_background_color;
			text_cursor_color = other.text_cursor_color;
		}
		
		protected override void attribute_changed() { @interface.menu_ui.controls.update_font(this); }
		protected override void color_changed() { @interface.menu_ui.controls.update_colors(this); }
		protected override void appearance_changed() { @interface.menu_ui.controls.update_appearance(this); }
		protected override string get_appearance_description() { return "Menu Controls"; }
		
		protected override bool monospace_font_required() { return true; }
		protected override void build_area_fields(MenuBuilder builder)
		{
			var field_handlers = get_field_handler_map();
			var item_spacing_field = new IntegerField("item_spacing", "Item Spacing", null, item_spacing, 1, 15);
			field_handlers.set(item_spacing_field, item_spacing_field.changed.connect(() => {
				item_spacing = item_spacing_field.value;
				attribute_changed();
			}));
			builder.add_field(item_spacing_field);
			
			builder.add_separator();
			
			add_color_field(builder, "item_color", "Item", "Item Color", item_color, AppearanceDefaults.MENU_ITEM_COLOR);
			add_color_field(builder, "selected_item_color", "Selected", "Selected Item Color", selected_item_color, AppearanceDefaults.MENU_SELECTED_ITEM_COLOR);
			add_color_field(builder, "selected_item_background_color", "Selected BG", "Selected Item Background Color", selected_item_background_color, AppearanceDefaults.MENU_SELECTED_ITEM_BACKGROUND_COLOR);
			var text_cursor_field = add_color_field(builder, "text_cursor_color", "Text Cursor", "Text Cursor Color", text_cursor_color, AppearanceDefaults.MENU_TEXT_CURSOR_COLOR);
			text_cursor_field.update_on_text_value_change = true;
		}
		protected override void cleanup_area_fields() {
		}
	}
}
