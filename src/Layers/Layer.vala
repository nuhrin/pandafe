using SDL;

namespace Layers
{
	public abstract class Layer : LayerBase
	{
		public Layer(string id) {
			base(id);
		}
		public ScreenLayer? screen { owned get { return get_owning_screen(); } }
		public Layer? parent { owned get { return get_parent_layer(); } }

		protected override void clear() { }		
		protected override void blit_surface(Surface surface, Rect? source_rect, Rect dest_rect) {
			var target = get_target_layer();
			if (target != null)
				target.blit_surface(surface, source_rect, dest_rect);
			else
				debug("no parent or screen found for layer: %s", id);
		}
		protected override void draw_rectangle_outline(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255) {
			var target = get_target_layer();
			if (target != null)
				target.draw_rectangle_outline(x, y, width, height, color, alpha);
			else
				debug("no parent or screen found for layer: %s", id);
		}
		protected override void draw_rectangle_fill(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255) {
			var target = get_target_layer();
			if (target != null)
				target.draw_rectangle_fill(x, y, width, height, color, alpha);
			else
				debug("no parent or screen found for layer: %s", id);
		}
		protected override void draw_horizontal_line(int16 x1, int16 x2, int16 y, SDL.Color color, uchar alpha=255) {
			var target = get_target_layer();
			if (target != null)
				target.draw_horizontal_line(x1, x2, y, color, alpha);
			else
				debug("no parent or screen found for layer: %s", id);
		}
		protected override void draw_vertical_line(int16 x, int16 y1, int16 y2, SDL.Color color, uchar alpha=255) {
			var target = get_target_layer();
			if (target != null)
				target.draw_vertical_line(x, y1, y2, color, alpha);
			else
				debug("no parent or screen found for layer: %s", id);
		}

				
		LayerBase? get_target_layer() { return (LayerBase?)parent ?? (LayerBase?)screen; }
	}
}
