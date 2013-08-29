/* StatusMessageLayer.vala
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

namespace Layers.GameBrowser
{
	public class StatusMessageLayer : SurfaceLayer
	{		
		GameBrowserUI.FooterUI ui;
		string? _left;
		string? _center;
		string? _right;
		
		public StatusMessageLayer(string id, int16 layer_height=480) {
			var ui = @interface.game_browser_ui.footer;
			base(id, 780, ui.font_height, 10, layer_height - ui.font_height - 10, @interface.game_browser_ui.background_color_rgb);
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
		
		public new void set(string? left=null, string? center=null, string? right=null, bool flip_screen=true) {				
			_left = left;
			_center = center;
			_right = right;
			update(flip_screen);
		}
		public bool text_will_fit(string text) {
			return (ui.render_text(text).w <= width);
		}
		
		protected override void draw() {
			Rect rect = {0, 0};
			if (_left != null && _left != "") {
				blit_surface(ui.render_text(_left), null, rect);
			}
			Surface rendered_message;
			if (_center != null && _center != "") {
				rendered_message = ui.render_text(_center);
				rect.x = (int16)(surface.w/2 - rendered_message.w/2);
				blit_surface(rendered_message, null, rect);
			}
			if (_right != null && _right != "") {
				rendered_message = ui.render_text(_right);
				rect.x = (int16)(surface.w - rendered_message.w);
				blit_surface(rendered_message, null, rect);
			}			
		}
		
		void update_colors() {
			update(false);
		}
	}
}
