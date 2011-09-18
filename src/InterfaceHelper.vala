using SDL;
using SDLTTF;

public class InterfaceHelper
{
	const int FONT_SIZE = 16;
	const int DEPTH = 32;

	Data.Preferences preferences;
	unowned SDL.Screen screen;

	Font font;
	int16 _font_height;
	Color _background_color;
	uint32 _background_color_rgb;
	Color _item_color;
	Color _selected_item_color;

	public InterfaceHelper(SDL.Screen* screen) {
		preferences = Data.preferences();
		this.screen = screen;
		update_from_preferences();
	}

	public void update_from_preferences() {
		font = new Font(preferences.font, FONT_SIZE);
		if (font == null) {
			GLib.error("Error loading font: %s", SDL.get_error());
		}
		_font_height = (int16)font.height();
		font_updated();
		_background_color = get_sdl_color(preferences.background_color);
		_background_color_rgb = this.screen.format.map_rgb(background_color.r, background_color.g, background_color.b);
		_item_color = get_sdl_color(preferences.item_color);
		_selected_item_color = get_sdl_color(preferences.selected_item_color);
		colors_updated();
	}
	public signal void font_updated();
	public signal void colors_updated();

	public unowned SDL.Color background_color { get { return _background_color; } }
	public uint32 background_color_rgb { get { return _background_color_rgb; } }
	public unowned SDL.Color item_color { get { return _item_color; } }
	public unowned SDL.Color selected_item_color { get { return _selected_item_color; } }

	public int16 font_height { get { return _font_height; } }
	public Surface render_text(string text) {
		return font.render_shaded(text, _item_color, _background_color);
	}
	public Surface render_text_selected(string text) {
		return font.render_shaded(text, _selected_item_color, _background_color);
	}
	public Surface render_text_blank(string text) {
		return font.render_shaded(text, _background_color, _background_color);
	}

	public Surface get_blank_surface(int width, int height) {
		return new Surface.RGB(SurfaceFlag.SWSURFACE, width, height, DEPTH, screen.format.Rmask, screen.format.Gmask, screen.format.Bmask, screen.format.Amask);
	}

	public int screen_fill(Rect? dst, uint32 color) {
		return screen.fill(dst, color);
	}
	public int screen_flip() {
		return screen.flip();
	}
	public int screen_blit(Surface src, Rect? srcrect, Rect? dstrect) {
		return src.blit(srcrect, screen, dstrect);
	}

	SDL.Color get_sdl_color(Gdk.Color color) {
		return { convert_color(color.red), convert_color(color.green), convert_color(color.blue) };
	}
	uchar convert_color(uint16 color) {
		return (255*color)/65535;
	}
}
