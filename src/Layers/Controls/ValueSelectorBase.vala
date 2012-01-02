using SDL;
using SDLTTF;
using Gee;

namespace Layers.Controls
{
	public abstract class ValueSelectorBase<G> : Layers.Layer 
	{
		bool event_loop_done;

		Surface surface;
		unowned Font font;
		int16 font_height;
		int16 xpos;
		int16 ypos;
		int16 max_text_width;
		int max_characters;
		int16 window_height;
		int _height;
		int _width;
		Surface blank_name_area;
		Surface select_name_area;
		int16 item_spacing;
		int visible_items;
		
		ArrayList<G> items;
		uint _selected_index;
		uint original_index;

		protected ValueSelectorBase(string id, int16 xpos, int16 ypos, int16 max_width, Iterable<G>? items=null, uint selected_index=0) {
			base(id);
			this.xpos = xpos;
			this.ypos = ypos;
			item_spacing = @interface.SELECTOR_ITEM_SPACING;
			font = @interface.get_monospaced_font();
			font_height = @interface.get_monospaced_font_height();
			max_text_width = max_width - 8;
			max_characters = max_text_width / @interface.get_monospaced_font_width(1);
			
			this.items = new ArrayList<G>();
			if (items != null)
				set_items(items);
			if (selected_index < this.items.size) {
				_selected_index = selected_index;
				original_index = selected_index;
			}
		}
		
		public uint selected_index {
			get { return _selected_index; }
			set {
				if (items.size == 0)
				GLib.error("ValueSelector '%s' has no items.", id);
				if (value > items.size)
					_selected_index = items.size -1;
				else
					_selected_index = value;
			}
		}
		public G selected_item() { 
			if (items.size == 0)
				GLib.error("ValueSelector '%s' has no items.", id);
				
			return items[(int)_selected_index]; 
		}
		public string selected_item_name() {
			if (items.size == 0)
				GLib.error("ValueSelector '%s' has no items.", id);
				
			return get_item_name((int)_selected_index);
		}
		
		public void add_item(G item) {
			items.add(item);
		}
		public void set_items(Iterable<G> items) {
			this.items.clear();
			foreach(G item in items)
				add_item(item);			
		}
		public void set_items_array(G[] items) {
			this.items.clear();
			foreach(G item in items)
				add_item(item);
		}
				
		public uint run(uchar screen_alpha=128, uint32 rgb_color=0) {
			if (items.size < 2)
				GLib.error("ValueSelector '%s' has too few items (%d). At least two are required for selection to make sense.", id, items.size);
				
			ensure_surface();
			update_item_name((int)_selected_index, true);
			
			@interface.push_layer(this, screen_alpha, rgb_color);
			drain_events();
			while(event_loop_done == false) {
				process_events();
				@interface.execute_idle_loop_work();
			}
			drain_events();
			@interface.pop_layer();
			
			return _selected_index;
		}
		
		protected abstract string get_item_name(int index);
		protected G get_item_at(int index) { return items[index]; }
		
		protected override void draw() {
			if (surface == null)
				return;
			
			// draw selector			
			Rect dest_r = {xpos + 4, ypos + 5};
			uint top_index;
			uint bottom_index;
			get_display_range(selected_index, out top_index, out bottom_index);
			var items = (bottom_index - top_index) + 1;
			var height = (int16)((font_height * items) + (item_spacing * items));
			Rect source_r = {0, get_offset(top_index), (int16)_width, height};
			blit_surface(surface, source_r, dest_r);
			
			// draw rectangle
			draw_rectangle_outline(xpos, ypos, (int16)_width, height + 5, @interface.white_color);
		}
		
		void drain_events() {
			Event event;
			while(Event.poll(out event) == 1);
		}
		void process_events() {
			Event event;
			while(Event.poll(out event) == 1) {
				switch(event.type) {
					case EventType.QUIT:
						this.event_loop_done = true;
						break;
					case EventType.KEYDOWN:
						this.on_keyboard_event(event.key);
						break;
					default:
						break;
				}
			}
		}		
		void on_keyboard_event(KeyboardEvent event) {
			if (event.keysym.mod == KeyModifier.NONE) {
				switch(event.keysym.sym) {
					case KeySymbol.RETURN:
					case KeySymbol.KP_ENTER:
						event_loop_done = true;
						break;
					case KeySymbol.ESCAPE:
						this.event_loop_done = true;
						_selected_index = original_index;
						break;
					case KeySymbol.UP:
						select_previous();
						break;
					case KeySymbol.DOWN:
						select_next();
						break;
					case KeySymbol.LEFT:
						select_previous_page();
						break;
					case KeySymbol.RIGHT:
						select_next_page();
						break;
					case KeySymbol.HOME:
						select_first();
						break;
					case KeySymbol.END:
						select_last();
						break;
					default:
						break;
				}
			}
		}

