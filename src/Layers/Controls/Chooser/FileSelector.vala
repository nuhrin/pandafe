using Gee;
using SDL;
using SDLTTF;
using Layers;
using Layers.MenuBrowser;

namespace Layers.Controls.Chooser
{
	public class FileSelector : Layer
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

		ArrayList<Item> items;
		Regex? regex_file_filter;

		int visible_items;
		int item_spacing;
		int index_before_select_first;
		int index_before_select_last;
		
		public FileSelector(string id, int16 xpos, int16 ypos, string path, Regex? regex_file_filter=null, bool is_root=false) {
			if (FileUtils.test(path, FileTest.EXISTS) == false)
				GLib.error("Path '%s' does not exist.", path);
									
			base(id);
			this.xpos = xpos;
			this.ypos = ypos;
			visible_items = @interface.SELECTOR_VISIBLE_ITEMS;
			item_spacing = @interface.SELECTOR_ITEM_SPACING;
			font = @interface.get_monospaced_font();
			font_height = @interface.get_monospaced_font_height();
			
			bool path_is_dir = FileUtils.test(path, FileTest.IS_DIR);
			this.path = (path_is_dir == false || path.has_suffix(Path.DIR_SEPARATOR_S) == true) 
				? Path.get_dirname(path)
				: path;
			this.regex_file_filter = regex_file_filter;
			this.is_root = is_root;
			
			populate_items();
			ensure_surface();
			index_before_select_first = -1;
			index_before_select_last = -1;
			if (path_is_dir == false) {
				int index = get_index_of_item_named(Path.get_basename(path));
				if (index > 0)
					selected_index = (uint)index;
			}
		}
		
		public int height { get { return _height; } }
		public int width { get { return _width; } }
		public uint item_count { get { return items.size; } }

		public string path { get; private set; }
		public bool is_root { get; private set; }
		
		public bool is_go_back_item_selected { get { return is_go_back_item((int)selected_index); } }
		public bool is_folder_selected { get { return items[(int)selected_index].is_folder; } }
		public uint selected_index { get; private set; }
		public string selected_item() { return items[(int)selected_index].name; }
		public string selected_path() { 
			if (is_go_back_item_selected)
				return Path.get_dirname(path);
				
			return Path.build_filename(path, selected_item());
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
			if (selected_index == 0)
				return false;				
			if (selected_index < visible_items)
				return select_item(0);				
			
			return select_item(selected_index - visible_items);
		}
		public bool select_next() {
			if (selected_index == item_count - 1)
				return select_item(0); // wrap around
				//return false;
				
			return select_item(selected_index + 1);
		}
		public bool select_next_page() {
			if (selected_index == items.size - 1)
				return false;
			if (selected_index + visible_items >= items.size)
				return select_item(items.size - 1);
			
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
			int index = get_index_of_item_named(name);
			if (index > 0)
				return select_item((uint)index);
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
		int get_index_of_item_named(string name) {
			for(int index=0; index<items.size; index++) {
				if (items[index].name == name)
					return index;
			}
			return -1;
		}
					

		void populate_items() {
			items = new ArrayList<Item>();
			var files = new ArrayList<string>();
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
						items.add(new Item.folder(name));
					else
						files.add(name);
				}				
				items.sort();
				if (regex_file_filter != null)
					files = get_matching_files(files);
				files.sort();
				foreach(var file in files)
					items.add(new Item.file(file));
			}
			catch(GLib.Error e)
			{
				debug("Error while getting children of '%s': %s", path, e.message);
			}
			if (is_root == false)
				items.insert(0, new Item.folder(".."));
		}
		ArrayList<string> get_matching_files(ArrayList<string> file_names) {
			var sb = new StringBuilder();
			var item_positions = new int[file_names.size];
			for(int index=0; index<file_names.size; index++) {
				item_positions[index] = (int)sb.len;
				sb.append("%s\n".printf(file_names[index]));
			}
			var items_str = sb.str;
			var matched_names = new ArrayList<string>();

			int matched_item_index = 0;
			int last_item_index = file_names.size - 1;
			MatchInfo match_info;
			regex_file_filter.match(items_str, 0, out match_info);
			while((matched_item_index < file_names.size) && match_info.matches()) {
				int match_position;
				if (match_info.fetch_pos(0, out match_position, null) == true) {
					if (match_position >= item_positions[matched_item_index]) {
						while(match_position >= item_positions[matched_item_index + 1] && (matched_item_index < last_item_index))
							matched_item_index++;

						matched_names.add(file_names[matched_item_index]);
						matched_item_index++;
					}
				}
				try {
					match_info.next();
				} catch(RegexError e) {
					debug("Error during file extension matching: %s", e.message);
					break;
				}
			}

			return matched_names;
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

			int max_chars = 0;
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

		bool is_go_back_item(int index) { return (is_root == false && index == 0); }
		
		Surface render_item(int index) {			
			return font.render_shaded(items[index].name, @interface.white_color, @interface.black_color);
		}
		void update_item(int index, bool selected=false) {
			Rect rect = {0, get_offset(index)};
			if (selected == true) {
				select_item_area.blit(null, surface, rect);
				font.render_shaded(items[index].name, @interface.black_color, @interface.white_color).blit(null, surface, rect);
			} else {
				blank_item_area.blit(null, surface, rect);
				font.render_shaded(items[index].name, @interface.white_color, @interface.black_color).blit(null, surface, rect);
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
		
		class Item : Comparable<Item>, Object
		{
			string _name;
			public Item.file(string name) {
				_name = name;
				this.is_folder = false;
			}
			public Item.folder(string name) {
				_name = name + "/";
				this.is_folder = true;
			}
			
			public bool is_folder { get; private set; }
			public unowned string name { get { return _name; } }
			
			public int compare_to(Item other) {
				if (is_folder == other.is_folder)
					return strcmp(name, other.name);
					
				return (is_folder) ? -1 : 1;
			}
		}
	}
}
