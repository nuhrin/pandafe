/* InterfaceHelper.vala
 * 
 * Copyright (C) 2012 nuhrin
 * 
 * This file is part of Pandafe.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *      nuhrin <nuhrin@oceanic.to>
 */

using Gee;
using SDL;
using SDLTTF;
using SDLGraphics;
using Layers;

public delegate void IdleFunction();

public InterfaceHelper @interface;

public class InterfaceHelper : Object
{
	public const string FONT_MONO_DEFAULT = "/usr/share/fonts/truetype/DejaVuSansMono.ttf";
	const int DEPTH = 32;
	const int IDLE_DELAY = 10;

	Data.Preferences preferences;
	unowned SDL.Screen screen;

	GameBrowserUI _game_browser_ui;
	Menus.MenuUI _menu_ui;

	HashMap<string, ulong> idle_function_hash;

	public InterfaceHelper(SDL.Screen* screen) {
		preferences = Data.preferences();
		this.screen = screen;
		idle_function_hash = new HashMap<string, ulong>();

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
	public void push_layer(Layer layer, uchar screen_alpha=0, uint32 rgb_color=0, bool flip_screen=true) {
		if (screen_alpha > 0) {
			var alpha_layer = new ScreenAlphaLayer(layer.id + "_alpha", screen_alpha, rgb_color);
			peek_screen_layer().push_layer(alpha_layer);
			alpha_layer.update(false);
		}
		peek_screen_layer().push_layer(layer);
		layer.update(flip_screen);
	}
	public Layer? pop_layer(bool flip_screen=true) {
		var screen = peek_screen_layer();
		var layer = screen.pop_layer();
		if (layer != null) {
			if ((layer is ScreenAlphaLayer) == false && peek_layer() is ScreenAlphaLayer)
				screen.pop_layer(); // remove alpha layer added by previous push			
			screen.update(flip_screen);
		}
		return layer;	
	}
	public Layer? peek_layer() {
		return peek_screen_layer().peek_layer();
	}

	public GameBrowserUI game_browser_ui {
		get {
			if (_game_browser_ui == null)
				_game_browser_ui = preferences.appearance.game_browser.create_ui();
			
			return _game_browser_ui;
		}
	}
	public Menus.MenuUI menu_ui {
		get {
			if (_menu_ui == null)
				_menu_ui = preferences.appearance.menu.create_ui();
			return _menu_ui;
		}
	}
	
	public uint32 map_rgb(SDL.Color color) { return this.screen.format.map_rgb(color.r, color.g, color.b); }
	
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
	public void draw_line(int16 x1, int16 y1, int16 x2, int16 y2, SDL.Color color, uchar alpha=255, Surface? surface=null) {	
		if (surface != null)
			Line.rgba(surface, x1, y1, x2, y2, color.r, color.g, color.b, alpha);
		else
			Line.rgba(screen, x1, y1, x2, y2, color.r, color.g, color.b, alpha);
	}
	public void draw_horizontal_line(int16 x1, int16 x2, int16 y, SDL.Color color, uchar alpha=255, Surface? surface=null) {	
		if (surface != null)
			Line.rgba_h(surface, x1, x2, y, color.r, color.g, color.b, alpha);
		else
			Line.rgba_h(screen, x1, x2, y, color.r, color.g, color.b, alpha);
	}
	public void draw_vertical_line(int16 x, int16 y1, int16 y2, SDL.Color color, uchar alpha=255, Surface? surface=null) {	
		if (surface != null)
			Line.rgba_v(surface, x, y1, y2, color.r, color.g, color.b, alpha);
		else
			Line.rgba_v(screen, x, y1, y2, color.r, color.g, color.b, alpha);
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
	
	public signal void quit_all();
	public signal void pandora_keyup_event();
	public bool pandora_keyup_event_handled { get; set; }
	
	public void cleanup_and_exit(owned ForEachFunc<string> message_action) {
		if (Data.pnd_mountset().has_mounted == true) {
 			message_action("Unmounting PNDs...");
			Data.pnd_mountset().unmount_all(name => message_action("Unmounting '%s'...".printf(name)));
		}
		quit_all();
	}
}
