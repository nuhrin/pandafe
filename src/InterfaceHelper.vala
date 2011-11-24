using Gee;
using SDL;
using SDLTTF;
using SDLGraphics;
using Layers;

public delegate void IdleFunction();

public InterfaceHelper @interface;

public class InterfaceHelper : Object
{
	const string FONT_MONO = "/usr/share/fonts/truetype/DejaVuSansMono.ttf";
	const int IDLE_DELAY = 10;
	public const int16 SELECTOR_WITDH = 440;
	public const int SELECTOR_VISIBLE_ITEMS = 15;
	public const int16 SELECTOR_ITEM_SPACING = 5;

	const int FONT_SIZE = 16;
	const int DEPTH = 32;

	Data.Preferences preferences;
	unowned SDL.Screen screen;

	Font font;
	Font font_mono;
	int16 font_mono_char_width;
	int16 font_mono_height;
	int16 _font_height;
	Surface _blank_item_surface;
	Color _background_color;
	uint32 _background_color_rgb;
	Color _item_color;
	Color _selected_item_color;
	Color _black_color;
	Color _white_color;
	uint32 _white_color_rgb;

	HashMap<string, ulong> idle_function_hash;

	public InterfaceHelper(SDL.Screen* screen) {
		preferences = Data.preferences();
		this.screen = screen;
		idle_function_hash = new HashMap<string, ulong>();

		_black_color = {0, 0, 0};
		_white_color = {255, 255, 255};
		_white_color_rgb = this.screen.format.map_rgb(255, 255, 255);

		font_mono = new Font(FONT_MONO, FONT_SIZE);
		if (font_mono == null) {
			GLib.error("Error loading monospaced font: %s", SDL.get_error());
		}
		font_mono_height = (int16)font_mono.height();
		font_mono_char_width = (int16)font_mono.render_shaded(" ", _black_color, _black_color).w;

		update_from_preferences();
		
		screen_layer_stack = new GLib.Queue<ScreenLayer>();
		screen_layer_stack.push_head(new ScreenLayer("root_screen"));
	}

	public void push_screen_layer(ScreenLayer screen_layer, bool do_update=true) {
		screen_layer_stack.push_head(screen_layer);
		if (do_update)
			screen_layer.update();
	}
	public ScreenLayer? pop_screen_layer() {
		if (screen_layer_stack.get_length() < 2)
			return null;
		var layer = screen_layer_stack.pop_head();
		screen_layer_stack.peek_head().update();
		return layer;
	}
	public unowned ScreenLayer peek_screen_layer() { 
		return screen_layer_stack.peek_head();
	}
	public void push_layer(Layer layer) {
		peek_screen_layer().push_layer(layer);
		layer.update();
	}
	public Layer? pop_layer() {
		var screen = peek_screen_layer();
		var layer = screen.pop_layer();
		if (layer != null)
			screen.update();
		return layer;	
	}
	public Layer? peek_layer() {
		return peek_screen_layer().peek_layer();
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
		_blank_item_surface = get_blank_background_surface(SELECTOR_WITDH, _font_height);
		colors_updated();
	}
	public signal void font_updated();
	public signal void colors_updated();

	public unowned SDL.Color background_color { get { return _background_color; } }
	public uint32 background_color_rgb { get { return _background_color_rgb; } }
	public unowned SDL.Color item_color { get { return _item_color; } }
	public unowned SDL.Color selected_item_color { get { return _selected_item_color; } }
	public unowned SDL.Color black_color { get { return _black_color; } }
	public unowned SDL.Color white_color { get{ return _white_color; } }
	public uint32 white_color_rgb { get { return _white_color_rgb; } }

	public uint32 map_rgb(SDL.Color color) { return this.screen.format.map_rgb(color.r, color.g, color.b); }

	public Surface render_text(string text) {
		return font.render_shaded(text, _item_color, _background_color);
	}
	public Surface render_text_selected(string text) {
		return font.render_shaded(text, _selected_item_color, _background_color);
	}
	public Surface render_text_with_color(string text, SDL.Color color, SDL.Color background_color) {
		return font.render_shaded(text, color, background_color);
	}
	public Surface render_text_selected_fast(string text) {
		return font.render(text, _selected_item_color);
	}

	public int16 font_height { get { return _font_height; } }
	public unowned Font get_monospaced_font() { return font_mono; }
	public int16 get_monospaced_font_width(uint chars=1) { return (int16)(font_mono_char_width * chars); }
	public int16 get_monospaced_font_height() { return font_mono_height; }

	public unowned Surface get_blank_item_surface() { return _blank_item_surface; }

	public Surface get_blank_surface(int width, int height, uint32 rgb_color=0) {
		var surface = new Surface.RGB(SurfaceFlag.SWSURFACE, width, height, DEPTH, 0, 0, 0, 0);
		if (rgb_color > 0)
			surface.fill(null, rgb_color);
		return surface;
	}
	public Surface get_blank_background_surface(int width, int height) {
		return get_blank_surface(width, height, _background_color_rgb);
	}
	public Surface get_blank_surface_color(int width, int height, SDL.Color color) {
		return get_blank_surface(width, height, map_rgb(color));
	}

	public void draw_rectangle_outline(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255, Surface surface=screen) {
		Rectangle.outline_rgba(surface, x, y, x+width, y+height, color.r, color.g, color.b, alpha);
	}
	public void draw_rectangle_fill(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255, Surface surface=screen) {
		Rectangle.fill_rgba(surface, x, y, x+width, y+height, color.r, color.g, color.b, alpha);
	}
	public void dim_screen(int percentage) {
		dim_surface(percentage, screen);
	}
	public void dim_surface(int percentage, Surface surface) {
		Rectangle.fill_rgba(surface, 0, 0, (int16)surface.w, (int16)surface.h, 0, 0, 0, (uchar)(2.55*percentage));
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

	public void connect_idle_function(string name, IdleFunction function) {
		disconnect_idle_function(name);
		idle_function_hash[name] = this.idle_worker.connect(() => function());
	}
	public void disconnect_idle_function(string name) {
		if (idle_function_hash.has_key(name) == true) {
			this.disconnect(idle_function_hash[name]);
			idle_function_hash.unset(name);
		}
	}
	public void execute_idle_loop_work() {
		if (idle_function_hash.size > 0)
			idle_worker();
		else
			SDL.Timer.delay(IDLE_DELAY);
	}
	signal void idle_worker();

	SDL.Color get_sdl_color(Gdk.Color color) {
		return { convert_color(color.red), convert_color(color.green), convert_color(color.blue) };
	}
	uchar convert_color(uint16 color) {
		return (255*color)/65535;
	}

	GLib.Queue<ScreenLayer> screen_layer_stack;
}
