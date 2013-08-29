/* MenuHeaderLayer.vala
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

namespace Layers.MenuBrowser
{
	public class MenuHeaderLayer : SurfaceLayer
	{
		Menus.MenuUI.HeaderUI ui;
		string? _left;
		string? _center;
		string? _right;
		
		public MenuHeaderLayer(string id) {
			var ui = @interface.menu_ui.header;
			base(id, 760, ui.font_height + 10, 20, 15, ui.background_color_rgb);
			this.ui = ui;
			ui.colors_updated.connect(update_colors);
		}

		public string? left {
			get { return _left; }
			set { _left = value; update(); }
		}
		public string? center {
			get { return _center; }
			set { _center = value; update(); }
		}
		public string? right {
			get { return _right; }
			set { _right = value; update(); }
		}
	
		public void set_text(string? left, string? center, string? right, bool flip_screen=true) {
			_left = left;
			_center = center;
			_right = right;
			update(flip_screen);
		}
		
		protected override void draw() {
			Rect rect = {0, 5};
			if (_left != null && _left != "") {
				blit_surface(ui.render_text(_left), null, rect);
			}
			Surface rendered_text;		
			if (_center != null && _center != "") {
				rendered_text = ui.render_text_to_fit(_center, width);
				rect.x = (int16)(surface.w/2 - rendered_text.w/2);
				blit_surface(rendered_text, null, rect);
			}
			if (_right != null && _right != "") {
				rendered_text = ui.render_text(_right);
				rect.x = (int16)(surface.w - rendered_text.w);
				blit_surface(rendered_text, null, rect);
			}		
		}
		
		void update_colors() {
			update(false);
		}
	}
}
