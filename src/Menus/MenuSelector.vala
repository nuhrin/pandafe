using SDL;
using SDLTTF;
using Gee;
using Menus.Fields;

namespace Menus
{
	public class MenuSelector : Layers.Layer
	{
		int16 xpos;
		int16 ypos;
		Menu _menu;
		uint8 max_name_length;
		uint8 max_value_length;
		Surface surface;
		unowned Font font;
		int16 font_height;
		int _height;
		int _width;
		uint8 max_name_length_real;
		int16 x_pos_value;
		string field_item_format;
		string menu_item_format;
		Surface blank_name_area;
		Surface select_name_area;
		Surface blank_value_area;

		bool has_field;
		int visible_items;
		int item_spacing;
		int index_before_select_first;
		int index_before_select_last;

		public MenuSelector(string id, int16 xpos, int16 ypos, Menu menu, uint8 max_name_length, uint8 max_value_length) {
			base(id);
			this.xpos = xpos;
			this.ypos = ypos;
			this._menu = menu;
			this.max_name_length = max_name_length;
			this.max_value_length = max_value_length;
			visible_items = @interface.SELECTOR_VISIBLE_ITEMS;
			item_spacing = @interface.SELECTOR_ITEM_SPACING;
			font = @interface.get_monospaced_font();
			font_height = @interface.get_monospaced_font_height();
			ensure_surface();
			@interface.font_updated.connect(update_font);
			@interface.colors_updated.connect(reset_surface);
			index_before_select_first = -1;
			index_before_select_last = -1;
			
			for(int index=0; index<menu.items.size; index++) {
				var field = menu.items[index] as MenuItemField;
				if (field != null) {
					int field_index = index;
					field.changed.connect(()=>update_item_value(field_index));
				}
			}
		}
		public unowned string menu_name { get { return _menu.name; } }
		public Menu menu { get { return _menu; } }
		
		public int height { get { return _height; } }
		public int width { get { return _width; } }
		public uint item_count { get { return menu.items.size; } }

		public uint selected_index { get; private set; }
		public MenuItem selected_item() { return menu.items[(int)selected_index]; }

		public Rect? get_selected_item_value_entry_rect() {
			var field = selected_item() as MenuItemField;
			if (field == null)
				return null;
			Rect rect = {xpos + x_pos_value - 4, ypos + get_offset((int)selected_index) - 5};
			rect.w = (int16)blank_value_area.w;
			rect.h = (int16)blank_value_area.h;
			return rect;
		}

		protected override void draw() {
			ensure_surface();
			Rect dest_r = {xpos, ypos};

			uint top_index;
			uint bottom_index;
			get_display_range(selected_index, out top_index, out bottom_index);
			var items = (bottom_index - top_index) + 1;
			var height = (int16)((font_height * items) + (item_spacing * items));
			Rect source_r = {0, get_offset(top_index), (int16)_width, height};
			blit_surface(surface, source_r, dest_r);
		}

		public bool select_previous() {
			if (selected_index == 0)
				return select_item(item_count - 1); // wrap around
				//return false;

			return select_item(selected_index - 1);
		}
		public bool select_next() {
			if (selected_index == item_count - 1)
				return select_item(0); // wrap around
				//return false;
				

			return select_item(selected_index + 1);
		}
		public bool select_first() {
			if (index_before_select_first != -1)
				return select_item(index_before_select_first);

			int index = (int)selected_index;
			if (select_item(0) == false)
				return false;

			index_before_select_first = index;
			return true;
		}
		public bool select_last() {
			if (index_before_select_last != -1)
				return select_item(index_before_select_last);

			int last_index = (int)item_count - 1;
			if (last_index < 0)
				return false;

			int index = (int)selected_index;
			if (select_item(last_index) == false)
				return false;

			index_before_select_last = index;
			return true;
		}
		public bool select_item_starting_with(string str, uint index=0) {
			return false;
		}
		public bool select_item(uint index) {
			if (index >= item_count)
				return false;

			update_item_name((int)selected_index, false);
			update_item_name((int)index, true);
			selected_index = index;
			index_before_select_first = -1;
			index_before_select_last = -1;
			update();
			return true;
		}

