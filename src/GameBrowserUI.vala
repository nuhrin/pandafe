using SDL;
using SDLTTF;

public class GameBrowserUI
{
	const int FONT_SIZE = 14;
	public const int16 SELECTOR_WITDH = 600;

	Data.Preferences preferences;
	Font _font;
	string _font_path;
	int16 _font_height;
	SDL.Color _item_color;
	SDL.Color _selected_item_color;
	SDL.Color _background_color;
	uint32 _background_color_rgb;
	Surface _blank_item_surface;
	
	public GameBrowserUI(string font_path, SDL.Color item_color, SDL.Color selected_item_color, SDL.Color background_color) {
		preferences = Data.preferences();
		set_font(font_path);
		_item_color = item_color;
		_selected_item_color = selected_item_color;
		_background_color = background_color;
		_background_color_rgb = @interface.map_rgb(_background_color);
		_blank_item_surface = get_blank_background_surface(SELECTOR_WITDH, _font_height);
	}
	public GameBrowserUI.from_preferences() {
		preferences = Data.preferences();
		update_font_from_preferences();
		update_colors_from_preferences();
	}
	
	public unowned Font font { get { return _font; } }
	public unowned string font_path { get { return _font_path; } }
	public int16 font_height { get { return _font_height; } }
	public unowned SDL.Color item_color { get { return _item_color; } }
	public unowned SDL.Color selected_item_color { get { return _selected_item_color; } }
	public unowned SDL.Color background_color { get { return _background_color; } }
	public uint32 background_color_rgb { get { return _background_color_rgb; } }
	
	public signal void font_updated();
	public signal void colors_updated();
	
	public GameBrowserUI clone() {
		return new GameBrowserUI(_font_path, _item_color, _selected_item_color, _background_color);
	}
	
	public void set_font(string font_path) {
		_font = new Font(font_path, FONT_SIZE);
		if (_font == null) {
			GLib.error("Error loading font: %s", SDL.get_error());
		}
		_font_path = font_path;
		_font_height = (int16)font.height();
		_blank_item_surface = null;
		font_updated();
	}
	public void set_colors(SDL.Color item, SDL.Color selected_item, SDL.Color background) {
		_item_color = item;
		_selected_item_color = selected_item;
		_background_color = background;
		_background_color_rgb = @interface.map_rgb(_background_color);
		_blank_item_surface = null;
		colors_updated();
	}
	public void set_appearance(Data.GameBrowserAppearance appearance, Data.GameBrowserAppearance? fallback_appearance=null) {
		var ui = appearance.create_ui(fallback_appearance);
		set_font(ui._font_path);
		_item_color = ui._item_color;
		_selected_item_color = ui._selected_item_color;
		_background_color = ui._background_color;
		colors_updated();
	}
	
	public void update_font_from_preferences() {
		set_font(preferences.appearance.font);		
	}
	public void update_colors_from_preferences() {
		var appearance = preferences.appearance;
		set_colors(appearance.item_color.get_sdl_color(),
				   appearance.selected_item_color.get_sdl_color(),
				   appearance.background_color.get_sdl_color());
	}
	
	public unowned Surface get_blank_item_surface() { 
		if (_blank_item_surface == null)
			_blank_item_surface = get_blank_background_surface(SELECTOR_WITDH, _font_height);
		return _blank_item_surface; 
	}
	public Surface get_blank_background_surface(int width, int height) {
		return @interface.get_blank_surface(width, height, _background_color_rgb);
	}

	
	public Surface render_text(string text) {
		return _font.render_shaded(text, _item_color, _background_color);
	}
	public Surface render_text_selected(string text) {
		return _font.render_shaded(text, _selected_item_color, _background_color);
	}

	public Surface render_text_selected_fast(string text) {
		return _font.render(text, _selected_item_color);
	}
}