		void select_previous() {
			if (_selected_index == 0)
				return;
			select_item(_selected_index - 1);
		}
		void select_previous_page() {
			if (_selected_index < visible_items) {
				select_first();
				return;
			}
			select_item(_selected_index - visible_items);
		}
		void select_next() {
			select_item(_selected_index + 1);
		}
		void select_next_page() {
			if (_selected_index + visible_items >= items.size) {
				select_last();
				return;
			}
			select_item(_selected_index + visible_items);			
		}
		void select_first() { select_item(0); }
		void select_last() { select_item(items.size - 1); }		
		void select_item(uint index) {
			if (index == _selected_index || index >= items.size)
				return;
			
			update_item_name((int)_selected_index, false);
			update_item_name((int)index, true);
			_selected_index = index;
			update();
		}

		void ensure_surface() {
			if (surface != null)
				return;
			update_selector_attributes();
			surface = @interface.get_blank_surface(_width, _height);

			Rect rect = {0, 0};
			for(int index=0; index < items.size; index++) {
				render_item(index).blit(null, surface, rect);
				rect.y = (int16)(rect.y + font_height + item_spacing);
			}
		}
		void update_selector_attributes() {
			int16 item_height = font_height + item_spacing;
			int surface_items = items.size;
			_height = (item_height * surface_items) + (item_spacing * 2);
			
			int max_name_chars = 0;
			for(int index=0; index<items.size; index++) {
				string name = get_item_name(index);
				if (name.length > max_name_chars)
					max_name_chars = name.length;
			}
			if (max_name_chars < max_characters)
				max_characters = max_name_chars;
			int name_area_width = @interface.get_monospaced_font_width(max_characters);
			_width = name_area_width + 8;//@interface.get_monospaced_font_width(2);

			blank_name_area = @interface.get_blank_surface(name_area_width, font_height);
			select_name_area = @interface.get_blank_surface(name_area_width, font_height);
			select_name_area.fill(null, @interface.highlight_color_rgb);
			
			int screen_height = @interface.screen_height;
			visible_items = (screen_height / 2) / (font_height + item_spacing);
			if (surface_items < visible_items)
				visible_items = surface_items;				
			window_height = (int16)(item_height * visible_items) + (item_spacing * 2);			

			// reposition to keep selector on screen, if necessary
			while (window_height + ypos > screen_height) {
				if (ypos < 0) {
					ypos = item_height - 1;
					visible_items--;
					window_height -= item_height;					
				} else {
					ypos -= item_height;
				}
			}
		}

		Surface render_item(int index) {
			return font.render_shaded(get_display_name(index), @interface.white_color, @interface.black_color);
		}
		void update_item_name(int index, bool selected=false) {
			Rect rect = {0, get_offset(index)};
			if (selected == true) {
				select_name_area.blit(null, surface, rect);
				font.render_shaded(get_display_name(index), @interface.white_color, @interface.highlight_color).blit(null, surface, rect);
			} else {
				blank_name_area.blit(null, surface, rect);
				font.render_shaded(get_display_name(index), @interface.white_color, @interface.black_color).blit(null, surface, rect);
			}
		}
		string get_display_name(int index) {
			string name = get_item_name(index);
			if (name.length > max_characters)
				return name.substring(0, max_characters);
			return name;
		}
		int16 get_offset(uint index) {
			return (int16)((font_height * index) + (item_spacing * index));
		}
		void get_display_range(uint center_index, out uint top_index, out uint bottom_index) {
			int top = (int)center_index - (visible_items / 2);
			if (top < 0)
				top = 0;
			int bottom = top + visible_items - 1;
			if (bottom >= items.size)
				bottom = items.size - 1;
			if ((bottom - top) < visible_items - 1)
				top = bottom - visible_items + 1;
			if (bottom < visible_items - 1 || top < 0)
				top = 0;			
			top_index = (uint)top;
			bottom_index = (uint)bottom;	
		}

	}
}