		public void update_selected_item_value() {
			update_item_value((int)selected_index);
			draw();
		}

		void reset_surface() {
			surface = null;
		}
		void update_font() {
			reset_surface();
		}
		void ensure_surface() {
			if (surface != null)
				return;
			update_selector_attributes();
			surface = @interface.get_blank_surface(_width, _height);

			Rect rect = {0, 0};
			for(int index=0; index < item_count; index++) {
				render_item(index).blit(null, surface, rect);
				rect.y = (int16)(rect.y + font_height + item_spacing);
			}
		}
		void update_selector_attributes() {
			int surface_items = menu.items.size;
			_height = (font_height * surface_items) + (item_spacing * surface_items) + (item_spacing * 2);

			int max_name_chars = 0;
			foreach(var item in menu.items) {
				if (item.name.length > max_name_chars)
					max_name_chars = item.name.length;
				if (has_field == false && item is MenuItemField)
					has_field = true;
			}
			if (max_name_chars > uint8.MAX)
				max_name_chars = uint8.MAX;
			max_name_length_real = (max_name_chars < max_name_length) ? (uint8)max_name_chars : max_name_length;
			int name_area_width = @interface.get_monospaced_font_width(max_name_length_real);
			int value_area_width = @interface.get_monospaced_font_width(max_value_length);
			x_pos_value = @interface.get_monospaced_font_width(max_name_length_real + 3); // +3 for " : " before value
			_width = (has_field == false)
				? @interface.get_monospaced_font_width(max_name_length_real + 2) // +2 for submenu " >"
				: x_pos_value + value_area_width;

			blank_name_area = @interface.get_blank_surface(name_area_width, font_height);
			select_name_area = @interface.get_blank_surface(name_area_width, font_height);
			select_name_area.fill(null, @interface.white_color_rgb);
			blank_value_area = @interface.get_blank_surface(value_area_width, font_height);

			field_item_format = "%-" + max_name_length_real.to_string() + "s : %s";
			menu_item_format = "%-" + max_name_length_real.to_string() + "s >";
		}

		Surface render_item(int index) {
			var item = menu.items[index];
			var field = item as MenuItemField;
			if (field != null)
				return font.render_shaded(field_item_format.printf(field.name, field.get_value_text()), @interface.white_color, @interface.black_color);
			var menu = item as Menu;
			if (menu != null)
				return font.render_shaded(menu_item_format.printf(menu.name), @interface.white_color, @interface.black_color);

			return font.render_shaded(item.name, @interface.white_color, @interface.black_color);
		}
		void update_item_name(int index, bool selected=false) {
			Rect rect = {0, get_offset(index)};
			var item = menu.items[index];
			if (selected == true) {
				select_name_area.blit(null, surface, rect);
				font.render_shaded(item.name, @interface.black_color, @interface.white_color).blit(null, surface, rect);
			} else {
				blank_name_area.blit(null, surface, rect);
				font.render_shaded(item.name, @interface.white_color, @interface.black_color).blit(null, surface, rect);
			}
		}
		void update_item_value(int index) {
			var field = menu.items[index] as MenuItemField;
			if (field == null)
				return;
			Rect rect = {x_pos_value, get_offset(index)};
			blank_value_area.blit(null, surface, rect);
			Surface? value_surface = field.get_value_rendering(font);
			if (value_surface == null)
				value_surface = font.render_shaded(field.get_value_text(), @interface.white_color, @interface.black_color);
			value_surface.blit(null, surface, rect);
		}
		int16 get_offset(uint index) {
			return (int16)((font_height * index) + (item_spacing * index));
		}
		void get_display_range(uint center_index, out uint top_index, out uint bottom_index) {
			int top = (int)center_index - (visible_items / 2);
			if (top < 0)
				top = 0;
			int bottom = top + visible_items - 1;
			if (bottom >= item_count)
				bottom = (int)item_count - 1;
			if ((bottom - top) < visible_items - 1)
				top = bottom - visible_items + 1;
			if (bottom < visible_items - 1 || top < 0)
				top = 0;			
			top_index = (uint)top;
			bottom_index = (uint)bottom;			
		}
	}
}
