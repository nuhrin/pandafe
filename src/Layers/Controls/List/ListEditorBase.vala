using SDL;
using Gee;
using Layers.MenuBrowser;

namespace Layers.Controls.List
{
	public abstract class ListEditorBase<G> : ScreenLayer
	{
		const int16 SELECTOR_XPOS = 100;
		const int16 SELECTOR_YPOS = 70;
		const string SELECTOR_ID = "list_item_selector";		
		
		bool event_loop_done;
		bool save_requested;
		MenuHeaderLayer header;
		ListItemSelector selector;
		Gee.List<G> _list;
		ArrayList<ListItem<G>> _items;
		
		protected ListEditorBase(string id, string name, Gee.List<G> list=new ArrayList<G>()) {
			base(id);
			_list = list;
			header = add_layer(new MenuHeaderLayer("header")) as MenuHeaderLayer;
			header.set_text(null, "Edit List: " + name, null, false);		
		}
		
		public Gee.List<G> list { get { return _list; } }
		
		public bool run() {
			ensure_items();
			selector = add_layer(new ListItemSelector(SELECTOR_ID, SELECTOR_XPOS, SELECTOR_YPOS, _items)) as ListItemSelector;
			@interface.push_screen_layer(this);
			selector.select_first();
			while(event_loop_done == false) {
				process_events();
				@interface.execute_idle_loop_work();
			}
			@interface.pop_screen_layer();
			
			if (save_requested) {
				_list.clear();
				foreach(var item in _items)
					_list.add(item.value);
				return true;
			}
			
			return false;
		}
		
		protected abstract ListItem<G> get_list_item(G item);
		
		void ensure_items() {
			if (_items != null)
				return;
			_items = new ArrayList<ListItem<G>>();
			foreach(var item in _list)
				_items.add(get_list_item(item));
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
		void activate_selected() {
			// item selected
			Rect rect = selector.get_selected_item_menu_rect();
			ListItemActionType action = new ListItemActionSelector("item_action_selector", rect.x + (int16)selector.width, rect.y).run();
			switch(action) {
				case ListItemActionType.EDIT:
					debug("edit");
					break;
				case ListItemActionType.MOVE:
					debug("move");
					break;
				case ListItemActionType.INSERT_ABOVE:
					debug("insert above");
					break;
				case ListItemActionType.INSERT_BELOW:
					debug("insert below");
					break;
				case ListItemActionType.DELETE:
					debug("delete");
					break;
				default:
					break;
			}

		}

		void go_back() {

		}		

	}
}
