using Gee;
using SDL;
using SDLTTF;
using Layers;
using Layers.MenuBrowser;

namespace Layers.Controls.Chooser
{
	public abstract class ChooserSelector : Layer
	{
		const uint8 MAX_ITEM_LENGTH = 50;
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

		Gee.List<Item> _items;

		int visible_items;
		int item_spacing;
		int index_before_select_first;
		int index_before_select_last;
		
		string? choose_item_name;
		
		protected ChooserSelector(string id, int16 xpos, int16 ypos, bool is_root=false, string? choose_item_name=null) {
			base(id);
			this.xpos = xpos;
			this.ypos = ypos;			
			visible_items = @interface.SELECTOR_VISIBLE_ITEMS;
			item_spacing = @interface.SELECTOR_ITEM_SPACING;
			font = @interface.get_monospaced_font();
			font_height = @interface.get_monospaced_font_height();
						
			index_before_select_first = -1;
			index_before_select_last = -1;		
			
			wrap_selector = true;
			this.is_root = is_root;
			this.choose_item_name = choose_item_name;
		}
		
		public int height { get { return _height; } }
		public int width { get { return _width; } }
		public uint item_count { get { return items.size; } }
		public bool wrap_selector { get; set; }
		
		public uint selected_index { get; private set; }
		public string selected_item() { return items[(int)selected_index].name; }
		public string selected_item_id() { return items[(int)selected_index].id; }
		public string? selected_item_secondary_id() { return items[(int)selected_index].secondary_id; }
		
		public bool is_choose_item_selected {  get { return is_choose_item((int)selected_index); } }
		public bool is_go_back_item_selected { get { return is_go_back_item((int)selected_index); } }
		public bool is_folder_selected { get { return items[(int)selected_index].is_folder; } }
		public bool is_root { get; private set; }
		
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
		protected Gee.List<Item> items { 
			get {
				if (_items == null) {
					_items = new ArrayList<Item>();
					populate_items(_items);
					if (choose_item_name != null)
						_items.insert(0, new Item.folder(""));
					if (is_root == false)
						_items.insert(0, new Item.folder(".."));
					string? selected_name = get_initial_selected_item_name();
					if (selected_name != null) {
						int index = get_index_of_item_named(selected_name);
						if (index > 0)
							selected_index = (uint)index;
					}
				}
				return _items;
			}
		}

		public bool select_previous() {
			if (selected_index == 0) {
				if (wrap_selector)
					return select_item(item_count - 1); // wrap around
				return false;
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
			if (selected_index == item_count - 1) {
				if (wrap_selector)
					return select_item(0); // wrap around
				return false;
			}
				
			return select_item(selected_index + 1);
		}
		public bool select_next_page() {
			if (selected_index == items.size - 1)
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
			for(int index=0; index<items.size; index++) {
				if (items[index].name == name)
					return select_item((uint)index);
			}
			return false;
		}		
		public bool select_item(uint index) {
			if (index >= item_count)
				return false;			

			ensure_surface();
			update_item((int)selected_index, false);
			update_item((int)index, true);
			selected_index = index;
			index_before_select_first = -1;
			index_before_select_last = -1;
			update();
			return true;
		}
		public void choose_selected_item_secondary_id(uchar screen_alpha=128, uint32 rgb_color=0) {
			var item = items[(int)selected_index];
			if (item.get_secondary_ids() == null)
				return;
				
			uint top_index;
			uint bottom_index;
			get_display_range(selected_index, out top_index, out bottom_index);			
			int16 offset = get_offset(selected_index);
			if ((int)bottom_index > visible_items - 1)
				offset = offset - get_offset(top_index);
			
			
			item.choose_secondary_id(xpos + (int16)_width, ypos + offset - 5, screen_alpha, rgb_color);			
		}
		
		protected abstract void populate_items(Gee.List<Item> items);
		protected Item create_file_item(string name, string? id=null) { return new Item.file(name, id); }
		protected Item create_folder_item(string name) { return new Item.folder(name); }
		protected virtual string? get_initial_selected_item_name() { return null; }

		
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
			int surface_items = items.size;
			_height = (font_height * surface_items) + (item_spacing * surface_items) + (item_spacing * 2);

			int max_chars = (choose_item_name != null) ? choose_item_name.length : 0;
			foreach(var item in items) {
				if (item.name.length > max_chars)
					max_chars = item.name.length;
			}
			if (max_chars > uint8.MAX)
				max_chars = uint8.MAX;
			max_item_length_real = (max_chars < MAX_ITEM_LENGTH) ? (uint8)max_chars : MAX_ITEM_LENGTH;
			int item_area_width = @interface.get_monospaced_font_width(max_item_length_real);
			_width = item_area_width;

			blank_item_area = @interface.get_blank_surface(item_area_width, font_height);
			select_item_area = @interface.get_blank_surface(item_area_width, font_height);
			select_item_area.fill(null, @interface.white_color_rgb);			
		}
				
