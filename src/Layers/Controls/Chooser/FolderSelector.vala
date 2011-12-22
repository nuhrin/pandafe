using Gee;
using SDL;
using SDLTTF;
using Layers;
using Layers.MenuBrowser;

namespace Layers.Controls.Chooser
{
	public class FolderSelector : Layer
	{
		const uint8 MAX_ITEM_LENGTH = 50;
		const string CURRENT_FOLDER_ITEM_NAME = "(Choose this folder)";
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

		ArrayList<string> items;		

		int visible_items;
		int item_spacing;
		int index_before_select_first;
		int index_before_select_last;
		
		public FolderSelector(string id, int16 xpos, int16 ypos, string path, bool is_root=false) {
			if (FileUtils.test(path, FileTest.IS_DIR) == false)
				GLib.error("Path '%s' does not exist.", path);
			
			base(id);
			this.xpos = xpos;
			this.ypos = ypos;
			visible_items = @interface.SELECTOR_VISIBLE_ITEMS;
			item_spacing = @interface.SELECTOR_ITEM_SPACING;
			font = @interface.get_monospaced_font();
			font_height = @interface.get_monospaced_font_height();
			
			this.path = path;
			this.is_root = is_root;
			
			populate_items();
			ensure_surface();
			index_before_select_first = -1;
			index_before_select_last = -1;			
		}
		
		public int height { get { return _height; } }
		public int width { get { return _width; } }
		public uint item_count { get { return items.size; } }

		public string path { get; private set; }
		public bool is_root { get; private set; }
		
		public bool is_choose_item_selected {  get { return is_choose_item((int)selected_index); } }
		public bool is_go_back_item_selected { get { return is_go_back_item((int)selected_index); } }
		public uint selected_index { get; private set; }
		public string selected_folder() { return items[(int)selected_index]; }
		public string selected_path() { 
			if (is_choose_item_selected)
				return path;
			if (is_go_back_item_selected)
				return Path.get_dirname(path);
				
			return Path.build_filename(path, selected_folder());
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
		public bool select_previous_page() {
			if (selected_index < visible_items) {
				return select_first();				
			}
			return select_item(selected_index - visible_items);
		}
		public bool select_next() {
			if (selected_index == item_count - 1)
				return select_item(0); // wrap around
				//return false;
				
			return select_item(selected_index + 1);
		}
		public bool select_next_page() {
			if (selected_index + visible_items >= items.size) {
				return select_last();
			}
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
				if (items[item_index].has_prefix(str) == true) {
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
		public bool select_item(uint index) {
			if (index >= item_count)
				return false;

			update_item((int)selected_index, false);
			update_item((int)index, true);
			selected_index = index;
			index_before_select_first = -1;
			index_before_select_last = -1;
			update();
			return true;
		}				

		void populate_items() {
			items = new ArrayList<string>();
			try {
				var directory = File.new_for_path(path);
				var enumerator = directory.enumerate_children("standard::*", FileQueryInfoFlags.NONE);
				FileInfo file_info;
				while ((file_info = enumerator.next_file ()) != null) {
					var type = file_info.get_file_type();
					var name = file_info.get_name();
					if (name.has_prefix(".") == true)
						continue;
					if (type == FileType.DIRECTORY)
						items.add(name);
				}
				items.sort();				
			}
			catch(GLib.Error e)
			{
				debug("Error while getting children of '%s': %s", path, e.message);
			}
			items.insert(0, "");
			if (is_root == false)
				items.insert(0, "..");			
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
			int surface_items = items.size;
			_height = (font_height * surface_items) + (item_spacing * surface_items) + (item_spacing * 2);

			int max_chars = CURRENT_FOLDER_ITEM_NAME.length;
			foreach(var item in items) {
				if (item.length > max_chars)
					max_chars = item.length;
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

		bool is_choose_item(int index) { return (index == ((is_root) ? 0 : 1)); }
		bool is_go_back_item(int index) { return (is_root == false && index == 0); }
		
		Surface render_item(int index) {			
			return font.render_shaded(is_choose_item(index) ? CURRENT_FOLDER_ITEM_NAME : items[index], @interface.white_color, @interface.black_color);
		}
		void update_item(int index, bool selected=false) {
			Rect rect = {0, get_offset(index)};
			var item = is_choose_item(index) ? CURRENT_FOLDER_ITEM_NAME : items[index];
			if (selected == true) {
				select_item_area.blit(null, surface, rect);
				font.render_shaded(item, @interface.black_color, @interface.white_color).blit(null, surface, rect);
			} else {
				blank_item_area.blit(null, surface, rect);
				font.render_shaded(item, @interface.white_color, @interface.black_color).blit(null, surface, rect);
			}
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
