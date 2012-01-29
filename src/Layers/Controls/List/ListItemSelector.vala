using SDL;
using SDLTTF;
using Gee;

namespace Layers.Controls.List
{
	public class ListItemSelector : Layer
	{
		const string NO_ITEMS_TEXT = "(Empty List): Insert Item";
		const uint8 MAX_ITEM_LENGTH = 50;
		const int VISIBLE_ITEMS = 11;
		int16 xpos;
		int16 ypos;
		Surface surface;
		unowned Font font;
		int16 font_height;
		int _height;
		int _width;
		uint8 max_item_length_real;
		Surface blank_item_area;
		Surface select_item_area;
		Surface move_item_area;
		bool move_active;
		int move_original_index;
		
		Gee.List<ListItem> _items;

		int visible_items;
		int item_spacing;
		int index_before_select_first;
		int index_before_select_last;
		
		public ListItemSelector(string id, int16 xpos, int16 ypos, Gee.List<ListItem> items) {
			base(id);
			this.xpos = xpos;
			this.ypos = ypos;
			visible_items = VISIBLE_ITEMS;
			item_spacing = @interface.SELECTOR_ITEM_SPACING;
			font = @interface.get_monospaced_font();
			font_height = @interface.get_monospaced_font_height();
			
			_items = items;
			ensure_surface();
			index_before_select_first = -1;
			index_before_select_last = -1;
			move_original_index = -1;
		}
		
		public int height { get { return _height; } }
		public int width { get { return _width; } }
		public uint item_count { get { return items.size; } }

		public Gee.List<ListItem> items { get { return _items; } }
		
		public uint selected_index { get; private set; }
		public ListItem selected_item() { return _items[(int)selected_index]; }		

		public Rect get_selected_item_rect() {			
			uint top_index;
			uint bottom_index;
			get_display_range(selected_index, out top_index, out bottom_index);			
			int16 offset = get_offset(selected_index);
			if ((int)bottom_index > visible_items - 1)
				offset = offset - get_offset(top_index);
			
			Rect rect = {xpos, ypos + offset - 5, (int16)_width};
			return rect;
		}
		
		public void add_item(ListItem item) {
			_items.add(item);
			reset();
		}
		public ListItem remove_selected_item() {
			if (_items.size == 0)
				GLib.error("List is empty.");
			ListItem item = selected_item();
			_items.remove_at((int)selected_index);
			if (selected_index == (uint)_items.size && selected_index > 0)
				selected_index--;
			reset();
			return item;
		}
		public void insert_item_before_selected(ListItem item) {
			_items.insert((int)selected_index, item);
			reset();
		}
		public void insert_item_after_selected(ListItem item) {
			if (_items.size == 0 || selected_index == (uint)_items.size - 1)
				_items.add(item);
			else
				_items.insert((int)selected_index + 1, item);
			if (_items.size > 1)
				selected_index++;
			reset();
		}
		public void move_start() {
			move_active = true;
			move_original_index = (int)selected_index;
			update_item((int)selected_index, true);
			update();
		}
		public void move_cancel() {			
			move_active = false;
			if (move_original_index != -1 && selected_index != (uint)move_original_index) {
				var item = selected_item();
				_items.remove_at((int)selected_index);
				if (move_original_index == _items.size - 1)
					_items.add(item);
				else
					_items.insert(move_original_index, item);
				selected_index = (uint)move_original_index;
				reset();				
			} else {
				update_item((int)selected_index, true);				
			}
			update();
			move_original_index = -1;
		}
		public void move_finish() {
			move_active = false;
			move_original_index = -1;
			update_item((int)selected_index, true);
			update();
		}
		
