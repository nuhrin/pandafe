/* TextEntry.vala
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

using SDL;
using SDLTTF;

namespace Layers.Controls
{
	public class TextEntry : Layers.SurfaceLayer, EventHandler
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
		string text;
		string original_text;
		
		Regex character_mask_regex;
		Regex? value_mask_regex;
		bool _is_valid_value;
		bool _error_thrown;
		
		public TextEntry(string id, int16 x, int16 y, int16 width, string? value=null, string? character_mask_regex=null, string? value_mask_regex=null) {
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
			
			initialize_character_mask_regex(character_mask_regex);
			initialize_value_mask_regex(value_mask_regex);
			
			//this.text = value ?? "";
			@interface.draw_rectangle_outline(0, 0, (int16)surface.w-2, (int16)surface.h-2, {255, 255, 255}, 255, surface);			
			set_text(value ?? "");
			_is_valid_value = is_valid_value();
			original_text = (has_valid_value) ? value : "";
		}		

		public string? run(uchar screen_alpha=128, uint32 rgb_color=0) {
			@interface.push_layer(this, screen_alpha, rgb_color);
			process_events();
			@interface.pop_layer();
			return text;
		}

		public string value {
			get { return text; }
			set { change_text(value); }
		}
		
		public bool has_valid_value { get { return _is_valid_value; } }
		
		public signal void text_changed(string text);
		public signal void validation_error();
		public signal void error_cleared();

		protected unowned string get_current_text_value() { return text; }
		protected void change_text(string new_text) {
			cursor_pos = new_text.length;
			update_text(new_text);
		}
		protected virtual void on_text_changed() { }
		protected virtual bool is_valid_value() { return true; }
		
		protected override void clear() { }
		protected override void draw() { }

		protected virtual void on_keydown_event(KeyboardEvent event) {
			if (process_unicode(event.keysym.unicode) == false)
				return;

			if (event.keysym.mod == KeyModifier.NONE) {
				switch(event.keysym.sym) {
					case KeySymbol.RETURN:
					case KeySymbol.KP_ENTER:
						if (has_valid_value == false) {
							validation_error();
							_error_thrown = true;
						} else
							quit_event_loop();
						break;
					case KeySymbol.ESCAPE:
						value = original_text ?? "";
						quit_event_loop();
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
						if (update_text_using_value_mask(text + c.to_string()) == true)
							return false;
						else
							cursor_pos--;
					} else {
						cursor_pos++;
						if (update_text_using_value_mask(text.splice(cursor_pos - 1, cursor_pos - 1, c.to_string())) == true)
							return false;
						else
							cursor_pos--;
					}
				}
			}
			return true;
		}
		bool character_is_valid(char c) {
			// return (c.isalnum() == true || c.ispunct() == true || c == ' ');
			return character_mask_regex.match(c.to_string());
		}
		bool update_text_using_value_mask(string new_text) {
			if (value_mask_regex != null && value_mask_regex.match(new_text) == false)
				return false;			
			update_text(new_text);
			return true;
		}
		void update_text(string? new_text=null) {
			set_text(new_text);
			if (new_text != null) {
				on_text_changed();
				this.text_changed(new_text);
			}
			_is_valid_value = is_valid_value();
			if (_is_valid_value == false) {
				validation_error();
				_error_thrown = true;
			}
			else if (_error_thrown == true) {
				_error_thrown = false;
				error_cleared();
			}
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
					//debug("in the beginning...");
					resolved_text = resolved_text.substring(0, max_characters);
				} else if (cursor_pos > text.length - half) {
					// end of string
					//debug("at the end...");
					resolved_text = resolved_text.substring(resolved_text.length - max_characters);
					relative_cursor_pos = (cursor_pos == text.length) ? max_characters - 1 : cursor_pos - (text.length - max_characters) - 1;
				} else {
					// middle of string
					//debug("(in the middle)");
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
			@interface.draw_rectangle_fill(cursor_x, cursor_y, char_width, cursor_height, @interface.highlight_color, 200, surface);

			surface.flip();
		}
		
		void initialize_character_mask_regex(string? regex) {
			try {
				if (regex != null) {
					this.character_mask_regex = new Regex(regex, RegexCompileFlags.OPTIMIZE);
					return;
				}
			}
			catch(RegexError e) {
				warning("Falling back to default character_mask_regex '%s' due to RegexError for '%s': %s", DEFAULT_CHARACTER_MASK, regex, e.message);				
			}
			try {
				this.character_mask_regex = new Regex(DEFAULT_CHARACTER_MASK, RegexCompileFlags.OPTIMIZE);
			}
			catch(RegexError e) {
				GLib.error("Unable to initialize default character_mask_regex '%s': %s", DEFAULT_CHARACTER_MASK, e.message);
			}
		}
		void initialize_value_mask_regex(string? regex) {
			if (regex == null) {
				value_mask_regex = null;
				return;
			}
			Regex? existing = value_mask_regex;
			try {
				if (regex != null) {
					this.value_mask_regex = new Regex(regex, RegexCompileFlags.OPTIMIZE);
					return;
				}
			}
			catch(RegexError e) {
				warning("Unable to initialize value_mask_regex '%s': %s", regex, e.message);
			}
			this.value_mask_regex = existing;
		}
	}
}
