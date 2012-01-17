using Gee;
using SDL;
using SDLTTF;
using Layers;
using Layers.MenuBrowser;

namespace Layers.Controls.Chooser
{
	public abstract class ChooserBase : ScreenLayer
	{		
		const int16 SELECTOR_XPOS = 100;
		const int16 SELECTOR_YPOS = 70;

		bool event_loop_done;
		
		HashMap<string, ChooserSelector> selector_hash;
		ChooserSelector selector;
		ChooserHeader header;

		protected ChooserBase(string id, string title) {
			base(id);
			selector_hash = new HashMap<string, ChooserSelector>();
			header = add_layer(new ChooserHeader("header")) as ChooserHeader;
			header.title = title;
		}

		public string? run(string starting_key, string? secondary_starting_key=null) {
			selector = get_selector(get_first_run_key(starting_key));
			add_layer(selector);
			@interface.push_screen_layer(this);
			update_chooser();
			
			uint index = get_first_run_selection_index(starting_key);
			if (index == 0 || selector.select_item(index) == false)
				selector.select_first();
			
			while(event_loop_done == false) {
				process_events();
				@interface.execute_idle_loop_work();
			}
			@interface.pop_screen_layer();
			
			return get_run_result();
		}
		protected virtual string get_first_run_key(string starting_key) { return starting_key; }
		protected virtual uint get_first_run_selection_index(string starting_key) {
			return (selector.is_root) ? 0 : 1;
		}
		protected abstract string? get_run_result();
		protected uint get_index_of_item_named(string name) {
			int index = selector.get_index_of_item_named(name);
			return (index < 0) ? 0 : index;
		}
				
		ChooserSelector get_selector(string key) {
			if (selector_hash.has_key(key) == true)
				return selector_hash[key];
				
			var new_selector = create_selector(key, SELECTOR_XPOS, SELECTOR_YPOS);
			new_selector.changed.connect(() => on_selector_changed());
			selector_hash[key] = new_selector;
			return new_selector;
		}
		protected abstract ChooserSelector create_selector(string key, int16 xpos, int16 ypos);
		
		//
		// screen updates
		void update_chooser() {
			update_header(header, selector);
		}
		protected abstract void update_header(ChooserHeader header, ChooserSelector selector);
		protected virtual void on_selector_changed() {
		}

		//
		// events
		void process_events() {
			Event event;
			while(Event.poll(out event) == 1) {
				switch(event.type) {
					case EventType.QUIT:
						this.event_loop_done = true;
						break;
					case EventType.KEYDOWN:
						this.on_keydown_event(event.key);
						break;
				}
			}
		}
		void drain_events() {
			Event event;
			while(Event.poll(out event) == 1);
		}
		void on_keydown_event (KeyboardEvent event) {
			if (process_unicode(event.keysym.unicode) == false)
				return;

			if (event.keysym.mod == KeyModifier.NONE) {
				switch(event.keysym.sym) {
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
					case KeySymbol.PAGEUP: // pandora Y
						select_first();
						break;
					case KeySymbol.PAGEDOWN: // pandora X
						select_last();
						break;
					case KeySymbol.RETURN:
					case KeySymbol.KP_ENTER:
					case KeySymbol.END: // pandora B
						activate_selected();
						drain_events();
						break;
					case KeySymbol.HOME: // pandora A
						go_back();
						drain_events();
						break;
					case KeySymbol.ESCAPE:
						this.event_loop_done = true;
						break;
					default:
						break;
				}
				return;
			}
		}
		bool process_unicode(uint16 unicode) {
			if (process_unicode_disabled)
				return true;

			if (unicode <= uint8.MAX) {
				char c = (char)unicode;
				if (c.isalnum() == true) {
					//debug("'%c' pressed", c);
					select_next_starting_with(c);
					return false;
				}
			}
			return true;
		}
		bool process_unicode_disabled;

		//
		// commands: selection
		void select_previous() {
			selector.select_previous();
		}
		void select_previous_page() {
			selector.select_previous_page();
		}
		void select_next() {
			selector.select_next();
		}
		void select_next_page() {
			selector.select_next_page();
		}
		void select_first() {
			selector.select_first();
		}
		void select_last() {
			selector.select_last();
		}
		void select_next_starting_with(char c) {
			if (last_pressed_alphanumeric == c) {
				last_pressed_alphanumeric_repeat_count++;
			} else {
				last_pressed_alphanumeric = c;
				last_pressed_alphanumeric_repeat_count = 0;
			}
			if (last_pressed_alphanumeric_repeat_count > 0) {
				if (selector.select_item_starting_with(last_pressed_alphanumeric.to_string(), last_pressed_alphanumeric_repeat_count) == true)
					return;				
				last_pressed_alphanumeric_repeat_count = 0;
			}
			selector.select_item_starting_with(last_pressed_alphanumeric.to_string());
		}
		char last_pressed_alphanumeric = 0;
		int last_pressed_alphanumeric_repeat_count;

		//
		// commands: misc
		protected abstract bool process_activation(ChooserSelector selector);
		protected abstract string get_selected_key(ChooserSelector selector);
		protected abstract string get_parent_key(ChooserSelector selector);
		protected abstract string get_parent_child_name(ChooserSelector selector);
		
		void activate_selected() {
			selector.choose_selected_item_secondary_id();
			if (process_activation(selector) == true) {
				this.event_loop_done = true;
				return;
			}
			if (selector.is_go_back_item_selected) {
				go_back();
				return;
			}
			
			selector = get_selector(get_selected_key(selector));
			replace_layer(selector.id, selector);
			clear();
			update_chooser();
			selector.select_first();
		}

		void go_back() {
			if (selector.is_root)
				return;
			
			var parent_key = get_parent_key(selector);
			debug("parent_key: %s", parent_key);
			var parent_child_name = get_parent_child_name(selector);
			debug("parent_child_name: %s", parent_child_name);
			
			selector = get_selector(parent_key);
			replace_layer(selector.id, selector);
			clear();
			update_chooser();
			if (selector.select_item_named(parent_child_name) == false)
				selector.select_first();
		}

	}
}
