using SDL;
using SDLTTF;

namespace Layers.MenuBrowser
{
	public class ChooserHeader : SurfaceLayer
	{
		unowned Font font;
		unowned Font font_small;
		string? _title;
		string? _path;
		
		public ChooserHeader(string id) {			
			base(id, 760, @interface.get_monospaced_font_height() + @interface.get_monospaced_small_font_height() + 5, 20, 20);
			font = @interface.get_monospaced_font();
			font_small = @interface.get_monospaced_small_font();
		}

		public string? title {
			get { return _title; }
			set { _title = value; update(); }
		}
		public string? path {
			get { return _path; }
			set { _path = value; update(); }
		}		
	
		public void set_text(string? title, string? path, bool flip_screen=true) {
			_title = title;
			_path = path;
			update(flip_screen);
		}
		
		protected override void draw() {
			Rect rect = {0, 0};			
			Surface rendered_text;		
			if (_title != null && _title != "") {
				rendered_text = font.render(_title, @interface.white_color);
				rect.x = (int16)(surface.w/2 - rendered_text.w/2);
				blit_surface(rendered_text, null, rect);
			}
			if (_path != null && _path != "") {
				rect.x = 0;
				rect.y += 5 + @interface.get_monospaced_font_height();
				rendered_text = font_small.render(_path, @interface.white_color);
				if (rendered_text.w > surface.w)
					blit_surface(rendered_text, {(int16)(rendered_text.w - surface.w),0, (int16)surface.w, (int16)rendered_text.h}, rect);
				else
					blit_surface(rendered_text, null, rect);
				
			}		
		}
		
	}
}
