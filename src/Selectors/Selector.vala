using SDL;
using SDLTTF;
using Gee;

public abstract class Selector : Object
{
	InterfaceHelper @interface;
	int visible_items;
	int16 item_spacing;
	Surface surface;
	int16 surface_width;
	int16 surface_window_height;
	bool all_items_rendered;
	int first_rendered_item;
	int last_rendered_item;
	int index_before_select_first;
	int index_before_select_last;
	string _filter;
	Gee.List<int> _filter_match_indexes;
	HashMap<int,int> _filter_index_position_hash;

	protected Selector(InterfaceHelper @interface) {
		this.@interface = @interface;
		@interface.font_updated.connect(update_font);
		@interface.colors_updated.connect(reset_surface);
		visible_items = @interface.SELECTOR_VISIBLE_ITEMS;
		item_spacing = @interface.SELECTOR_ITEM_SPACING;
		surface_width = @interface.SELECTOR_WITDH;
		surface_window_height = get_surface_window_height();
		selected_index = -1;
		first_rendered_item = -1;
		last_rendered_item = -1;
		index_before_select_first = -1;
		index_before_select_last = -1;
		@interface.connect_idle_function("selector", rendering_iteration);
	}
	SelectorItemSet items {
		get {
			if (_items == null)
				_items = new SelectorItemSet(@interface, this);

			return _items;
		}
	}
	SelectorItemSet _items;

	public int item_count {
		get {
			if (_item_count == -1)
				_item_count = get_itemcount();
			return (int)_item_count;
		}
	}
	int _item_count = -1;
	public int display_item_count {
		get { return (_filter_match_indexes != null) ? _filter_match_indexes.size : item_count; }
	}
	public int selected_index { get; private set; }
	public int selected_display_index() { return get_display_index_from_index(selected_index); }

	public void blit_to_screen(int16 x, int16 y) {
		if (surface == null)
			ensure_surface(selected_index);
		int16 offset = 0;
		var half = visible_items / 2;
		int s_display_index = selected_display_index();
		if (visible_items < display_item_count && s_display_index > half) {
			int display_top_index = s_display_index - half;
			if (display_item_count - s_display_index < half + 1)
				display_top_index = display_item_count - visible_items;
			offset = get_item_offset(display_top_index) - item_spacing;
		}
		Rect source_r = {0, offset, surface_width, surface_window_height};
		Rect dest_r = {x, y};
		@interface.screen_blit(surface, source_r, dest_r);
	}

	public void dim(int percentage) {
		@interface.dim_surface(percentage, surface);
	}

	public bool has_previous { get { return selected_display_index() > 0; } }
	public bool has_next { get { return selected_display_index() < display_item_count - 1; } }

	public bool select_previous() {
		if (has_previous == false)
			return false;

		return select_display_item(selected_display_index() - 1);
	}
	public bool select_previous_by(uint count) {
		int s_display_index = selected_display_index();
		if (count == 0 || s_display_index == 0)
			return false;
		int display_index = s_display_index - (int)count;
		if (display_index < 0)
			display_index = 0;

		return select_display_item(display_index);
	}
	public bool select_next() {
		if (has_next == false)
			return false;

		return select_display_item(selected_display_index() + 1);
	}
	public bool select_next_by(uint count) {
		int s_display_index = selected_display_index();
		if (count == 0 || s_display_index == display_item_count - 1)
			return false;
		int display_index = s_display_index + (int)count;
		if (display_index >= display_item_count)
			display_index = display_item_count - 1;

		return select_display_item(display_index);
	}
	public bool select_first() {
		if (index_before_select_first != -1)
			return select_item(index_before_select_first);

		int index = selected_index;
		if (select_display_item(0) == false)
			return false;

		index_before_select_first = index;
		return true;
	}
	public bool select_last() {
		if (index_before_select_last != -1)
			return select_item(index_before_select_last);

		int last_index = display_item_count - 1;
		if (last_index < 0)
			return false;

		int index = selected_index;
		if (select_display_item(last_index) == false)
			return false;

		index_before_select_last = index;
		return true;
	}
	public bool select_item_starting_with(string str, int index=0) {
		Gee.List<int> matching_indexes;
		if (items.search("^" + str, out matching_indexes, null) == false)
			return false;

		if (matching_indexes.size >= index + 1)
			return select_item(matching_indexes[index]);

		return false;
	}
	public bool select_display_item(int display_index) {
		return select_item(get_index_from_display_index(display_index));
	}
	public bool select_item(int index) {
		int16 offset = get_item_offset(index);
		if (offset == -1)
			return false;

		index_before_select_first = -1;
		index_before_select_last = -1;

		ensure_surface(index);

		Rect rect = {0, offset};
		if (selected_index != -1) {
			Rect oldrect = {0, get_item_offset(selected_index)};
			@interface.get_blank_item_surface().blit(null, surface, oldrect);
			items.get_item_rendering(selected_index).blit(null, surface, oldrect);
		}
		items.get_item_selected_rendering(index).blit(null, surface, rect);
		selected_index = index;

		return true;
	}

