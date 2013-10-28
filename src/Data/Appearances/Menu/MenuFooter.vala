/* MenuFooter.vala
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

namespace Data.Appearances.Menu
{
	public class MenuFooter : MenuFontAreaBase<MenuFooter>
	{
		const string DEFAULT_TEXT_COLOR = "#00FF14";
		
		construct {
		}
		public MenuFooter.default() {
			base.default();
			text_color = build_color(DEFAULT_TEXT_COLOR);
		}
		
		public Data.Color text_color { get; set; }
		public SDL.Color text_color_sdl() { return resolve_sdl_color(text_color, DEFAULT_TEXT_COLOR); }
				
		public override MenuFooter copy() {
			var copy = new MenuFooter();
			copy_font_to(copy);
			
			if (text_color != null)
				copy.text_color = text_color.copy();

			return copy;			
		}
		public override void copy_from(MenuFooter other) {
			copy_font_from(other);
			text_color = other.text_color;
		}		
		
		protected override void attribute_changed() { @interface.menu_ui.footer.update_font(this); }
		protected override void color_changed() { @interface.menu_ui.footer.update_colors(this); }
		protected override void appearance_changed() { @interface.menu_ui.footer.update_appearance(this); }
		protected override string get_appearance_description() { return "Menu Footer"; }
		
		protected override bool monospace_font_required() { return true; }
		protected override void build_area_fields(MenuBuilder builder)
		{
			builder.add_separator();
			add_color_field(builder, "text_color", "Text", "Text Color", text_color, DEFAULT_TEXT_COLOR);
		}
		protected override void cleanup_area_fields() {
		}
	}
}
