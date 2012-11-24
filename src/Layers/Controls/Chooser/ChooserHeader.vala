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
			base(id, 760, @interface.get_monospaced_font_height() + @interface.get_monospaced_small_font_height() + 25, 20, 15);
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
			Rect rect = {0, 5};			
			Surface rendered_text;		
			if (_title != null && _title != "") {
				rendered_text = font.render(_title, @interface.white_color);
				rect.x = (int16)(surface.w/2 - rendered_text.w/2);
				blit_surface(rendered_text, null, rect);
			}
			draw_horizontal_line(0, (int16)width, @interface.get_monospaced_font_height() + 11, @interface.white_color);
			if (_path != null && _path != "") {
				rect.x = 10;
				rect.y += 20 + @interface.get_monospaced_font_height();
				rendered_text = font_small.render(_path, @interface.white_color);
				if (rendered_text.w > surface.w)
					blit_surface(rendered_text, {(int16)(rendered_text.w - surface.w),0, (int16)surface.w, (int16)rendered_text.h}, rect);
				else
					blit_surface(rendered_text, null, rect);
				
			}		
		}
		
	}
}
