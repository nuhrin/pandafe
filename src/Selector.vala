using SDL;
using SDLTTF;
using Gee;

public abstract class Selector : Object
{
	const int DEPTH = 32;
	const int16 ITEM_SPACING = 5;
	Surface surface;
	unowned PixelFormat format;
	unowned Font font;
	int font_height;
	int surface_width;
	int visible_items;
	uint32 background_color_rgb;
	int index_before_select_first;
	int index_before_select_last;

	protected Selector(PixelFormat* format, Font* font, int width, int visible_items) {
		this.format = format;
		this.font = font;
		font_height = (int16)this.font.height();
		surface_width = width;
		this.visible_items = visible_items;
		update_colors();
		selected_index = -1;
		index_before_select_first = -1;
		index_before_select_last = -1;
	}
	SelectorItemSet items {
		get {
			if (_items == null)
				_items = new SelectorItemSet(font, this, (s,i)=>s.get_item_name(i));

			return _items;
		}
	}
	SelectorItemSet _items;

	public int selected_index { get; private set; }

	public void update_colors() {
		var preferences = Data.preferences();
		var background_color = preferences.background_color_sdl();
		background_color_rgb = format.map_rgb(background_color.r, background_color.g, background_color.b);
		if (_items != null)
			_items.update_colors();

		surface = null;
	}
	public void update_font(Font* font) {
		items.update_font(font);

		surface = null;
	}

	public void blit_to(Surface other, int16 x, int16 y) {
		ensure_surface();
		int16 height = (int16)((font_height * visible_items) + (ITEM_SPACING * visible_items) + ITEM_SPACING);
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
		surface.blit(source_r, other, dest_r);
	}

	public bool has_previous { get { return selected_index > 0; } }
	public bool has_next { get { return selected_index < get_item_count() -1; } }

	public bool select_previous() {
		if (has_previous == false)
			return false;

		return select_item(selected_index - 1);
	}
	public bool select_previous_by(uint count) {
		if (count == 0)
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
		if (count == 0)
			return false;
		int index = selected_index + (int)count;
		int item_count = get_item_count();
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

		if (selected_index != -1) {
			Rect oldrect = {0, get_item_offset(selected_index)};
			items.get_item_rendering(selected_index).blit(null, surface, oldrect);
		}
		Rect rect = {0, offset};
		items.get_item_blank_rendering(index).blit(null, surface, rect);
		items.get_item_selected_rendering(index).blit(null, surface, rect);

		surface.flip();
		selected_index = index;

		debug("selected index: %d", index);

		return true;
	}

	int16 get_item_offset(int index) {
		if (index < 0 || index >= get_item_count())
			return -1;
		return (int16)((font_height * index) + (ITEM_SPACING * index) + ITEM_SPACING);
	}
	void ensure_surface() {
		if (surface != null)
			return;

		int item_count = get_item_count();
		int surface_items = item_count;
		if (visible_items > item_count)
			surface_items = visible_items;

		int font_height = font.height();
		int height = (font_height * surface_items) + (ITEM_SPACING * surface_items) + (ITEM_SPACING * 2);
		surface = new Surface.RGB(SurfaceFlag.SWSURFACE, this.surface_width, height, DEPTH, format.Rmask, format.Gmask, format.Bmask, format.Amask);
		surface.fill(null, background_color_rgb);

		Rect rect = {0, ITEM_SPACING};
		for(int index=0; index < item_count; index++) {
			if (selected_index == index)
				items.get_item_selected_rendering(index).blit(null, surface, rect);
			else
				items.get_item_rendering(index).blit(null, surface, rect);
			rect.y = (int16)(rect.y + font_height + ITEM_SPACING);
		}

		surface.flip();
	}

	public abstract int get_item_count();
	public abstract string get_item_name(int index);

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
