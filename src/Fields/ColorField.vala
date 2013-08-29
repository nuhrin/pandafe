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
	public class ColorField : MenuItemField, SubMenuItem
	{
		Data.Color _color;
		ColorMenu _menu;
		string _menu_title;
		
		public ColorField(string id, string name, string? help=null, string? title=null, Data.Color? color=null) {
			base(id, name, help);
			_menu_title = title ?? help ?? name;
			_color = new Data.Color();
			if (color != null)
				_color.copy_from(color);
		}

		public new Data.Color value {
			owned get { return _color; }
			set { change_value(value); }
		}		
		
		public bool update_on_text_value_change { get; set; }
		
		public Menus.Menu menu { 
			get { 
				_menu = create_menu(_color);
				return _menu;
			}
		}
		public signal void selection_changed(Data.Color color);
				
		public override string get_value_text() { return _color.spec; }
		public override int get_minimum_menu_value_text_length() { return 7; } // "#000000"
		
		protected override Value get_field_value() { return _color; }
		protected override void set_field_value(Value value) { change_value((Data.Color)value); }
		protected override bool has_value() { return true; }

		protected override void activate(Menus.MenuSelector selector) {
			assert_not_reached();	
		}

		void change_value(Data.Color color) {
			if (_color.spec != color.spec) {
				_color.copy_from(color);
				changed();
			}
		}
		
		ColorMenu create_menu(Data.Color color) {
			var menu = new ColorMenu(name, color);
			menu.title = _menu_title;
			menu.update_on_text_value_change = update_on_text_value_change;
			menu.changed.connect(() => selection_changed(_menu.color));
			menu.saved.connect(() => {
				change_value(_menu.color);
				this.saved();
			});
			menu.cancelled.connect(() => {
				selection_changed(_color);
				this.cancelled();
			});
			menu.finished.connect(() => this.finished());
			menu.set_metadata("header_footer_reveal", "true");
			return menu;
		}

		public class ColorMenu : Menus.Menu {
			Data.Color _color;
			public ColorMenu(string name, Data.Color color) {
				base(name);
				_color = color.copy();
			}

			public signal void changed();
			public Data.Color color { get { return _color; } }
			public bool update_on_text_value_change { get; set; }
			
			protected override void populate_items(Gee.List<Menus.MenuItem> items) { 
				spec_field = new StringField("spec", "Color Spec", "Hex Code (#xxx or #xxxxxx) or Color Name", _color.spec);
				spec_field.set_minimum_menu_value_text_length(10);
				spec_field.add_entry_validator((value) => Data.Color.parse((string?)value, null), "invalid color");
				items.add(spec_field);
				items.add(new Menus.MenuItemSeparator());
				red_field = new UIntField("r", "Red", "0 - 255", _color.red, 0, 255);
				items.add(red_field);
				green_field = new UIntField("g", "Green", "0 - 255", _color.green, 0, 255);
				items.add(green_field);
				blue_field = new UIntField("b", "Blue", "0 - 255", _color.blue, 0, 255);
				items.add(blue_field);
				hue_field = new UIntField("h", "Hue", "0 - 360", _color.hue, 0, 360);
				items.add(hue_field);
				saturation_field = new UIntField("s", "Saturation", "0 - 100", _color.saturation, 0, 100);
				items.add(saturation_field);
				value_field = new UIntField("v", "Value", "0 - 100", _color.value, 0, 100);
				items.add(value_field);
				items.add(new Menus.MenuItemSeparator());
				items.add(new Menus.MenuItem.cancel_item());
				items.add(new Menus.MenuItem.save_item("Ok"));
				watch_rgb_fields();
				watch_hsv_fields();		
				watch_spec_field();	
			}
			protected override void cleanup() {
				clear_all_handlers();
				spec_field = null;
				red_field = null;
				green_field = null;
				blue_field = null;
				hue_field = null;
				saturation_field = null;
				value_field = null;
			}
			void watch_rgb_fields() {
				add_uint_handler(red_field, (f) => f.changed.connect(()=>rgb_field_changed()));
				add_uint_handler(green_field, (f) => f.changed.connect(()=>rgb_field_changed()));
				add_uint_handler(blue_field, (f) => f.changed.connect(()=>rgb_field_changed()));
				if (update_on_text_value_change) {
					add_uint_handler(red_field, (f) => f.text_value_changed.connect((v)=>rgb_field_changed((uchar)v, null, null)));
					add_uint_handler(green_field, (f) => f.text_value_changed.connect((v)=>rgb_field_changed(null, (uchar)v, null)));
					add_uint_handler(blue_field, (f) => f.text_value_changed.connect((v)=>rgb_field_changed(null, null, (uchar)v)));
				}
			}
			void ignore_rgb_fields() {
				clear_handlers(red_field);
				clear_handlers(blue_field);
				clear_handlers(green_field);
			}
			void watch_hsv_fields() {
				add_uint_handler(hue_field, (f) => f.changed.connect(()=>hsv_field_changed()));
				add_uint_handler(saturation_field, (f) => f.changed.connect(()=>hsv_field_changed()));
				add_uint_handler(value_field, (f) => f.changed.connect(()=>hsv_field_changed()));
				if (update_on_text_value_change) {
					add_uint_handler(hue_field, (f) => f.text_value_changed.connect((v)=>hsv_field_changed((uchar)v, null, null)));
					add_uint_handler(saturation_field, (f) => f.text_value_changed.connect((v)=>hsv_field_changed(null, (uchar)v, null)));
					add_uint_handler(value_field, (f) => f.text_value_changed.connect((v)=>hsv_field_changed(null, null, (uchar)v)));
				}
			}
			void ignore_hsv_fields() {
				clear_handlers(hue_field);
				clear_handlers(saturation_field);
				clear_handlers(value_field);				
			}
			void watch_spec_field() {
				add_handler(spec_field, (f) => f.changed.connect(() => spec_field_changed()));
			}
			void ignore_spec_field() {
				clear_handlers(spec_field);
			}
			void rgb_field_changed(uchar? red=null, uchar? green=null, uchar? blue=null) {
				uchar r = red ?? (uchar)red_field.value;
				uchar g = green ?? (uchar)green_field.value;
				uchar b = blue ?? (uchar)blue_field.value;
				_color.set_rgb(r, g, b);
				ignore_hsv_fields();
				ignore_spec_field();
				hue_field.value = _color.hue;
				saturation_field.value = _color.saturation;
				value_field.value = _color.value;
				spec_field.value = _color.spec;
				watch_hsv_fields();
				watch_spec_field();
				changed();
			}		
			void hsv_field_changed(uint8? hue=null, uint8? saturation=null, uint8? value=null) {
				uint8 h = hue ?? (uint8)hue_field.value;
				uint8 s = saturation ?? (uint8)saturation_field.value;
				uint8 v = value ?? (uint8)value_field.value;
				_color.set_hsv(h, s, v);
				ignore_rgb_fields();
				ignore_spec_field();
				red_field.value = _color.red;
				green_field.value = _color.green;
				blue_field.value = _color.blue;
				spec_field.value = _color.spec;
				watch_rgb_fields();
				watch_spec_field();
				changed();
			}
			void spec_field_changed() {
				_color.spec = spec_field.value;
				ignore_hsv_fields();
				ignore_rgb_fields();
				hue_field.value = _color.hue;
				saturation_field.value = _color.saturation;
				value_field.value = _color.value;
				red_field.value = _color.red;
				green_field.value = _color.green;
				blue_field.value = _color.blue;
				watch_hsv_fields();
				watch_rgb_fields();
				changed();
			}
			
			void add_handler(MenuItemField field, SignalConnect<MenuItemField> handler) {
				if (field_handlers == null)
					field_handlers = new HashMultiMap<MenuItemField,ulong>();
				field_handlers[field] = handler(field);
			}
			void add_uint_handler(UIntField field, SignalConnect<UIntField> handler) {
				if (field_handlers == null)
					field_handlers = new HashMultiMap<MenuItemField,ulong>();
				field_handlers[field] = handler(field);
			}
			void clear_handlers(MenuItemField field) {
				if (field_handlers == null || field_handlers.contains(field) == false)
					return;
				foreach(ulong handler in field_handlers[field])
					field.disconnect(handler);
				field_handlers.remove_all(field);
			}
			void clear_all_handlers() {
				if (field_handlers == null)
					return;
				foreach(var field in field_handlers.get_keys())  {
					foreach(ulong handler in field_handlers[field])
						field.disconnect(handler);
				}
				field_handlers.clear();
			}
			
			UIntField red_field;
			UIntField green_field;
			UIntField blue_field;
			UIntField hue_field;
			UIntField saturation_field;
			UIntField value_field;
			StringField spec_field;
			HashMultiMap<MenuItemField,ulong> field_handlers;
		}		
	}
}
