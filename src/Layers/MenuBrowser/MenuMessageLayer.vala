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
			base(id, 780, font_height, 10, layer_height - font_height - 10);
			font = @interface.get_monospaced_font();
		}

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
		
		protected override void draw() {
			Rect rect = {0, 0};
			if (_error != null && _error != "")
				blit_surface(font.render(_error, @interface.white_color), null, rect);
			else if (_message != null && _message != "")
				blit_surface(font.render(_message, @interface.white_color), null, rect);
			else if (_help != null && _help != "")
				blit_surface(font.render(_help, @interface.white_color), null, rect);
		}
		
	}
}
