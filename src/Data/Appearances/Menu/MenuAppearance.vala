/* MenuAppearance.vala
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

using Gee;
using Catapult;
using Fields;
using Menus;
using Menus.Fields;

namespace Data.Appearances.Menu
{
	public class MenuAppearance : MenuAppearanceBase<MenuAppearance>
	{
		const string DEFAULT_BORDER_COLOR = "#00BF10";
		
		construct {
			background_color = build_color(default_background_color());
			header = new MenuHeader.default();
			controls = new MenuControls.default();
			footer = new MenuFooter.default();
		}
		public MenuAppearance.default() {
			background_color = build_color(default_background_color());
			header = new MenuHeader.default();
			controls = new MenuControls.default();
			footer = new MenuFooter.default();
		}
		
		public override void set_name(string? name) { 
			base.set_name(name);
			header.set_name(name);
			controls.set_name(name);
			footer.set_name(name);
		}

		public Data.Color background_color { get; set; }
		public Data.Color border_color { get; set; }
		public SDL.Color background_color_sdl() { return resolve_sdl_color(background_color, default_background_color()); }
		public SDL.Color border_color_sdl() { return resolve_sdl_color(border_color, DEFAULT_BORDER_COLOR); }

		public MenuHeader header { get; set; }
		public MenuControls controls { get; set; }
		public MenuFooter footer { get; set; }


		public override MenuAppearance copy() {
			var copy = new MenuAppearance();
			if (background_color != null)
				copy.background_color = background_color.copy();
			else
				copy.background_color = build_color(default_background_color());
			if (border_color != null)
				copy.border_color = border_color.copy();
			else
				copy.border_color = build_color(DEFAULT_BORDER_COLOR);
				
			copy.header = header.copy();
			copy.controls = controls.copy();
			copy.footer = footer.copy();
			
			return copy;
		}
		public override void copy_from(MenuAppearance other) {
			background_color = other.background_color;
			border_color = other.border_color;
			header.copy_from(other.header);
			controls.copy_from(other.controls);
			footer.copy_from(other.footer);
		}

		public MenuUI create_ui() {
			return new MenuUI.from_appearance(this);
		}

		// menu
		protected override void color_changed() { @interface.menu_ui.update_colors(this); }
		protected override void appearance_changed() { @interface.menu_ui.update_appearance(this); }
		protected override string get_appearance_description() { return "Menu"; }
		
		protected override void build_menu(MenuBuilder builder) {
			add_color_field(builder, "background_color", "Background", "Background Color", background_color, default_background_color());
			add_color_field(builder, "border_color", "Border", "Border Color", border_color, DEFAULT_BORDER_COLOR);
			
			builder.add_separator();
						
			add_appearance_field<MenuHeader>(builder, "header", "Header", "Menu Header", header);
			add_appearance_field<MenuControls>(builder, "controls", "Controls", "Menu Controls", controls);
			add_appearance_field<MenuFooter>(builder, "footer", "Footer", "Menu Footer", footer);

			builder.add_separator();			
			builder.add_cancel_item();
			builder.add_save_item("Ok");
		}
		protected override void cleanup_fields() { }
	}
}
