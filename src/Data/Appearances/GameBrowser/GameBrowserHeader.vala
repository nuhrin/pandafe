/* GameBrowserHeader.vala
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

namespace Data.Appearances.GameBrowser
{
	public class GameBrowserHeader : GameBrowserFontAreaBase<GameBrowserHeader>
	{
		construct {
		}
		public GameBrowserHeader.default() {
			base.default();
			text_color = build_color(AppearanceDefaults.GAME_BROWSER_HEADER_FOOTER_COLOR);
		}
		
		public Data.Color text_color { get; set; }
		public SDL.Color text_color_sdl() { return resolve_sdl_color(text_color, AppearanceDefaults.GAME_BROWSER_HEADER_FOOTER_COLOR); }
				
		public override GameBrowserHeader copy() {
			var copy = new GameBrowserHeader();
			copy_font_to(copy);
			
			if (text_color != null)
				copy.text_color = text_color.copy();

			return copy;			
		}
		public override void copy_from(GameBrowserHeader other) {
			copy_font_from(other);
			text_color = other.text_color;
		}
		
		protected override unowned string default_font_preferred() { return AppearanceDefaults.GAME_BROWSER_HEADER_FONT_PREFERRED; }
		protected override int default_font_size() { return AppearanceDefaults.GAME_BROWSER_HEADER_FONT_SIZE; }
		
		protected override void attribute_changed() { @interface.game_browser_ui.header.update_font(this); }
		protected override void color_changed() { @interface.game_browser_ui.header.update_colors(this); }
		protected override void appearance_changed() { @interface.game_browser_ui.header.update_appearance(this); }
		protected override string get_appearance_description() { return "Game Browser Header"; }
		
		protected override void build_area_fields(MenuBuilder builder)
		{
			builder.add_separator();
			add_color_field(builder, "text_color", "Text", "Text Color", text_color, AppearanceDefaults.GAME_BROWSER_HEADER_FOOTER_COLOR);
		}
		protected override void cleanup_area_fields() {
		}
	}
}
