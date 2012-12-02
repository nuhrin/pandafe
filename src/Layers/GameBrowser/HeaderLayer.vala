/* HeaderLayer.vala
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

namespace Layers.GameBrowser
{
	public class HeaderLayer : SurfaceLayer
	{
		GameBrowserUI ui;
		string? _left;
		string? _center;
		string? _right;
				
		public HeaderLayer(string id, int16 ypos=20, GameBrowserUI? ui=null) {
			GameBrowserUI resolved_ui = (GameBrowserUI)ui ?? @interface.game_browser_ui;
			base(id, 760, resolved_ui.font_height, 20, ypos, resolved_ui.background_color_rgb);
			this.ui = resolved_ui;			
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
			Rect rect = {0, 0};
			if (_left != null && _left != "") {
				blit_surface(ui.render_text_selected_fast(_left), null, rect);
			}
			Surface rendered_text;		
			if (_center != null && _center != "") {
				rendered_text = ui.render_text_selected_fast(_center);
				rect.x = (int16)(surface.w/2 - rendered_text.w/2);
				blit_surface(rendered_text, null, rect);
			}
			if (_right != null && _right != "") {
				rendered_text = ui.render_text_selected_fast(_right);
				rect.x = (int16)(surface.w - rendered_text.w);
				blit_surface(rendered_text, null, rect);
			}		
		}
		
	}
}
