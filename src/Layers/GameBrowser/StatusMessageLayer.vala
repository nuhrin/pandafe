using SDL;

namespace Layers.GameBrowser
{
	public class StatusMessageLayer : SurfaceLayer
	{		
		GameBrowserUI ui;
		string? _left;
		string? _center;
		string? _right;
		
		public StatusMessageLayer(string id, GameBrowserUI? ui=null, int16 layer_height=480) {
			GameBrowserUI resolved_ui = ui ?? @interface.game_browser_ui;
			base(id, 780, resolved_ui.font_height, 10, layer_height - resolved_ui.font_height - 10, resolved_ui.background_color_rgb);
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
		
		public new void set(string? left=null, string? center=null, string? right=null, bool flip_screen=true) {				
			_left = left;
			_center = center;
			_right = right;
			update(flip_screen);
		}
		public bool text_will_fit(string text) {
			return (ui.render_text_selected_fast(text).w <= width);
		}
		
		protected override void draw() {
			Rect rect = {0, 0};
			if (_left != null && _left != "") {
				blit_surface(ui.render_text_selected_fast(_left), null, rect);
			}
			Surface rendered_message;
			if (_center != null && _center != "") {
				rendered_message = ui.render_text_selected_fast(_center);
				rect.x = (int16)(surface.w/2 - rendered_message.w/2);
				blit_surface(rendered_message, null, rect);
			}
			if (_right != null && _right != "") {
				rendered_message = ui.render_text_selected_fast(_right);
				rect.x = (int16)(surface.w - rendered_message.w);
				blit_surface(rendered_message, null, rect);
			}			
		}		
	}
}