	public bool filter(string pattern) {
		_filter = pattern;
		_filter_match_indexes = new ArrayList<int>();
		_filter_match_indexes.add_all(items.get_folder_indexes());
		_filter_index_position_hash = new HashMap<int,int>();
		//debug("filtering by '%s'", pattern);
		Gee.List<int> matching_indexes;
		bool success;
		success = items.search(pattern, out matching_indexes, null);
		if (success == true) {
//~ 			print("matches: ");
//~ 			foreach(var index in matching_indexes)
//~ 				print("[%d] ", index);
//~ 			print("\n");

			_filter_match_indexes.add_all(matching_indexes);
		}

		var display_index = get_closest_display_index(selected_index);

		for(int index=0; index<_filter_match_indexes.size; index++)
			_filter_index_position_hash[_filter_match_indexes[index]] = index;

		reset_surface();
		if (display_index != -1)
			select_display_item(display_index);
		else
			ensure_surface(0);

		return success;
	}
	public void clear_filter() {
		_filter = null;
		_filter_match_indexes = null;
		_filter_index_position_hash = null;
		reset_surface();
		ensure_surface(selected_index);
	}
	public string? get_filter_pattern() { return _filter; }

	public abstract int get_itemcount();
	public abstract string get_item_name(int index);
	public abstract string get_item_full_name(int index);

	void reset_surface() {
		surface = null;
		first_rendered_item = -1;
		last_rendered_item = -1;
		all_items_rendered = false;
	}
	void update_font() {
		reset_surface();
		surface_window_height = get_surface_window_height();
	}
	int16 get_surface_window_height() { return (int16)((@interface.font_height * visible_items) + (item_spacing * visible_items) + item_spacing); }

	int16 get_display_item_offset(int display_index) {
		if (display_index < 0 || display_index >= display_item_count)
			return -1;
		return (int16)((@interface.font_height * display_index) + (item_spacing * display_index) + item_spacing);
	}
	int16 get_item_offset(int index) {
		return get_display_item_offset(get_display_index_from_index(index));
	}
	void ensure_surface(int select_index) {
		if (surface == null) {
			int surface_items = (visible_items > display_item_count)
				? visible_items
				: display_item_count;
			int height = (@interface.font_height * surface_items) + (item_spacing * surface_items) + (item_spacing * 2);
			surface = @interface.get_blank_background_surface(this.surface_width, height);
		}

		if (all_items_rendered == true)
			return;

		if (first_rendered_item == 0 && last_rendered_item == display_item_count - 1) {
			all_items_rendered = true;
			return;
		}

		int top_index;
		int bottom_index;
		get_display_range(get_display_index_from_index(select_index), out top_index, out bottom_index);

		if (first_rendered_item == -1) {
			render_item_range(top_index, bottom_index);
			first_rendered_item = top_index;
			last_rendered_item = bottom_index;
			surface.flip();
			return;
		}

		bool needs_flip = false;

		if (top_index < first_rendered_item) {
			render_item_range(top_index, first_rendered_item - 1);
			first_rendered_item = top_index;
			needs_flip = true;
		}
		if (bottom_index > last_rendered_item) {
			render_item_range(last_rendered_item + 1, bottom_index);
			last_rendered_item = bottom_index;
			needs_flip = true;
		}

		if (needs_flip == true)
			surface.flip();
	}
	void rendering_iteration() {
		bool needs_flip = false;
		if (first_rendered_item > 0) {
			first_rendered_item--;
			render_item_range(first_rendered_item, first_rendered_item);
			needs_flip = true;
		}
		if (last_rendered_item < display_item_count - 1) {
			last_rendered_item++;
			render_item_range(last_rendered_item, last_rendered_item);
			needs_flip = true;
		}
		if (needs_flip == true) {
			surface.flip();
		} else {
			all_items_rendered = true;
			@interface.disconnect_idle_function("selector");
		}
	}
	void render_item_range(int top_index, int bottom_index) {
		int16 offset = get_display_item_offset(top_index);
		if (offset == -1 || display_item_count < 1)
			return;
		Rect rect = {0, offset};
		for(int display_index=top_index; display_index <= bottom_index; display_index++) {
			items.get_item_rendering(get_index_from_display_index(display_index)).blit(null, surface, rect);
			rect.y = (int16)(rect.y + @interface.font_height + item_spacing);
		}
	}
	void get_display_range(int center_index, out int top_index, out int bottom_index) {
		top_index = center_index - (visible_items / 2);
		if (top_index < 0)
			top_index = 0;
		bottom_index = top_index + visible_items;
		if (bottom_index > display_item_count)
			bottom_index = display_item_count;
		bottom_index--;
		if ((bottom_index - top_index) < visible_items)
			top_index = bottom_index - visible_items;
		if (bottom_index < visible_items || top_index < 0)
			top_index = 0;
	}
	int get_index_from_display_index(int display_index) {
		if (_filter_match_indexes == null)
			return display_index;
		if (display_index < 0 || display_index >= display_item_count)
			return -1;

		return _filter_match_indexes[display_index];
	}
	int get_display_index_from_index(int index) {
		if (_filter_index_position_hash == null)
			return index;
		if (_filter_index_position_hash.has_key(index) == false)
			return -1;
		return _filter_index_position_hash[index];
	}

	int get_closest_display_index(int index) {
		if (_filter_match_indexes == null)
			return -1;
		int size = _filter_match_indexes.size;
		if (size == 0)
			return -1;
		else if (size == 1 || index < 0 || index >= item_count)
			return 0;
		int min_distance = (_filter_match_indexes[0] - index).abs();
		int closest_item_index = 0;
		for(int item_index = 1; item_index < size; item_index++) {
			int distance = (_filter_match_indexes[item_index] - index).abs();
			if (distance < min_distance) {
				min_distance = distance;
				closest_item_index = item_index;
			}
		}
		return closest_item_index;
	}
}

