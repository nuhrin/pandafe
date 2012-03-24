using SDL;
using SDLTTF;
using Gee;

public abstract class Selector : Layers.Layer
{
	const int ITEMS_PER_SURFACE = 50;
	const int MAX_WIDTH = 680;
	
	GameBrowserUI ui;
	SelectorSurfaceSet surfaces;
	int index_before_select_first;
	int index_before_select_last;
	int visible_items;
	int16 item_spacing;
	string _filter;
	Gee.List<int> _filter_match_indexes;
	HashMap<int,int> _filter_index_position_hash;
	
	protected Selector(string id, int16 xpos, int16 ypos, GameBrowserUI? ui=null) {
		base(id);
		this.ui = ui ?? @interface.game_browser_ui;
		this.xpos = xpos;
		this.ypos = ypos;
		selected_index = -1;
		index_before_select_first = -1;
		index_before_select_last = -1;
		update_font();
		this.ui.font_updated.connect(update_font);
		this.ui.colors_updated.connect(reset_surface);		
	}

	public int16 xpos { get; set; }
	public int16 ypos { get; set; }
	
	SelectorItemSet items {
		get {
			if (_items == null)
				_items = new SelectorItemSet(this, ui);			

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
	public int selected_index { get; protected set; }
	public int selected_display_index() { return get_display_index_from_index(selected_index); }

	protected override void draw() {
		Rect dest = {xpos, ypos};
		if (display_item_count == 0) {
			blit_surface(ui.render_text("(no items)"), null, dest);
			return;
		}
		var s_display_index = selected_display_index();
		if (s_display_index < 0)
			s_display_index = 0;
		if (surfaces == null)
			ensure_surfaces(s_display_index);
		var window = surfaces.get_window(s_display_index);
		blit_surface(window.surface_one.get_surface(), window.rect_one, dest);		
		if (window.surface_two != null) {
			dest.y += (int16)window.rect_one.h;
			blit_surface(window.surface_two.get_surface(), window.rect_two, dest);
		}
	}
	public signal void loading();
	public signal void rebuilt();
	public void rebuild() {
		reset_surface();
		_items = null;
		_item_count = -1;
		int index = selected_index;
		selected_index = -1;
		rebuild_items(index);
		rebuilt();
	}
	protected abstract void	rebuild_items(int selection_index);

	public bool has_previous { get { return selected_display_index() > 0; } }
	public bool has_next { get { return selected_display_index() < display_item_count - 1; } }

	public bool select_previous() {
		if (has_previous == false)
			return false;

		return select_display_item(selected_display_index() - 1);
	}
	public bool select_previous_page() {
		return select_previous_by((uint)visible_items);
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
	public bool select_next_page() {
		return select_next_by((uint)visible_items);
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
		if (items.search("^" + str, out matching_indexes) == false)
			return false;

		if (matching_indexes.size >= index + 1)
			return select_item(matching_indexes[index]);

		return false;
	}
	public bool select_item(int index, bool flip=true) {
		return select_display_item(get_display_index_from_index(index), flip);
	}
	public bool select_display_item(int display_index, bool flip=true) {
		index_before_select_first = -1;
		index_before_select_last = -1;

//~ 		debug("select_display_item(): %d", display_index);
		ensure_surfaces(display_index);
		if (surfaces.select_item(display_index, selected_display_index()) == true) {
			selected_index = get_index_from_display_index(display_index);
			update(flip);
			return true;
		}
		return false;
	}
	public void ensure_selection(bool flip=true) {
		if (selected_index >= 0 || display_item_count == 0) {
			update(flip);
			return;
		}
		select_item(0, flip);
	}

	public bool filter(string pattern) {
		_filter = pattern;
		_filter_match_indexes = new ArrayList<int>();
		_filter_match_indexes.add_all(items.get_folder_indexes());
		_filter_index_position_hash = new HashMap<int,int>();
		//debug("filtering by '%s'", pattern);
		Gee.List<int> matching_indexes;
		bool success;
		success = items.search(pattern, out matching_indexes);
		if (success == true)
			_filter_match_indexes.add_all(matching_indexes);

		var display_index = get_closest_display_index(selected_index);

		for(int index=0; index<_filter_match_indexes.size; index++)
			_filter_index_position_hash[_filter_match_indexes[index]] = index;

		if (display_index != -1)
			select_display_item(display_index, false);
		
		rebuild();
		return success;
	}
	public void clear_filter() {
		_filter = null;
		_filter_match_indexes = null;
		_filter_index_position_hash = null;
		rebuild();
	}
	public string? get_filter_pattern() { return _filter; }

	public abstract int get_itemcount();
	public abstract string get_item_name(int index);
	public abstract string get_item_full_name(int index);

	void reset_surface() {
		surfaces = null;
	}
	void update_font() {
		item_spacing = ui.font_height / 4;
		int16 max_height = (int16)@interface.screen_height - (ui.font_height * 2) - 10 - ypos;
		visible_items = max_height / (ui.font_height + item_spacing);
		reset_surface();
	}

	void ensure_surfaces(int display_index) {		
		if (surfaces == null)
			surfaces = new SelectorSurfaceSet(display_item_count, ITEMS_PER_SURFACE, this, get_index_from_display_index);
		surfaces.ensure_surfaces(display_index);
	}

	int get_index_from_display_index(int display_index) {		
		if (display_index < 0 || display_index >= display_item_count)
			return -1;
		if (_filter_match_indexes == null)
			return display_index;

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
	
	class SelectorWindow : Object {
		public SelectorWindow(int16 width) {
			rect_one = {0,0,width,0};
			rect_two = {0,0,width,0};
		}
		public SelectorSurface? surface_one;
		public Rect rect_one;
		public SelectorSurface? surface_two;
		public Rect rect_two;
	}
	delegate int TransformIndex(int index);
	class SelectorSurfaceSet : Object {
		SelectorItemSet items;
		Selector selector;
		int16 font_height;
		
		TransformIndex get_index_from_display_index;
		int item_count;
		int items_per_surface;
		SelectorSurface? top;
		SelectorSurface? mid;
		SelectorSurface? bot;
		int surface_count;
		int top_index;
		int mid_index;
		int bot_index;
		int visible_items;
		int16 item_spacing;
		SelectorWindow window;

		public SelectorSurfaceSet(int item_count, int items_per_surface, Selector selector, owned TransformIndex get_index_from_display_index) {
			this.item_count = item_count;
			this.items_per_surface = items_per_surface;
			this.selector = selector;
			this.items = selector.items;
			font_height = selector.ui.font_height;
			this.get_index_from_display_index = (owned)get_index_from_display_index;

			surface_count = (item_count + items_per_surface - 1) / items_per_surface;
			if (surface_count < 1)
				surface_count = 1;
			top_index = -1;
			mid_index = -1;
			bot_index = -1;

			visible_items = selector.visible_items;
			item_spacing = selector.item_spacing;
		}
		public bool select_item(int new_index, int old_index) {
			//debug("SelectorSurfaceSet.select_item(%d, %d)", new_index, old_index);
			var ss_new = get_surface_for_index(new_index);
			if (ss_new == null)
				return false;
			bool result = ss_new.select_item(new_index);
			var ss_old = get_surface_for_index(old_index);
			if (ss_old != null)
				ss_old.unselect_item(old_index);

			return result;
		}
		public void ensure_surfaces(int display_index) {
			if (display_index < 0 || display_index > item_count - 1)
				return;

			if (surface_count == 1) { 					// one surface only
//~ 				debug("one surface only");
				if (top == null)
					top = create_surface(0, true);
				top.ensure_surface(display_index);
				return;
			}

			int display_page = ((display_index + items_per_surface) / items_per_surface) - 1;
			if (surface_count == 2) {			// two surfaces only
//~ 				debug("two surface only");
				if (top == null)
					top = create_surface(0);
				if (mid == null)
					mid = create_surface(1, true);

				top.ensure_surface(display_index);
				mid.ensure_surface(display_index);
				return;
			}
			if (surface_count == 3) {			// three surfaces only
//~ 				debug("three surface only");
				if (top == null)
					top = create_surface(0);
				if (mid == null)
					mid = create_surface(1);
				if (bot == null)
					bot = create_surface(2, true);

				top.ensure_surface(display_index);
				mid.ensure_surface(display_index);
				bot.ensure_surface(display_index);
				return;
			}

			//
			// three dymanic surfaces
			if (display_page == 0) { 	// top surface at top of selector
//~ 				debug("top surface at top of selector");
				if (top_index == 1) {
					// reuse existing top as mid
					mid = top;
					mid_index = 1;
				}
				if (top_index != 0) {
					top = create_surface(0);
					top_index = 0;
				}
				if (mid_index != 1) {
					mid = create_surface(1);
					mid_index = 1;
				}
				if (bot_index != 2) {
					bot = create_surface(2);
					bot_index = 2;
				}
				top.ensure_surface(display_index);
				mid.ensure_surface(display_index);
				bot.ensure_surface(display_index);
				return;
			}

			if (display_page == 1) { 	// mid surface at top of selector
//~ 				debug("mid surface at top of selector");
				if (mid_index == 2) {
					bot = mid;
					bot_index = 2;
				}
				if (top_index == 1) {
					mid = top;
					mid_index = 1;
				}
				if (mid_index != 1) {
					mid = create_surface(1);
					mid_index = 1;
				}
				if (top_index != 0) {
					top = create_surface(0);
					top_index = 0;
				}
				if (bot_index != 2) {
					bot = create_surface(2);
					bot_index = 2;
				}
				top.ensure_surface(display_index);
				mid.ensure_surface(display_index);
				bot.ensure_surface(display_index);
				return;
			}

			int expected_bot_index = surface_count - 1;
			int expected_mid_index = expected_bot_index - 1;
			int expected_top_index = expected_mid_index - 1;
//~ 			debug("display_page: %d", display_page);
			if (display_page == expected_bot_index) { 	// bottom surface at bottom of selector
//~ 				debug("bottom surface at bottom of selector");
				if (bot_index == expected_mid_index) {
					mid = bot;
					mid_index = expected_mid_index;
				}
				if (bot_index != expected_bot_index) {
					bot = create_surface(expected_bot_index, true);
					bot_index = expected_bot_index;
				}
				if (mid_index != expected_mid_index) {
					mid = create_surface(expected_mid_index);
					mid_index = expected_mid_index;
				}
				if (top_index != expected_top_index) {
					top = create_surface(expected_top_index);
					top_index = expected_top_index;
				}
				top.ensure_surface(display_index);
				mid.ensure_surface(display_index);
				bot.ensure_surface(display_index);
				return;
			}

			if (display_page == expected_mid_index) { 	// mid surface at bottom of selector
//~ 				debug("mid surface at bottom of selector");
				if (mid_index == expected_top_index) {
					top = mid;
					top_index = expected_top_index;
				}
				if (bot_index == expected_mid_index) {
					mid = bot;
					mid_index = expected_mid_index;
				}
				if (mid_index != expected_mid_index) {
					mid = create_surface(expected_mid_index);
					mid_index = expected_mid_index;
				}
				if (bot_index != expected_bot_index) {
					bot = create_surface(expected_bot_index, true);
					bot_index = expected_bot_index;
				}
				if (top_index != expected_top_index) {
					top = create_surface(expected_top_index);
					top_index = expected_top_index;
				}
				top.ensure_surface(display_index);
				mid.ensure_surface(display_index);
				bot.ensure_surface(display_index);
				return;
			}

			// somewhere in the middle...
//~ 			debug("somewhere in the middle... (display_page: %d)", display_page);
			expected_mid_index = display_page;
			if (top_index == expected_mid_index) {
				// moving down...
//~ 				debug("moving down...");
				bot = mid;
				bot_index = mid_index;
				mid = top;
				mid_index = top_index;
			} else if (bot_index == expected_mid_index) {
				// moving up...
//~ 				debug("moving up...");
				top = mid;
				top_index = mid_index;
				mid = bot;
				mid_index = bot_index;
			}
			if (mid_index != expected_mid_index) {
				mid = create_surface(expected_mid_index);
				mid_index = expected_mid_index;
			}
			if (bot_index != expected_mid_index + 1) {
				bot = create_surface(expected_mid_index + 1);
				bot_index = expected_mid_index + 1;
			}
			if (top_index != expected_mid_index - 1) {
				top = create_surface(expected_mid_index - 1);
				top_index = expected_mid_index - 1;
			}
			top.ensure_surface(display_index);
			mid.ensure_surface(display_index);
			bot.ensure_surface(display_index);
		}
		public SelectorWindow get_window(int display_index) {
			if (window == null)
				window = new SelectorWindow(GameBrowserUI.SELECTOR_WITDH);

			int top_index;
			int bottom_index;
			get_display_range(display_index, out top_index, out bottom_index);

			var target_surface = get_surface_for_index(display_index);
			var offset = target_surface.get_offset(top_index);
			if (offset != -1) {
				window.surface_one = target_surface;
				window.rect_one.y = offset;
				if (target_surface.bottom_item_index >= bottom_index) {
					// one surface only
//~ 					debug("window: one_surface_only");
					window.rect_one.h = get_surface_window_height(top_index, bottom_index);
					window.surface_two = null;
					return window;
				}
				// two surfaces, display_index in first
//~ 				debug("window: two surfaces, display_index in first");
				window.rect_one.h = get_surface_window_height(top_index, target_surface.bottom_item_index);
				window.surface_two = get_surface_for_index(bottom_index);
				window.rect_two.y = window.surface_two.get_offset(window.surface_two.top_item_index);
				window.rect_two.h = get_surface_window_height(window.surface_two.top_item_index, bottom_index);
				return window;
			}

			// two surfaces, display_index in second
//~ 			debug("window: two surfaces, display_index in second");
			window.surface_one = get_surface_for_index(top_index);
			window.rect_one.y = window.surface_one.get_offset(top_index);
			window.rect_one.h = get_surface_window_height(top_index, window.surface_one.bottom_item_index);
			window.surface_two = target_surface;
			window.rect_two.y = target_surface.get_offset(target_surface.top_item_index);
			window.rect_two.h = get_surface_window_height(target_surface.top_item_index, bottom_index);
			return window;
		}

		SelectorSurface? get_surface_for_index(int display_index) {
			if (display_index < 0 || display_index > item_count - 1)
				return null;

			if (surface_count == 1) { 			// one surface only
				return top;
			} else if (surface_count == 2) {	// two surfaces only
				return (display_index < items_per_surface)
					? top : mid;
			} else if (surface_count == 3) {	// three surfaces only
				if (display_index < items_per_surface) {
					return top;
				} else if (display_index < (items_per_surface + items_per_surface)) {
					return mid;
				} else {
					return bot;
				}
			}

			//
			// three dymanic surfaces (assume ensure_surfaces(display_index) has been run
			if (display_index < mid.top_item_index)
				return top;
			else if (display_index > mid.bottom_item_index)
				return bot;
			else
				return mid;
		}

		SelectorSurface create_surface(int surface_index, bool is_last=false) {
//~ 			if (is_last)
//~ 				debug("creating new surface @index: %d, is_last", surface_index);
//~ 			else
//~ 				debug("creating new surface @index: %d", surface_index);
			int first_index = surface_index * items_per_surface;
			return new SelectorSurface(first_index, (is_last) ? item_count - 1 : first_index + items_per_surface - 1,
				selector, (owned)get_index_from_display_index);
		}

		int16 get_surface_window_height(int first, int last) {
			int items = (last - first) + 1;
			return (int16)((font_height * items) + (item_spacing * items));// + item_spacing);
		}
		void get_display_range(int center_index, out int top_index, out int bottom_index) {
			top_index = center_index - (visible_items / 2);
			if (top_index < 0)
				top_index = 0;
			bottom_index = top_index + visible_items - 1;
			if (bottom_index > item_count - 1)
				bottom_index = item_count - 1;
			//bottom_index--;
			if ((bottom_index - top_index) < visible_items - 1)
				top_index = bottom_index - visible_items + 1;
			if (bottom_index < visible_items - 1 || top_index < 0)
				top_index = 0;
		}
	}
	class SelectorSurface : Object {
		Selector selector;
		SelectorItemSet items;
		int16 font_height;
		TransformIndex get_index_from_display_index;
		Surface surface;
		int visible_items;
		int item_spacing;
		int first_index;
		int last_index;
		int first_rendered_index;
		int last_rendered_index;
		bool all_items_rendered;
		string idle_function_name;

		public SelectorSurface(int first_index, int last_index, Selector selector, owned TransformIndex get_index_from_display_index) {
			this.first_index = first_index;
			this.last_index = last_index;
			this.selector = selector;
			this.items = selector.items;
			font_height = selector.ui.font_height;
			this.get_index_from_display_index = (owned)get_index_from_display_index;
			first_rendered_index = -1;
			last_rendered_index = -1;
			visible_items = selector.visible_items;
			item_spacing = selector.item_spacing;
			int surface_items = last_index - first_index + 1;
			int height = (font_height * surface_items) + (item_spacing * surface_items) + (item_spacing * 2);
			surface = selector.ui.get_blank_background_surface(GameBrowserUI.SELECTOR_WITDH, height);
			idle_function_name = "selector-" + Random.next_int().to_string();
			@interface.connect_idle_function(idle_function_name, rendering_iteration);
		}
		~SelectorSurface() {
			if (idle_function_name != null)
				@interface.disconnect_idle_function(idle_function_name);			
		}

		public int item_height { get { return (last_index - first_index); } }
		public int top_item_index { get { return first_index; } }
		public int bottom_item_index { get { return last_index; } }

		public unowned Surface get_surface() { return surface; }
		public bool select_item(int display_index) {
			int16 offset = get_offset(display_index);
			if (offset == -1) {
//~ 				debug("SelectorSurface.select_item(%d): get_offset() fail!", display_index);
//~ 				debug("  first_index: %d, last_index: %d", first_index, last_index);
				return false;
			}

			ensure_surface(display_index);

			Rect rect = {0, offset};
			items.get_item_selected_rendering(get_index_from_display_index(display_index)).blit(null, surface, rect);
//~ 			debug("selected display_index: %d", display_index);
			surface.flip();

			return true;
		}
		public void unselect_item(int display_index) {
			if (display_index < first_rendered_index || display_index > last_rendered_index)
				return;
			Rect rect = {0, get_offset(display_index)};
			selector.ui.get_blank_item_surface().blit(null, surface, rect);
			items.get_item_rendering(get_index_from_display_index(display_index)).blit(null, surface, rect);
			surface.flip();
		}
		public void ensure_surface(int display_index) {
			if (all_items_rendered == true)
				return;

			if (first_rendered_index == first_index && last_rendered_index == last_index) {
				all_items_rendered = true;
				return;
			}

			int top_index;
			int bottom_index;
			get_display_range(display_index, out top_index, out bottom_index);

			if (first_rendered_index == -1) {
				render_item_range(top_index, bottom_index);
				first_rendered_index = top_index;
				last_rendered_index = bottom_index;
				surface.flip();
				return;
			}

			bool needs_flip = false;

			if (top_index < first_rendered_index) {
				render_item_range(top_index, first_rendered_index - 1);
				first_rendered_index = top_index;
				needs_flip = true;
			}
			if (bottom_index > last_rendered_index) {
				render_item_range(last_rendered_index+ 1, bottom_index);
				last_rendered_index = bottom_index;
				needs_flip = true;
			}

			if (needs_flip)
				surface.flip();
		}
		public int16 get_offset(int display_index) {
			if (display_index < this.first_index || display_index > this.last_index)
				return -1;
			var index = display_index - first_index;
			return (int16)((font_height * index) + (item_spacing * index) + item_spacing);
		}

		void get_display_range(int center_index, out int top_index, out int bottom_index) {
			top_index = center_index - (visible_items / 2);
			if (top_index < first_index)
				top_index = first_index;
			bottom_index = top_index + visible_items - 1;
			if (bottom_index > last_index)
				bottom_index = last_index;
			//bottom_index--;
			if ((bottom_index - top_index) < visible_items - 1)
				top_index = bottom_index - visible_items + 1;
			if (bottom_index < visible_items || top_index < first_index)
				top_index = first_index;
		}
		void render_item_range(int top_index, int bottom_index) {
			int16 offset = get_offset(top_index);
			if (offset == -1)
				return;
			Rect rect = {0, offset};			
			for(int display_index=top_index; display_index <= bottom_index; display_index++) {
				int index = get_index_from_display_index(display_index);
				if (index == selector.selected_index)
					items.get_item_selected_rendering(index).blit(null, surface, rect);
				else
					items.get_item_rendering(index).blit(null, surface, rect);
				rect.y = (int16)(rect.y + font_height + item_spacing);
			}
		}
		void rendering_iteration() {
			bool needs_flip = false;
			if (first_rendered_index > first_index) {
				first_rendered_index--;
				render_item_range(first_rendered_index, first_rendered_index);
				needs_flip = true;
			}
			if (last_rendered_index < last_index) {
				last_rendered_index++;
				render_item_range(last_rendered_index, last_rendered_index);
				needs_flip = true;
			}
			if (needs_flip == true) {
				surface.flip();
			} else {
				all_items_rendered = true;
				if (idle_function_name != null)
					@interface.disconnect_idle_function(idle_function_name);
			}
		}
	}
}

