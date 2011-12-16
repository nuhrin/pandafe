using Gee;
using SDL;
using Catapult;
using Layers.Controls;

namespace Menus.Fields
{
	public class ColorField : MenuItemField
	{
		Data.Color _color;
		
		public ColorField(string id, string name, string? help=null, Data.Color color) {
			base(id, name, help);
			_color = color;
		}

		public new Data.Color value {
			owned get { return _color; }
			set { change_value(value); }
		}

		public override string get_value_text() { return _color.spec; }
		protected override Value get_field_value() { return _color; }
		protected override void set_field_value(Value value) { change_value((Data.Color)value); }

		protected override void activate(MenuSelector selector) {
			var menu = build_menu();
			var browser = new MenuBrowser(menu, 10, 10);
			//browser.add_layer(...)
			var spec_prior = _color.spec;
			browser.run();
			if (_color.spec != spec_prior) {
				changed();
				selector.update();
			}
		}

		void change_value(Data.Color color) {
			_color = color;
			changed();
		}
		
		Menu build_menu() {
			_menu = new Menu(name);
			_red_menu_item = add_uint_field("r", "Red", null, _color.red, 255);
			_green_menu_item = add_uint_field("g", "Green", null, _color.green, 255);
			_blue_menu_item = add_uint_field("b", "Blue", null, _color.blue, 255);
			_hue_menu_item = add_uint_field("h", "Hue", null, _color.hue, 360);
			_saturation_menu_item = add_uint_field("s", "Saturation", null, _color.saturation, 100);
			_value_menu_item = add_uint_field("v", "Value", null, _color.value, 100);
			_menu.add_item(new MenuItem.cancel_item());
			_menu.add_item(new MenuItem.save_item());
			watch_rgb_fields();
			watch_hsv_fields();
			return _menu;
		}
		UIntField add_uint_field(string id, string name, string? help, uint value, uint max) {
			UIntField field = new UIntField(id, name, help, value, 0, max);
			_menu.add_item(field);
			return field;
		}
		Menu _menu;
		UIntField _red_menu_item;
		UIntField _green_menu_item;
		UIntField _blue_menu_item;
		UIntField _hue_menu_item;
		UIntField _saturation_menu_item;
		UIntField _value_menu_item;
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
			_hue_menu_item.changed.connect(hsv_field_changed);
			_saturation_menu_item.changed.connect(hsv_field_changed);
			_value_menu_item.changed.connect(hsv_field_changed);
		}
		void rgb_field_changed() {
			debug("rgb changed");
			_color.set_rgb((uchar)_red_menu_item.value, (uchar)_green_menu_item.value, (uchar)_blue_menu_item.value);
			ignore_hsv_fields();
			_hue_menu_item.value = _color.hue;
			_saturation_menu_item.value = _color.saturation;
			_value_menu_item.value = _color.value;
			watch_hsv_fields();
		}		
		void hsv_field_changed() {
			_color.set_hsv((uint8)_hue_menu_item.value, (uint8)_saturation_menu_item.value, (uint8)_value_menu_item.value);
			ignore_rgb_fields();
			_red_menu_item.value = _color.red;
			_green_menu_item.value = _color.green;
			_blue_menu_item.value = _color.blue;
			watch_rgb_fields();
		}		

	}
}
