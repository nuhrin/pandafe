using SDL;
using SDLTTF;

namespace Layers.MenuBrowser
{
	public class MenuHeaderLayer : SurfaceLayer
	{
		unowned Font font;
		string? _left;
		string? _center;
		string? _right;
		
		public MenuHeaderLayer(string id) {
			base(id, 760, @interface.get_monospaced_font_height(), 20, 20);
			font = @interface.get_monospaced_font();
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
	
		public void set_text(string? left, string? center, string? right, bool flip_screen=true) {
			_left = left;
			_center = center;
			_right = right;
			update(flip_screen);
		}
		
		protected override void draw() {
			Rect rect = {0, 0};
			if (_left != null && _left != "") {
				blit_surface(font.render(_left, @interface.white_color), null, rect);
			}
			Surface rendered_text;		
			if (_center != null && _center != "") {
				rendered_text = font.render(_center, @interface.white_color);
				rect.x = (int16)(surface.w/2 - rendered_text.w/2);
				blit_surface(rendered_text, null, rect);
			}
			if (_right != null && _right != "") {
				rendered_text = font.render(_right, @interface.white_color);
				rect.x = (int16)(surface.w - rendered_text.w);
				blit_surface(rendered_text, null, rect);
			}		
		}
		
	}
}
