using SDL;

namespace Layers
{
	public abstract class SurfaceLayer : Layer
	{
		protected Surface surface;
		uint32 background_color_rgb;
		Rect dest_rect;
		protected SurfaceLayer(string id, int width, int height, int16 xpos=0, int16 ypos=0, uint32 rgb_color=0) {
			base(id);
			surface = @interface.get_blank_surface(width, height, rgb_color);
			background_color_rgb = rgb_color;
			dest_rect = {xpos, ypos};
		}
	
		protected override void blit() {
			if (parent != null)
				parent.blit_surface(surface, null, dest_rect);
			else if (screen != null)
				screen.blit_surface(surface, null, dest_rect);
		}				
		protected override void clear() { 
			surface.fill(null, background_color_rgb);
		}		
		protected override void blit_surface(Surface surface, Rect? source_rect, Rect dest_rect) {
			surface.blit(source_rect, this.surface, dest_rect);
		}
		protected override void draw_rectangle_outline(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255) {
			@interface.draw_rectangle_outline(x, y, width, height, color, alpha, surface);
		}
		protected override void draw_rectangle_fill(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255) {
			@interface.draw_rectangle_fill(x, y, width, height, color, alpha, surface);
		}

	}
}
