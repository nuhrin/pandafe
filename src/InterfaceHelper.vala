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
	public const int SELECTOR_VISIBLE_ITEMS = 15;
	public const int16 SELECTOR_ITEM_SPACING = 5;

	const int FONT_SIZE = 16;
	const int FONT_SMALL_SIZE = 12;
	const int DEPTH = 32;

	Data.Preferences preferences;
	unowned SDL.Screen screen;

	GameBrowserUI _game_browser_ui;
	Font font_mono;
	Font font_mono_small;
	int16 font_mono_char_width;
	int16 font_mono_height;
	int16 font_mono_small_height;
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

		font_mono_small = new Font(FONT_MONO, FONT_SMALL_SIZE);
		font_mono_small_height = (int16)font_mono_small.height();
		
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
	public void push_layer(Layer layer, uchar screen_alpha=0, uint32 rgb_color=0) {
		if (screen_alpha > 0) {
			var alpha_layer = new ScreenAlphaLayer(layer.id + "_alpha", screen_alpha, rgb_color);
			peek_screen_layer().push_layer(alpha_layer);
			alpha_layer.update();
		}
		peek_screen_layer().push_layer(layer);
		layer.update();
	}
	public Layer? pop_layer() {
		var screen = peek_screen_layer();
		var layer = screen.pop_layer();
		if (layer != null) {
			if ((layer is ScreenAlphaLayer) == false && peek_layer() is ScreenAlphaLayer)
				screen.pop_layer(); // remove alpha layer added by previous push			
			screen.update();
		}
		return layer;	
	}
	public Layer? peek_layer() {
		return peek_screen_layer().peek_layer();
	}

	public GameBrowserUI game_browser_ui {
		get {
			if (_game_browser_ui == null) {
				_game_browser_ui = new GameBrowserUI(preferences.font, 
					preferences.item_color.get_sdl_color(),
					preferences.selected_item_color.get_sdl_color(),
					preferences.background_color.get_sdl_color());
			}
			return _game_browser_ui;
		}
	}
	public unowned SDL.Color black_color { get { return _black_color; } }
	public unowned SDL.Color white_color { get{ return _white_color; } }
	public uint32 white_color_rgb { get { return _white_color_rgb; } }
	public unowned SDL.Color highlight_color { get { return game_browser_ui.background_color; } }
	public uint32 highlight_color_rgb { get { return game_browser_ui.background_color_rgb; } }

	public uint32 map_rgb(SDL.Color color) { return this.screen.format.map_rgb(color.r, color.g, color.b); }

	public unowned Font get_monospaced_font() { return font_mono; }
	public int16 get_monospaced_font_width(uint chars=1) { return (int16)(font_mono_char_width * chars); }
	public int16 get_monospaced_font_height() { return font_mono_height; }
	public unowned Font get_monospaced_small_font() { return font_mono_small; }
	public int16 get_monospaced_small_font_height() { return font_mono_small_height; }

	public Surface get_blank_surface(int width, int height, uint32 rgb_color=0) {
		var surface = new Surface.RGB(SurfaceFlag.SWSURFACE, width, height, DEPTH, 0, 0, 0, 0);
		if (rgb_color > 0)
			surface.fill(null, rgb_color);
		return surface;
	}
	public Surface get_blank_surface_color(int width, int height, SDL.Color color) {
		return get_blank_surface(width, height, map_rgb(color));
	}

	public void draw_rectangle_outline(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255, Surface? surface=null) {
		if (surface != null)
			Rectangle.outline_rgba(surface, x, y, x+width, y+height, color.r, color.g, color.b, alpha);
		else
			Rectangle.outline_rgba(screen, x, y, x+width, y+height, color.r, color.g, color.b, alpha);
	}
	public void draw_rectangle_fill(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255, Surface? surface=null) {
		if (surface != null)
			Rectangle.fill_rgba(surface, x, y, x+width, y+height, color.r, color.g, color.b, alpha);
		else
			Rectangle.fill_rgba(screen, x, y, x+width, y+height, color.r, color.g, color.b, alpha);
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
	public int screen_width { get { return screen.w; } }
	public int screen_height { get { return screen.h; } }

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

	GLib.Queue<ScreenLayer> screen_layer_stack;
	
	public void ensure_gtk_init() {
		if (gtk_is_initialized == true)
			return;
		unowned string[] args = NULL_ARGS;
		Gtk.init(ref args);
	}
	static bool gtk_is_initialized;	
	static string[] NULL_ARGS = null;
}