		Surface render_item(int index) {			
			return font.render_shaded(get_item_name(index), @interface.white_color, @interface.black_color);
		}
		void update_item(int index, bool selected=false) {
			Rect rect = {0, get_offset(index)};
			var item = get_item_name(index);
			if (selected == true) {
				select_item_area.blit(null, surface, rect);
				font.render_shaded(item, @interface.black_color, @interface.white_color).blit(null, surface, rect);
			} else {
				blank_item_area.blit(null, surface, rect);
				font.render_shaded(item, @interface.white_color, @interface.black_color).blit(null, surface, rect);
			}
		}
		
		unowned string get_item_name(int index) {
			return is_choose_item(index) ? choose_item_name : items[index].name;
		}
		bool is_choose_item(int index) { return (choose_item_name != null && index == ((is_root) ? 0 : 1)); }
		bool is_go_back_item(int index) { return (is_root == false && index == 0); }
		
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
		public int get_index_of_item_named(string name) {
			for(int index=0; index<items.size; index++) {
				if (items[index].name == name)
					return index;
			}
			return -1;
		}
		protected class Item : Comparable<Item>, Object
		{
			string _name;
			string? _id;
			string? _secondary_id;
			ArrayList<string> secondary_id_list;
			
			public Item.file(string name, string? id=null) {
				_name = name;
				_id = id;
				this.is_folder = false;
			}
			public Item.folder(string name) {
				_name = name;
				this.is_folder = true;
			}
			
			public bool is_folder { get; private set; }
			public unowned string name { get { return _name; } }
			public unowned string id { 
				get { 
					if (_id != null)
						return _id;
					return _name;
				}
			}
			
			public unowned string? secondary_id { get { return _secondary_id; } }
			public Gee.List<string>? get_secondary_ids() { return secondary_id_list; }
			
			public void add_secondary_id(string id) {
				if (_secondary_id == null) {
					_secondary_id = id;
					return;
				} 
				if (secondary_id_list == null) {
					secondary_id_list = new ArrayList<string>();
					secondary_id_list.add(_secondary_id);					
				}
				secondary_id_list.add(id);
			}
			public void choose_secondary_id(int16 xpos, int16 ypos, uchar screen_alpha=128, uint32 rgb_color=0) {
				if (secondary_id_list == null || secondary_id_list.size < 2)
					return;
					
				uint id_index = 0;
				for(int index=0; index< secondary_id_list.size; index++) {			
					if (id == secondary_id_list[index]) {
						id_index = (uint)index;
						break;
					}
				}
				var id_selector = new StringSelector("secondary_id_chooser", xpos, ypos, 300, secondary_id_list, id_index);
				var new_index = id_selector.run(screen_alpha, rgb_color);
				if (new_index != id_index)
					_secondary_id = secondary_id_list[(int)new_index];				
			}
			
			public int compare_to(Item other) {
				if (is_folder == other.is_folder)
					return Utility.strcasecmp(name, other.name);
					
				return (is_folder) ? -1 : 1;
			}
		}
	}
}
