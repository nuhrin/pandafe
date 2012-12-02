/* ColorField.vala
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
using Catapult;
using Layers.Controls;
using Layers.MenuBrowser;
using Menus;	
using Menus.Fields;

namespace Fields
{
	public class ColorField : MenuItemField
	{
		Data.Color _color;
		
		public ColorField(string id, string name, string? help=null, Data.Color? color=null) {
			base(id, name, help);
			_color = new Data.Color();
			if (color != null)
				_color.copy_from(color);
		}

		public new Data.Color value {
			owned get { return _color; }
			set { change_value(value); }
		}
		
		public Data.Color? get_edited_color() { return _menu_color; }

		public override string get_value_text() { return _color.spec; }
		public override int get_minimum_menu_value_text_length() { return 7; } // "#000000"
//~ 		public override Surface? get_value_rendering(SDLTTF.Font* font) {
//~ 			unowned SDLTTF.Font f = font; 
//~ 			var color = _color.get_sdl_color();
//~ 			return f.render_shaded(get_value_text(), @interface.white_color, color);
//~ 		}
		
		protected override Value get_field_value() { return _color; }
		protected override void set_field_value(Value value) { change_value((Data.Color)value); }
		protected override bool has_value() { return true; }

		protected override void activate(Menus.MenuSelector selector) {
			var copy = _color.copy();
			show_menu(copy, menu => {
				if (_color.spec != copy.spec) {
					_color.copy_from(copy);
					changed();
					selector.update();
				}
				return true;
			});			
		}

		void change_value(Data.Color color) {
			if (_color.spec != color.spec) {
				_color.copy_from(color);
				changed();
			}
		}
		
		void show_menu(Data.Color color, owned Predicate<Menus.Menu> on_save) {
			_menu_color = color;
			_menu = new Menus.Menu(name, null, null, (owned)on_save);
			_red_menu_item = add_uint_field("r", "Red", null, color.red, 255);
			_green_menu_item = add_uint_field("g", "Green", null, color.green, 255);
			_blue_menu_item = add_uint_field("b", "Blue", null, _color.blue, 255);
			_hue_menu_item = add_uint_field("h", "Hue", null, _color.hue, 360);
			_saturation_menu_item = add_uint_field("s", "Saturation", null, _color.saturation, 100);
			_value_menu_item = add_uint_field("v", "Value", null, _color.value, 100);
			_menu.add_item(new Menus.MenuItem.cancel_item());
			_menu.add_item(new Menus.MenuItem.save_item());
			watch_rgb_fields();
			watch_hsv_fields();
			
			var browser = new MenuBrowser(_menu);
			var rect = browser.get_selector_rect();			
			_color_display = new ColorDisplayLayer("color_display", (int16)(rect.x + rect.w), 60, this);
			browser.add_layer(_color_display);
			browser.run();
			
		}
		UIntField add_uint_field(string id, string name, string? help, uint value, uint max) {
			UIntField field = new UIntField(id, name, help, value, 0, max);
			_menu.add_item(field);
			return field;
		}
		Menus.Menu _menu;
		Data.Color _menu_color;
		UIntField _red_menu_item;
		UIntField _green_menu_item;
		UIntField _blue_menu_item;
		UIntField _hue_menu_item;
		UIntField _saturation_menu_item;
		UIntField _value_menu_item;
		ColorDisplayLayer _color_display;
		void watch_rgb_fields() {
			_red_menu_item.changed.connect(rgb_field_changed);
			_green_menu_item.changed.connect(rgb_field_changed);
			_blue_menu_item.changed.connect(rgb_field_changed);
		}
		void ignore_rgb_fields() {
			_red_menu_item.changed.disconnect(rgb_field_changed);
			_green_menu_item.changed.disconnect(rgb_field_changed);
			_blue_menu_item.changed.disconnect(rgb_field_changed);
		}
		void watch_hsv_fields() {
			_hue_menu_item.changed.connect(hsv_field_changed);
			_saturation_menu_item.changed.connect(hsv_field_changed);
			_value_menu_item.changed.connect(hsv_field_changed);
		}
		void ignore_hsv_fields() {
			_hue_menu_item.changed.disconnect(hsv_field_changed);
			_saturation_menu_item.changed.disconnect(hsv_field_changed);
			_value_menu_item.changed.disconnect(hsv_field_changed);
		}
		void rgb_field_changed() {
			_menu_color.set_rgb((uchar)_red_menu_item.value, (uchar)_green_menu_item.value, (uchar)_blue_menu_item.value);
			ignore_hsv_fields();
			_hue_menu_item.value = _menu_color.hue;
			_saturation_menu_item.value = _menu_color.saturation;
			_value_menu_item.value = _menu_color.value;
			watch_hsv_fields();
			_color_display.update();
		}		
		void hsv_field_changed() {
			_menu_color.set_hsv((uint8)_hue_menu_item.value, (uint8)_saturation_menu_item.value, (uint8)_value_menu_item.value);
			ignore_rgb_fields();
			_red_menu_item.value = _menu_color.red;
			_green_menu_item.value = _menu_color.green;
			_blue_menu_item.value = _menu_color.blue;
			watch_rgb_fields();
			_color_display.update();
		}		

	}
}
