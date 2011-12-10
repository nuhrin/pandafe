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

		
	}
}
