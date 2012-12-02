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
		unowned Font font;
		string? _error;
		string? _message;
		string? _help;
		
		public MenuMessageLayer(string id, int16 layer_height=480) {
			int16 font_height = @interface.get_monospaced_font_height();
			base(id, 760, font_height + 10, 20, layer_height - font_height - 20);
			font = @interface.get_monospaced_font();
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
		public void update_help(string? help, bool flip=true) {
			_help = help;
			update(flip);
		}
		
		protected override void draw() {
			Rect rect = {35, 5};
			Surface rendered = null;

			if (_error != null && _error != "")
				rendered = font.render(_error, @interface.white_color);
			else if (_message != null && _message != "")
				rendered = font.render(_message, @interface.white_color);
			else if (_help != null && _help != "")
				rendered = font.render(_help, @interface.white_color);
			
			if (rendered == null)
				return;
			
			if (rendered.w > width) {
				unowned Font small_font = @interface.get_monospaced_small_font();
				if (_error != null && _error != "")
					rendered = small_font.render(_error, @interface.white_color);
				else if (_message != null && _message != "")
					rendered = small_font.render(_message, @interface.white_color);
				else if (_help != null && _help != "")
					rendered = small_font.render(_help, @interface.white_color);				
			}
			
			if (centered == true)
				rect.x = (int16)(surface.w/2 - rendered.w/2);
			
			blit_surface(rendered, null, rect);
		}		
	}
}