		public void reset() {
			surface = null;
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

		public void hide_selection(bool flip=true) {
			update_item((int)selected_index, false);
			update(flip);
		}
		public void show_selection(bool flip=true) {
			update_item((int)selected_index, true);
			update(flip);
		}
		public bool select_previous() {
			if (_items.size == 0)
				return false;
			if (selected_index == 0) {
				if (move_active == true)
					return false;
				return select_item(item_count - 1); // wrap around				
			}

			return select_item(selected_index - 1);
		}
		public bool select_previous_page() {						
			if (selected_index == 0)
				return false;
			if (selected_index < visible_items) 
				return select_item(0);
		
			return select_item(selected_index - visible_items);
		}
		public bool select_next() {
			if (_items.size == 0)
				return false;
			if (selected_index == item_count - 1) {
				if (move_active == true)
					return false;
				return select_item(0); // wrap around
			}
				
			return select_item(selected_index + 1);
		}
		public bool select_next_page() {
			if (_items.size == 0 || selected_index == _items.size - 1)
				return false;
			if (selected_index + visible_items >= items.size)
				return select_item(items.size -1);
							
			return select_item(selected_index + visible_items);			
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

			int last_index = _items.size - 1;
			if (last_index < 0)
				return false;

			int index = (int)selected_index;
			if (select_item(last_index) == false)
				return false;

			index_before_select_last = index;
			return true;
		}
		public bool select_item_starting_with(string str, uint index=0) {
			if (move_active == true || _items.size == 0)
				return false;
			int found_count=0;
			int item_index;
			for(item_index=1; item_index<items.size; item_index++) {
				if (items[item_index].name.has_prefix(str) == true) {
					found_count++;					
					if (found_count == index+1)
						break;
				} else if (found_count > 0) {
					return false; // nothing else with this prefix, so give up
				}
			}
			if (found_count > 0)
				return select_item((uint)item_index);
				
			return false;
		}		
		public bool select_item_named(string name) {
			if (move_active == true)
				return false;
			for(int index=0; index<items.size; index++) {
				if (items[index].name == name)
					return select_item((uint)index);
			}
			return false;
		}		
		public bool select_item(uint index, bool flip=true) {
			if (index >= item_count)
				return false;			

			if (move_active == true) {
				if (selected_index == index)
					return false;
				var item = selected_item();
				_items.remove_at((int)selected_index);
				if (index == (uint)_items.size)
					_items.add(item);
				else				
					_items.insert((int)index, item);				
				reset();
			} else {
				update_item((int)selected_index, false);
				update_item((int)index, true);
			}
			selected_index = index;
			index_before_select_first = -1;
			index_before_select_last = -1;
			update(flip);
			return true;
		}
				
		void ensure_surface() {
			if (surface != null)
				return;
			update_selector_attributes();
			surface = @interface.get_blank_surface(_width, _height);

			Rect rect = {0, 0};
			if (_items.size == 0) {
				select_item_area.blit(null, surface, rect);
				font.render_shaded(NO_ITEMS_TEXT, @interface.black_color, @interface.white_color).blit(null, surface, rect);
				return;
			}
			for(int index=0; index < _items.size; index++) {
				var item = items[index].name;
				if (index == selected_index) {
					if (move_active == true) {
						move_item_area.blit(null, surface, rect);
						font.render_shaded(item, @interface.white_color, @interface.highlight_color).blit(null, surface, rect);
					} else {
						select_item_area.blit(null, surface, rect);
						font.render_shaded(item, @interface.black_color, @interface.white_color).blit(null, surface, rect);
					}
				} else {
					font.render_shaded(item, @interface.white_color, @interface.black_color).blit(null, surface, rect);
				}
				rect.y = (int16)(rect.y + font_height + item_spacing);
			}
		}		
		void update_selector_attributes() {
			int surface_items = _items.size;
			if (surface_items == 0)
				surface_items = 1;
			_height = (font_height * surface_items) + (item_spacing * surface_items) + (item_spacing * 2);

			int max_chars = 0;
			if (_items.size == 0) {
				max_chars = NO_ITEMS_TEXT.length;
			} else {
				foreach(var item in items) {
					if (item.name.length > max_chars)
						max_chars = item.name.length;
				}
			}
			if (max_chars > uint8.MAX)
				max_chars = uint8.MAX;
			max_item_length_real = (max_chars < MAX_ITEM_LENGTH) ? (uint8)max_chars : MAX_ITEM_LENGTH;
			int item_area_width = @interface.get_monospaced_font_width(max_item_length_real);
			_width = item_area_width;

			blank_item_area = @interface.get_blank_surface(item_area_width, font_height);
			select_item_area = @interface.get_blank_surface(item_area_width, font_height);
			select_item_area.fill(null, @interface.white_color_rgb);
			move_item_area = @interface.get_blank_surface(item_area_width, font_height);
			move_item_area.fill(null, @interface.highlight_color_rgb);			
		}
		
		void update_item(int index, bool selected=false) {
			Rect rect = {0, get_offset(index)};
			var item = (_items.size == 0) ? NO_ITEMS_TEXT : _items[index].name;
			if (selected == true) {
				if (move_active == true) {
					move_item_area.blit(null, surface, rect);
					font.render_shaded(item, @interface.white_color, @interface.highlight_color).blit(null, surface, rect);
				} else {
					select_item_area.blit(null, surface, rect);
					font.render_shaded(item, @interface.black_color, @interface.white_color).blit(null, surface, rect);
				}
			} else {
				blank_item_area.blit(null, surface, rect);
				font.render_shaded(item, @interface.white_color, @interface.black_color).blit(null, surface, rect);
			}
		}
		
		int16 get_offset(uint index) {
			return (int16)((font_height * index) + (item_spacing * index));
		}
		void get_display_range(uint center_index, out uint top_index, out uint bottom_index) {
			if (_items.size == 0) {
				top_index = 0;
				bottom_index = 0;
				return;
			}
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
