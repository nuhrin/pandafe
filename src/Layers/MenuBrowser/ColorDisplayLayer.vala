using SDL;
using SDLTTF;

namespace Layers.MenuBrowser
{
	public class ColorDisplayLayer : SurfaceLayer
	{
		const uint MIN_CHAR_WIDTH = 8;
		
		Menus.Fields.ColorField field;
		unowned Font font;
		int16 font_height;		
		
		public ColorDisplayLayer(string id, int16 xpos, int16 ypos, Menus.Fields.ColorField color_field) {
			
			int width = (int)@interface.get_monospaced_font_width(MIN_CHAR_WIDTH) + 2;
			int height = width + (int)@interface.get_monospaced_font_height() - 10;
			base(id, width, height, xpos, ypos);
			font = @interface.get_monospaced_font();
			font_height = @interface.get_monospaced_font_height();
			field = color_field;
		}		
		
		protected override void draw() {
			draw_rectangle_outline(0,0, (int16)surface.w-1, (int16)surface.h-1, @interface.white_color);
			var dcolor = field.get_edited_color();			
			SDL.Color color = dcolor.get_sdl_color();
			int16 border = (int16)surface.h - font_height - 5;
			draw_rectangle_fill(1,1, (int16)surface.w-3, border, color);
			draw_rectangle_outline(0,border, (int16)surface.w, 1, @interface.white_color);
			var text = font.render_shaded(dcolor.spec, 
				(dcolor.value < 25)
					? @interface.white_color // may be to dark to display on black, use white
					: color,
				@interface.black_color);			
			blit_surface(text, null, {5, border + 3});
		}
	}
}
