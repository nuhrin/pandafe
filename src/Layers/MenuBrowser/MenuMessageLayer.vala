/* MenuMessageLayer.vala
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
	public class MenuMessageLayer : SurfaceLayer
	{
		Menus.MenuUI.FooterUI ui;
		string? _error;
		string? _message;
		string? _help;
		
		public MenuMessageLayer(string id, int16 layer_height=480) {
			var ui = @interface.menu_ui.footer;
			base(id, 760, ui.font_height + 10, 20, layer_height - ui.font_height - 20, ui.background_color_rgb);
			this.ui = ui;
			ui.colors_updated.connect(update_colors);
		}
		public bool centered { get; set; }

		public string? error {
			get { return _error; }
			set { _error = value; update(); }
		}
		public string? message {
			get { return _message; }
			set { _message = value; update(); }
		}
		public string? help {
			get { return _help; }
			set { _help = value; update(); }
		}
	
		public void reset(bool flip=true) {
			_error = null;
			_message = null;
			_help = null;
			update(flip);
		}
		public void update_error(string? error, bool flip=true) {
			_error = error;
			update(flip);
		}
		public void update_message(string? message, bool flip=true) {
			_message = message;
			update(flip);
		}
		public void update_help(string? help, bool flip=true) {
			_help = help;
			update(flip);
		}
		public void set_text(string? error, string? message, string? help) {
			_error = error;
			_message = message;
			_help = help;
			update(false);
		}
		
		protected override void draw() {
			Rect rect = {35, 5};
			
			string? text = null;
			
			if (_error != null && _error != "")
				text = _error;
			else if (_message != null && _message != "")
				text = _message;
			else if (_help != null && _help != "")
				text = _help;
			
			if (text == null)
				return;
			
			var rendered = ui.render_text_to_fit(text, width);			
			
			if (centered == true)
				rect.x = (int16)(surface.w/2 - rendered.w/2);
				
			rect.y = (int16)(surface.h/2 - rendered.h/2);
			
			blit_surface(rendered, null, rect);
		}
		
		void update_colors() {
			update(false);
		}
	}
}
