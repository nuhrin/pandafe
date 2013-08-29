/* GameBrowserAppearance.vala
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

namespace Data.Appearances.GameBrowser
{
	public class GameBrowserAppearance : GameBrowserAppearanceBase<GameBrowserAppearance>
	{
		construct {
			background_color = build_color(default_background_color());
			header = new GameBrowserHeader.default();
			list = new GameBrowserList.default();
			footer = new GameBrowserFooter.default();
		}
		public GameBrowserAppearance.default() {
			background_color = build_color(default_background_color());
			header = new GameBrowserHeader.default();
			list = new GameBrowserList.default();
			footer = new GameBrowserFooter.default();
		}

		public override void set_name(string? name) { 
			base.set_name(name);
			header.set_name(name);
			list.set_name(name);
			footer.set_name(name);
		}

		public Data.Color background_color { get; set; }
		public SDL.Color background_color_sdl() { return resolve_sdl_color(background_color, default_background_color()); }
		
		public GameBrowserHeader header { get; set; }
		public GameBrowserList list { get; set; }
		public GameBrowserFooter footer { get; set; }
				
		
		public override GameBrowserAppearance copy() {
			var copy = new GameBrowserAppearance();
			if (background_color != null)
				copy.background_color = background_color.copy();
			else
				copy.background_color = build_color(default_background_color());
			copy.header = header.copy();
			copy.list = list.copy();
			copy.footer = footer.copy();
			
			return copy;
		}
		public override void copy_from(GameBrowserAppearance other) {
			background_color = other.background_color;
			header.copy_from(other.header);
			list.copy_from(other.list);
			footer.copy_from(other.footer);
		}
		
		public GameBrowserUI create_ui() {				
			return new GameBrowserUI.from_appearance(this);
		}
		
		// menu
		protected override void color_changed() { @interface.game_browser_ui.update_colors(this); }
		protected override void appearance_changed() { @interface.game_browser_ui.update_appearance(this); }
		protected override string get_appearance_description() { return "Game Browser"; }
		
		protected override void build_menu(MenuBuilder builder) {			
			add_color_field(builder, "background_color", "Background", "Background Color", background_color, default_background_color());			
			
			builder.add_separator();
			
			add_appearance_field<GameBrowserHeader>(builder, "header", "Header", "Game Browser Header", header);
			add_appearance_field<GameBrowserList>(builder, "list", "List", "Game Browser List", list);
			add_appearance_field<GameBrowserFooter>(builder, "footer", "Footer", "Game Browser Footer", footer);
			
			builder.add_separator();			
			builder.add_cancel_item();
			builder.add_save_item("Ok");
		}
		protected override void cleanup_fields() { }
	}
}
