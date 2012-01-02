using SDL;
using SDLTTF;

namespace Layers.GameBrowser
{
	public class HeaderLayer : SurfaceLayer
	{
		GameBrowserUI ui;
		string? _left;
		string? _center;
		string? _right;
				
		public HeaderLayer(string id, int16 ypos=20, GameBrowserUI? ui=null) {
			GameBrowserUI resolved_ui = (GameBrowserUI)ui ?? @interface.game_browser_ui;
			base(id, 760, resolved_ui.font_height, 20, ypos, resolved_ui.background_color_rgb);
			this.ui = resolved_ui;			
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
				blit_surface(ui.render_text_selected_fast(_left), null, rect);
			}
			Surface rendered_text;		
			if (_center != null && _center != "") {
				rendered_text = ui.render_text_selected_fast(_center);
				rect.x = (int16)(surface.w/2 - rendered_text.w/2);
				blit_surface(rendered_text, null, rect);
			}
			if (_right != null && _right != "") {
				rendered_text = ui.render_text_selected_fast(_right);
				rect.x = (int16)(surface.w - rendered_text.w);
				blit_surface(rendered_text, null, rect);
			}		
		}
		
	}
}
