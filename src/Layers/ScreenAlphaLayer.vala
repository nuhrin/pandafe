using SDL;

namespace Layers
{
	public class ScreenAlphaLayer : SurfaceLayer
	{
		public ScreenAlphaLayer(string id, uchar alpha, uint32 rgb_color=0) {
			base(id, @interface.screen_width, @interface.screen_height, 0, 0, rgb_color);
			surface.set_alpha(SurfaceFlag.RLEACCEL | SurfaceFlag.SRCALPHA, alpha);
		}
		
		protected override void draw() { }
	}
}
