using SDL;
using SDLTTF;

namespace Layers.Controls
{
	public class TextEntry : Layers.SurfaceLayer
	{
		const string DEFAULT_CHARACTER_MASK = "[[:alnum:][:punct:] ]";
		
		Surface blank_textarea;
		unowned Font font;
		int16 font_height;
		int16 x;
		int16 y;
		int16 max_text_width;
		int16 char_width;
		int max_characters;
		int cursor_pos;
		int16 cursor_y;
		int16 cursor_height;
		bool event_loop_done;
		string text;
		string original_text;
		
		Regex character_mask;

		public TextEntry(string id, int16 x, int16 y, int16 width, string? value=null, string? character_mask=null) {
			base(id, width, @interface.get_monospaced_font_height() + 10, x, y);
			font = @interface.get_monospaced_font();
			font_height = @interface.get_monospaced_font_height();
			this.x = x;
			this.y = y;
			blank_textarea = @interface.get_blank_surface(width - 6, font_height + 6);
			max_text_width = width - 8;
			char_width = (int16)font.render_shaded(" ", @interface.black_color, @interface.black_color).w;
			max_characters = max_text_width / char_width;
			cursor_y = 5 + (font_height / 3) * 2;
			cursor_height = font_height / 3;
			cursor_pos = (value != null) ? value.length : 0;
			
			this.character_mask = initialize_regex(character_mask, DEFAULT_CHARACTER_MASK, RegexCompileFlags.OPTIMIZE);
			//this.text = value ?? "";
			@interface.draw_rectangle_outline(0, 0, (int16)surface.w-2, (int16)surface.h-2, {255, 255, 255}, 255, surface);			
			set_text(value ?? "");		
			original_text = value;
		}
		Regex initialize_regex(string* regex, string* default_regex, RegexCompileFlags compile_options=0, RegexMatchFlags match_options=0) {
			try {
				if (regex != null)
					return new Regex(regex, compile_options, match_options);				
			}
			catch(RegexError e) {
				warning("Falling back to default regex '%s' due to RegexError for '%s': %s", default_regex, regex, e.message);				
			}
			try {
				return new Regex(default_regex, compile_options, match_options);
			}
			catch(RegexError e) {
				GLib.error("Unable to initialize default regex '%s': %s", default_regex, e.message);
			}
		}

		public string? run() {
			@interface.push_layer(this);
			drain_events();
			while(event_loop_done == false) {
				process_events();
				@interface.execute_idle_loop_work();
			}
			drain_events();
			@interface.pop_layer();
			return text;
		}

		public string value {
			get { return text; }
			set { text = value; }
		}
		public signal void text_changed(string text);

		protected override void clear() {
		}
		protected override void draw() {
			
		}

		void drain_events() {
			Event event;
			while(Event.poll(out event) == 1);
		}
		void process_events() {
			Event event;
			while(Event.poll(out event) == 1) {
				switch(event.type) {
					case EventType.QUIT:
						this.event_loop_done = true;
						break;
					case EventType.KEYDOWN:
						this.on_keyboard_event(event.key);
						break;
					default:
						break;
				}
			}
		}

		void on_keyboard_event (KeyboardEvent event) {
			if (process_unicode(event.keysym.unicode) == false)
				return;

			if (event.keysym.mod == KeyModifier.NONE) {
				switch(event.keysym.sym) {
					case KeySymbol.RETURN:
					case KeySymbol.KP_ENTER:
						event_loop_done = true;
						break;
					case KeySymbol.ESCAPE:
						this.event_loop_done = true;
						text = original_text;
						break;
					case KeySymbol.LEFT:
						if (cursor_pos > 0) {
							cursor_pos--;
							update_text();
						}
						break;
					case KeySymbol.RIGHT:
						if (cursor_pos < text.length) {
							cursor_pos++;
							update_text();
						}
						break;
					case KeySymbol.HOME:
						if (cursor_pos > 0) {
							cursor_pos = 0;
							update_text();
						}
						break;
					case KeySymbol.END:
						if (cursor_pos < text.length) {
							cursor_pos = text.length;
							update_text();
						}
						break;
					case KeySymbol.BACKSPACE:
						if (text.length > 0 && cursor_pos > 0) {
							cursor_pos--;
							if (cursor_pos == text.length - 1) {
								update_text(text.substring(0, text.length - 1));
							} else {
								update_text(text.splice(cursor_pos, cursor_pos + 1));
							}
						}
						break;
					case KeySymbol.DELETE:
						if (cursor_pos < text.length) {
							if (cursor_pos == text.length - 1)
								update_text(text.substring(0, text.length - 1));
							else
								update_text(text.splice(cursor_pos, cursor_pos + 1));
						}
						break;
					default:
						break;
				}
			}
		}
		bool process_unicode(uint16 unicode) {
			if (unicode <= uint8.MAX) {
				char c = (char)unicode;
				if (character_is_valid(c) == true) {
					if (cursor_pos == text.length) {
						cursor_pos++;
						update_text(text + c.to_string());
					} else {
						cursor_pos++;
						update_text(text.splice(cursor_pos - 1, cursor_pos - 1, c.to_string()));
					}
					return false;
				}
			}
			return true;
		}
		bool character_is_valid(char c) {
			// return (c.isalnum() == true || c.ispunct() == true || c == ' ');
			return character_mask.match(c.to_string());
		}

		void update_text(string? new_text=null) {
			set_text(new_text);
			if (new_text != null)
				this.text_changed(new_text);
			update();
		}
		void set_text(string? new_text=null) {
			if (new_text != null)
				this.text = new_text;

			var resolved_text = text + " ";
			int relative_cursor_pos = cursor_pos;
			int half = max_characters / 2;
			if (resolved_text.length > max_characters) {
				if (cursor_pos <= half) {
					// beginning of string
					debug("in the beginning...");
					resolved_text = resolved_text.substring(0, max_characters);
				} else if (cursor_pos > text.length - half) {
					// end of string
					debug("at the end...");
					resolved_text = resolved_text.substring(resolved_text.length - max_characters);
					relative_cursor_pos = (cursor_pos == text.length) ? max_characters - 1 : cursor_pos - (text.length - max_characters) - 1;
				} else {
					// middle of string
					debug("(in the middle)");
					relative_cursor_pos = half + (max_characters % 2) - 1;
					resolved_text = resolved_text.substring(cursor_pos - relative_cursor_pos, max_characters);
				}
			}
//~ 			debug("cursor[%d]: '%c', relative_cursor[%d]: '%c'",
//~ 				cursor_pos,
//~ 				(cursor_pos == text.length) ? ' ' : text[cursor_pos],
//~ 				relative_cursor_pos,
//~ 				resolved_text[relative_cursor_pos]);

			// clear text area
			Rect textarea_rect = {1, 1, max_text_width + 2};
			blank_textarea.blit(null, surface, textarea_rect);

			// render text
			Rect text_rect = {4, 5, max_text_width};
			font.render_shaded(resolved_text, @interface.white_color, @interface.black_color).blit(null, surface, text_rect);

			// render cursor
			int16 cursor_x = (int16)(relative_cursor_pos*char_width) + 4;
			@interface.draw_rectangle_fill(cursor_x, cursor_y, char_width, cursor_height, @interface.background_color, 200, surface);

			surface.flip();
		}
	}
}
