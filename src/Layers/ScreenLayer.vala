/* ScreenLayer.vala
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

namespace Layers
{
	public class ScreenLayer : LayerBase
	{
		uint32 background_color_rgb;
		public ScreenLayer(string id, uint32 background_color_rgb=0) {
			base(id);
			this.background_color_rgb = background_color_rgb;
		}

		public void flip() {
			@interface.screen_flip();
		}
		
		public void set_color(SDL.Color color) {
			set_rgb_color(@interface.map_rgb(color));
		}
		public void set_rgb_color(uint32 rgb_color) {
			background_color_rgb = rgb_color;
		}
		
		protected override void clear() { 
			@interface.screen_fill(null, background_color_rgb);
		}
		protected override void draw() { }
		protected override void blit_surface(Surface surface, Rect? source_rect, Rect dest_rect) {
			@interface.screen_blit(surface, source_rect, dest_rect);		
		}
		protected override void draw_rectangle_outline(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255) {
			@interface.draw_rectangle_outline(x, y, width, height, color, alpha);
		}
		protected override void draw_rectangle_fill(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255) {
			@interface.draw_rectangle_fill(x, y, width, height, color, alpha);
		}
		protected override void draw_horizontal_line(int16 x1, int16 x2, int16 y, SDL.Color color, uchar alpha=255) {
			@interface.draw_horizontal_line(x1, x2, y, color, alpha);
		}
		protected override void draw_vertical_line(int16 x, int16 y1, int16 y2, SDL.Color color, uchar alpha=255) {
			@interface.draw_vertical_line(x, y1, y2, color, alpha);
		}


		
	}
}
