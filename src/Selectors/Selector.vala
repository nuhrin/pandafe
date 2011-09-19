using SDL;
using SDLTTF;
using Gee;

public abstract class Selector : Object
{
	const int16 ITEM_SPACING = 5;
	Surface surface;
	InterfaceHelper @interface;
	int surface_width;
	int visible_items;
	int index_before_select_first;
	int index_before_select_last;

	protected Selector(InterfaceHelper @interface, int width, int visible_items) {
		this.@interface = @interface;
		@interface.font_updated.connect(reset_surface);
		@interface.colors_updated.connect(reset_surface);
		surface_width = width;
		this.visible_items = visible_items;
		selected_index = -1;
		index_before_select_first = -1;
		index_before_select_last = -1;
	}
	SelectorItemSet items {
		get {
			if (_items == null)
				_items = new SelectorItemSet(@interface, this);

			return _items;
		}
	}
	SelectorItemSet _items;

	public int selected_index { get; private set; }

	void reset_surface() {
		surface = null;
	}

	public void blit_to_screen(int16 x, int16 y) {
		ensure_surface();
		int16 height = (int16)((@interface.font_height * visible_items) + (ITEM_SPACING * visible_items) + ITEM_SPACING);
		int16 offset = 0;
		int item_count = get_item_count();
		var half = visible_items / 2;
		if (visible_items < item_count && selected_index > half) {
			int display_top_index = selected_index - half;
			if (item_count - selected_index < half + 1)
				display_top_index = item_count - visible_items;
			offset = get_item_offset(display_top_index) - ITEM_SPACING;
		}
		Rect source_r = {0, offset, (int16)surface_width, height};
		Rect dest_r = {x, y};
		@interface.screen_blit(surface, source_r, dest_r);
	}

	public bool has_previous { get { return selected_index > 0; } }
	public bool has_next { get { return selected_index < get_item_count() -1; } }

	public bool select_previous() {
		if (has_previous == false)
			return false;

		return select_item(selected_index - 1);
	}
	public bool select_previous_by(uint count) {
		if (count == 0 || selected_index == 0)
			return false;
		int index = selected_index - (int)count;
		if (index < 0)
			index = 0;
		return select_item(index);
	}
	public bool select_next() {
		if (has_next == false)
			return false;

		return select_item(selected_index + 1);
	}
	public bool select_next_by(uint count) {
		int item_count = get_item_count();
		if (count == 0 || selected_index == item_count - 1)
			return false;
		int index = selected_index + (int)count;
		if (index >= item_count)
			index = item_count - 1;
		return select_item(index);
	}

	public bool select_first() {
		if (index_before_select_first != -1)
			return select_item(index_before_select_first);

		int index = selected_index;
		if (select_item(0) == false)
			return false;

		index_before_select_first = index;
		return true;
	}
	public bool select_last() {
		if (index_before_select_last != -1)
			return select_item(index_before_select_last);

		int last_index = get_item_count() - 1;
		if (last_index < 0)
			return false;

		int index = selected_index;
		if (select_item(last_index) == false)
			return false;

		index_before_select_last = index;
		return true;
	}

	public bool select_item(int index) {
		int16 offset = get_item_offset(index);
		if (offset == -1)
			return false;

		index_before_select_first = -1;
		index_before_select_last = -1;

		ensure_surface();

		Rect rect = {0, offset};
		if (selected_index != -1) {
			Rect oldrect = {0, get_item_offset(selected_index)};
			items.get_item_blank_rendering(selected_index).blit(null, surface, oldrect);
			items.get_item_rendering(selected_index).blit(null, surface, oldrect);
		}
		items.get_item_blank_rendering(index).blit(null, surface, rect);
		items.get_item_selected_rendering(index).blit(null, surface, rect);

		surface.flip();
		selected_index = index;

		return true;
	}

	int16 get_item_offset(int index) {
		if (index < 0 || index >= get_item_count())
			return -1;
		return (int16)((@interface.font_height * index) + (ITEM_SPACING * index) + ITEM_SPACING);
	}
	void ensure_surface() {
		if (surface != null)
			return;

		int item_count = get_item_count();
		int surface_items = item_count;
		if (visible_items > item_count)
			surface_items = visible_items;

		int height = (@interface.font_height * surface_items) + (ITEM_SPACING * surface_items) + (ITEM_SPACING * 2);
		surface = @interface.get_blank_surface(this.surface_width, height);
		surface.fill(null, @interface.background_color_rgb);

		Rect rect = {0, ITEM_SPACING};
		for(int index=0; index < item_count; index++) {
			if (selected_index == index)
				items.get_item_selected_rendering(index).blit(null, surface, rect);
			else
				items.get_item_rendering(index).blit(null, surface, rect);
			rect.y = (int16)(rect.y + @interface.font_height + ITEM_SPACING);
		}

		surface.flip();
	}

	public abstract int get_item_count();
	public abstract string get_item_name(int index);
	public abstract string get_item_full_name(int index);

	// filtering related

	public bool filter(string pattern) {
		ArrayList<int> matching_indexes;
		bool is_partial;
		if (items.search(pattern, out matching_indexes, out is_partial) == false)
			return false;

		print("matches: ");
		foreach(var index in matching_indexes)
			print("[%d] ", index);
		print("\n");
		return !is_partial;
	}
}
