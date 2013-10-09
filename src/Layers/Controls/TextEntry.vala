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

using Gee;
using SDL;
using SDLTTF;

namespace Layers.Controls
{
	public class TextEntry : Layers.SurfaceLayer, EventHandler
	{
		const string DEFAULT_CHARACTER_MASK = "[[:alnum:][:punct:] ]";
		
		TextEntryUI ui;
		Surface blank_textarea;
		int16 x;
		int16 y;
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
			this.common(id,x, y, new MenuTextEntryUI(width, @interface.menu_ui.controls), value, character_mask_regex, value_mask_regex);
		}		
		public TextEntry.browser(string id, int16 x, int16 y, int16 width, string? value=null, string? character_mask_regex=null, string? value_mask_regex=null){
			var ui = @interface.game_browser_ui;
			this.common(id,x, y, new BrowserTextEntryUI(width, ui, ui.list), value, character_mask_regex, value_mask_regex);
		}
		public TextEntry.browser_footer(string id, int16 x, int16 y, int16 width, string? value=null, string? character_mask_regex=null, string? value_mask_regex=null){
			var ui = @interface.game_browser_ui;
			this.common(id,x, y, new BrowserFooterTextEntryUI(width, ui, ui.footer), value, character_mask_regex, value_mask_regex);
		}
		TextEntry.common(string id, int16 x, int16 y, TextEntryUI ui, string? value=null, string? character_mask_regex=null, string? value_mask_regex=null) {
			base(id, ui.surface_width(), ui.surface_height(), x, y, ui.background_color_rgb);
			this.ui = ui;
			this.x = x;
			this.y = y;
			blank_textarea = ui.get_blank_textarea();
			cursor_y = ui.control_spacing_v + (ui.font_height / 3) * 2;
			cursor_height = ui.font_height / 3;
			cursor_pos = (value != null) ? value.length : 0;
			
			initialize_character_mask_regex(character_mask_regex);
			initialize_value_mask_regex(value_mask_regex);
			
			//int16 rect_width = (int16)(blank_textarea.w + (ui.control_spacing_h));
			@interface.draw_rectangle_outline(0, 0, (int16)surface.w-1, (int16)surface.h-1, ui.border_color(), 255, surface);			
			this.text = value ?? "";
			render_text();
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
		public signal void validation_error(string? error=null);
		public signal void error_cleared();

		public void add_validator(owned Predicate<string> is_valid, string error_if_invalid) {
			if (_validators == null)
				_validators = new ArrayList<Validator>();
			_validators.add(new Validator((owned)is_valid, error_if_invalid));
		}

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
						if (_validators != null) {
							if (_is_valid_value == true) {
								foreach(var validator in _validators) {
									if (validator.is_valid(text) == false) {
										_is_valid_value = false;
										validation_error(validator.error);
										_error_thrown = true;
										return;
									}
								}
							}
						}
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
			if (new_text != null) {
				this.text = new_text;
				on_text_changed();
				this.text_changed(new_text);
			}
				
			_is_valid_value = is_valid_value();			
			if (_is_valid_value == false) {
				validation_error();
				_error_thrown = true;
			} else if (_error_thrown == true) {
				_error_thrown = false;
				error_cleared();
			}			
			
			render_text();			
			update();
		}
		void render_text() {
			int16 cursor_x;
			int16 cursor_width;
			var visible_text = ui.get_visible_text(text, cursor_pos, out cursor_x, out cursor_width);

			// clear text area
			Rect textarea_rect = {1, 1, ui.max_text_width + 2};
			blank_textarea.blit(null, surface, textarea_rect);

			// render text
			Rect text_rect = {ui.control_spacing_h, ui.control_spacing_v, ui.max_text_width};
			ui.render_text(visible_text).blit(null, surface, text_rect);

			// render cursor
			@interface.draw_rectangle_fill(cursor_x, cursor_y, cursor_width, cursor_height, ui.cursor_color(), 200, surface);

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
		
		class Validator {
			Predicate<string> predicate;
			string _error;
			public Validator(owned Predicate<string> is_valid, string error_if_invalid) {
				predicate = (owned)is_valid;
				_error = error_if_invalid;
			}
			public bool is_valid(string value) { return predicate(value); }
			public unowned string error { get { return _error; } }
		}
		ArrayList<Validator> _validators;
		
		class MenuTextEntryUI: TextEntryUI 
		{
			Menus.MenuUI.ControlsUI ui;
			int max_characters;
			int16 char_width;
			public MenuTextEntryUI(int16 requested_width, Menus.MenuUI.ControlsUI ui) {
				base(requested_width, ui);
				this.ui = ui;
				char_width = ui.font_width();
				max_characters = max_text_width / char_width;
			}
			
			public override uint32 background_color_rgb { get { return ui.background_color_rgb; } }
			public override unowned SDL.Color border_color() { return ui.border_color; }
			public override unowned SDL.Color cursor_color() { return ui.text_cursor_color; }
			public override int16 control_spacing_v { get { return ui.value_control_spacing; } }
			public override int16 control_spacing_h { get { return ui.value_control_spacing; } }
			public override int surface_width() { return (max_characters * ui.font_width()) + (control_spacing_h * 2) + 1; }

			public override Surface render_text(string text) { return ui.render_text(text); }
			public override Surface get_blank_textarea() {
				return ui.get_blank_background_surface((int16)((max_characters * char_width) + control_spacing_h)-1, ui.font_height + control_spacing_v);
			}

			public override string get_visible_text(string text, int cursor_pos, out int16 cursor_x, out int16 cursor_width) {
				var visible_text = text + " ";
				int relative_cursor_pos = cursor_pos;
				int half = max_characters / 2;
				if (visible_text.length > max_characters) {
					if (cursor_pos <= half) {
						// beginning of string
						//debug("in the beginning...");
						visible_text = visible_text.substring(0, max_characters);
					} else if (cursor_pos > text.length - half) {
						// end of string
						//debug("at the end...");
						visible_text = visible_text.substring(visible_text.length - max_characters);
						relative_cursor_pos = (cursor_pos == text.length) ? max_characters - 1 : cursor_pos - (text.length - max_characters) - 1;
					} else {
						// middle of string
						//debug("(in the middle)");
						relative_cursor_pos = half + (max_characters % 2) - 1;
						visible_text = visible_text.substring(cursor_pos - relative_cursor_pos, max_characters);
					}
				}				
//~ 			debug("cursor[%d]: '%c', relative_cursor[%d]: '%c'",
//~ 				cursor_pos,
//~ 				(cursor_pos == text.length) ? ' ' : text[cursor_pos],
//~ 				relative_cursor_pos,
//~ 				visible_text[relative_cursor_pos]);

				cursor_x = (int16)(relative_cursor_pos*char_width) + control_spacing_h;
				cursor_width = char_width;
				return visible_text;
			}

			protected override int16 calculate_max_text_width(int16 requested_width) { return requested_width - control_spacing_h; }
		}
		class BrowserTextEntryUI: TextEntryUI 
		{
			protected GameBrowserUI ui;
			public BrowserTextEntryUI(int16 requested_width, GameBrowserUI ui, Data.Appearances.AppearanceAreaUI fontui) {
				base(requested_width, fontui);
				this.ui = ui;
			}
			
			public override uint32 background_color_rgb { get { return ui.background_color_rgb; } }
			public override unowned SDL.Color border_color() { return ui.list.selected_item_background_color; }
			public override unowned SDL.Color cursor_color() { return ui.list.selected_item_background_color; }
			public override int16 control_spacing_v { get { return ui.list.spacing.item_v; } }
			public override int16 control_spacing_h { get { return ui.list.spacing.item_h; } }
			public override int surface_width() { return max_text_width + (control_spacing_h * 2) + 1; }
			
			public override Surface render_text(string text) { return ui.list.render_text(text); }
			public override Surface get_blank_textarea() {
				return ui.get_blank_background_surface((int16)(max_text_width + (control_spacing_h * 2)) -1, font_height + control_spacing_v);
			}
			
			public override string get_visible_text(string text, int cursor_pos, out int16 cursor_x, out int16 cursor_width) {
				string visible_text = text + " ";
				int relative_cursor_pos = cursor_pos;
				
				if (fontui.get_text_width(visible_text) > max_text_width) {
					var full_text = visible_text;
					int16 half_window = max_text_width / 2;
					// get left text fitting window and max cursor pos for rendering at front of string
					int pos=0;
					int front_max_cursor_pos = 0;
					StringBuilder sb = new StringBuilder(full_text.substring(pos, 1));
					int width = fontui.get_text_width(sb.str);
					while (width <= max_text_width) {
						if (width <= half_window)
							front_max_cursor_pos++;
						sb.append(full_text.substring(pos + 1, 1));
						width = fontui.get_text_width(sb.str);
						pos++;
					}
					string left_text = full_text.substring(0, pos);
					// get right text fitting window and max cursor pos for rendering at end of string
					pos = full_text.length - 1;
					int end_max_cursor_pos = pos + 1;
					sb = new StringBuilder(full_text.substring(pos, 1));
					width = fontui.get_text_width(sb.str);
					while (width <= max_text_width) {
						if (width <= half_window)
							end_max_cursor_pos--;
						sb.append(full_text.substring(pos - 1, 1));
						width = fontui.get_text_width(sb.str);
						pos--;
					}
					string right_text = full_text.substring(pos+1);
					
					if (cursor_pos <= front_max_cursor_pos) {
						// beginning of string
						visible_text = left_text;
					} else if (cursor_pos >= end_max_cursor_pos) {
						// end of string
						visible_text = right_text;
						int right_text_start_pos = (full_text.length - right_text.length);
						relative_cursor_pos =  cursor_pos - right_text_start_pos;
					} else {
						// middle of string
						cursor_width = (int16)fontui.get_text_width(full_text.substring(cursor_pos, 1));
						int16 side_window = (max_text_width - cursor_width) / 2;
						pos = cursor_pos - 1;
						sb = new StringBuilder(full_text.substring(pos, 1));
						while (fontui.get_text_width(sb.str) <= side_window) {
							sb.append(full_text.substring(pos - 1, 1));
							pos--;
						}
						int left_index = pos;
						pos = cursor_pos + 1;
						int length = cursor_pos - left_index;
						sb = new StringBuilder(full_text.substring(left_index, length + 1));
						while (pos < full_text.length && fontui.get_text_width(sb.str) <= max_text_width) {
							sb.append(full_text.substring(pos, 1));
							pos++;
							length++;
						}
						visible_text = full_text.substring(left_index, length);
						relative_cursor_pos = cursor_pos - left_index;
					}
				}
				
				cursor_x = (int16)fontui.get_text_width(visible_text.substring(0, relative_cursor_pos)) + control_spacing_h;
				cursor_width = (int16)fontui.get_text_width(visible_text.substring(relative_cursor_pos, 1));
				return visible_text;
			}			

			protected override int16 calculate_max_text_width(int16 requested_width) { return requested_width - (control_spacing_h * 2); }			
		}
		class BrowserFooterTextEntryUI: BrowserTextEntryUI
		{
			public BrowserFooterTextEntryUI(int16 requested_width, GameBrowserUI ui, Data.Appearances.AppearanceAreaUI fontui) {
				base(requested_width, ui, fontui);
			}
			public override unowned SDL.Color border_color() { return ui.footer.text_color; }
			public override unowned SDL.Color cursor_color() { return ui.footer.text_color; }
			public override int16 control_spacing_h { get { return (int16)ui.footer.get_text_width(" "); } }
			public override Surface render_text(string text) { return ui.footer.render_text(text); }
		} 
		abstract class TextEntryUI 
		{
			protected Data.Appearances.AppearanceAreaUI fontui;
			int16 requested_width;
			int16 _max_text_width;
			protected TextEntryUI(int16 requested_width, Data.Appearances.AppearanceAreaUI fontui) {
				this.requested_width = requested_width;
				this.fontui = fontui;
				_max_text_width = -1;
			}

			public int16 max_text_width { 
				get {
					if (_max_text_width == -1)
						_max_text_width = calculate_max_text_width(requested_width);
					return _max_text_width;
				}
			}
			public int16 font_height { get { return fontui.font_height;} }
			public int surface_height() { return fontui.font_height + (control_spacing_v * 2); }			

			public abstract uint32 background_color_rgb { get; }
			public abstract unowned SDL.Color border_color();
			public abstract unowned SDL.Color cursor_color();
			public abstract int16 control_spacing_v { get; }
			public abstract int16 control_spacing_h { get; }
			public abstract int surface_width();
			
			public abstract Surface render_text(string text);
			public abstract Surface get_blank_textarea();
			
			public abstract string get_visible_text(string text, int cursor_pos, out int16 cursor_x, out int16 cursor_width);

			protected abstract int16 calculate_max_text_width(int16 requested_width);
		}
	}
}
