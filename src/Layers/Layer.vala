using SDL;

namespace Layers
{
	public abstract class Layer : LayerBase
	{
		public Layer(string id) {
			base(id);
		}
		protected override void clear() { }
		
		protected override void blit_surface(Surface surface, Rect? source_rect, Rect dest_rect) {
			if (parent != null)
				parent.blit_surface(surface, source_rect, dest_rect);
			else if (screen != null)
				screen.blit_surface(surface, source_rect, dest_rect);
			else
				debug("no parent or screen found for layer: %s", id);
		}
		
		public ScreenLayer? screen { owned get { return get_owning_screen(); } }
		public Layer? parent { owned get { return get_parent_layer(); } }
	}
}
