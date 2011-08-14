using SDL;
using SDLTTF;

public abstract class Selector : Object
{
	const int DEPTH = 32;
	const int16 ITEM_SPACING = 5;
	const Color ITEM_COLOR = {255, 255, 255};
	const Color SELECTED_ITEM_COLOR = {0, 100, 255};
	Surface surface;
	unowned Font font;
	unowned PixelFormat format;
	int font_height;
	int surface_width;
	int visible_items;

	protected Selector(PixelFormat* format, Font* font, int width, int visible_items) {
		this.format = format;
		this.font = font;
		font_height = (int16)this.font.height();
		surface_width = width;
		this.visible_items = visible_items;
		selected_index = -1;
	}
	public int selected_index { get; private set; }

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

	public bool select_item(int index) {
		int16 offset = get_item_offset(index);
		if (offset == -1)
			return false;

		ensure_surface();

		if (selected_index != -1) {
			Rect oldrect = {0, get_item_offset(selected_index)};
			font.render_blended(get_item_name(selected_index), ITEM_COLOR).blit(null, surface, oldrect);
		}
		Rect rect = {0, offset};
		font.render_blended(get_item_name(index), {0,0,0}).blit(null, surface, rect);
		font.render_blended(get_item_name(index), SELECTED_ITEM_COLOR).blit(null, surface, rect);

		surface.flip();
		selected_index = index;

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

		Rect rect = {0, ITEM_SPACING};
		for(int index=0; index < item_count; index++) {
			var name = get_item_name(index);
			var text = font.render_blended(name, ITEM_COLOR);
			text.blit(null, surface, rect);
			rect.y = (int16)(rect.y + font_height + ITEM_SPACING);
		}

		surface.flip();
	}

	protected abstract int get_item_count();
	protected abstract string get_item_name(int index);
}
