/* ChooserHeader.vala
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
	public class ChooserHeader : SurfaceLayer
	{
		Menus.MenuUI ui;
		string? _title;
		string? _path;
		
		public ChooserHeader(string id) {
			var ui = @interface.menu_ui;
			base(id, 760, ui.header.font_height + ui.controls.small_font_height + 25, 20, 15, ui.background_color_rgb);
			this.ui = ui;
		}

		public string? title {
			get { return _title; }
			set { _title = value; update(); }
		}
		public string? path {
			get { return _path; }
			set { _path = value; update(); }
		}		
	
		public void set_text(string? title, string? path, bool flip_screen=true) {
			_title = title;
			_path = path;
			update(flip_screen);
		}
		
		protected override void draw() {
			Rect rect = {0, 5};			
			Surface rendered_text;		
			if (_title != null && _title != "") {
				rendered_text = ui.header.render_text(_title);
				rect.x = (int16)(surface.w/2 - rendered_text.w/2);
				blit_surface(rendered_text, null, rect);
			}
			draw_horizontal_line(0, (int16)width, ui.header.font_height + 11, ui.controls.item_color);
			if (_path != null && _path != "") {
				rect.x = 10;
				rect.y += 20 + ui.header.font_height;
				rendered_text = ui.controls.render_text_small(_path);
				if (rendered_text.w > surface.w)
					blit_surface(rendered_text, {(int16)(rendered_text.w - surface.w),0, (int16)surface.w, (int16)rendered_text.h}, rect);
				else
					blit_surface(rendered_text, null, rect);
				
			}		
		}
		
	}
}
