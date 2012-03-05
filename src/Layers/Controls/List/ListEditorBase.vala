using SDL;
using Gee;
using Menus;
using Layers.MenuBrowser;

namespace Layers.Controls.List
{
	public abstract class ListEditorBase<G> : ScreenLayer
	{
		const int16 SELECTOR_XPOS = 100;
		const int16 SELECTOR_YPOS = 70;
		const int16 MENU_SELECTOR_XPOS = 80;
		const int16 MENU_SELECTOR_YPOS = 350;
		
		bool event_loop_done;
		bool move_active;
		bool menu_active;
		bool save_requested;
		MenuHeaderLayer header;
		MenuMessageLayer message;
		ListItemSelector selector;
		MenuSelector menu_selector;
		Gee.List<G> _list;
		ArrayList<ListItem<G>> _items;
		
		protected ListEditorBase(string id, string title, string? help=null, Gee.List<G> list=new ArrayList<G>()) {
			base(id);
			_list = list;
			header = add_layer(new MenuHeaderLayer("header")) as MenuHeaderLayer;
			header.set_text(null, title, null, false);
			message = add_layer(new MenuMessageLayer("status")) as MenuMessageLayer;	
			if (help != null)
				message.help = help;
			var menu = new Menus.Menu("");
			var cancel_text = get_cancel_item_text();
			if (cancel_text != null)
				menu.add_item(new Menus.MenuItem.cancel_item(cancel_text));
			var save_text = get_save_item_text();
			if (save_text != null)
				menu.add_item(new Menus.MenuItem.save_item(save_text));
			menu_selector = add_layer(new MenuSelector("list_menu_selector", MENU_SELECTOR_XPOS, MENU_SELECTOR_YPOS, menu, 100, 0)) as MenuSelector;
			menu_selector.wrap_selector = false;
		}		
		
		public void set_header(string? left, string? center, string? right) {
			header.set_text(left, center, right);
		}
		
		public Gee.List<G> list { get { return _list; } }
		protected Gee.List<ListItem<G>> items { get { return _items; } }
		
		public bool run() {
			ensure_items();
			selector = add_layer(new ListItemSelector("list_item_selector", SELECTOR_XPOS, SELECTOR_YPOS, _items)) as ListItemSelector;
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
		protected abstract bool create_item(Rect selected_item_rect, out G item);
		protected abstract bool edit_list_item(ListItem<G> item, uint index);
		protected virtual bool confirm_deletion() { return false; }
		protected virtual bool on_delete(ListItem<G> item) { return true; }
		protected virtual bool can_edit(ListItem<G> item) { return true; }
		protected virtual bool can_delete(ListItem<G> item) { return true; }
		protected virtual bool can_insert() { return true; }
		protected virtual string? get_cancel_item_text() { return MenuItemActionType.CANCEL.name(); }
		protected virtual string? get_save_item_text() { return MenuItemActionType.SAVE.name(); }
		protected bool save_on_return { get; set; }
		
		protected Rect get_selected_item_rect() {
			return selector.get_selected_item_rect();
		}
		
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
						focus_list();
						break;
					case KeySymbol.PAGEDOWN: // pandora X
						focus_menu();
						break;
					case KeySymbol.SPACE:
					case KeySymbol.TAB:
						toggle_focus();
						break;
					case KeySymbol.RETURN:
					case KeySymbol.KP_ENTER:
					case KeySymbol.END: // pandora B
						if (move_active == true) {
							selector.move_finish();
							move_active = false;
							break;
						}
						activate_selected();
						drain_events();
						break;
					case KeySymbol.HOME: // pandora A
					case KeySymbol.ESCAPE:
						if (move_active == true) {
							selector.move_cancel();
							move_active = false;
							break;
						}
						if (save_on_return == true)
							save_requested = true;
						this.event_loop_done = true;
						break;
					default:
						break;
				}
				return;
			}
		}
		bool process_unicode(uint16 unicode) {
			if (menu_active || process_unicode_disabled)
				return true;

			if (unicode <= uint8.MAX) {
				char c = (char)unicode;
				if (c.isalnum() == true) {
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
			if (menu_active)
				menu_selector.select_previous();
			else
				selector.select_previous();
		}
		void select_previous_page() {
			if (menu_active == false)
				selector.select_previous_page();
		}
		void select_next() {
			if (menu_active)
				menu_selector.select_next();
			else
				selector.select_next();
		}
		void select_next_page() {
			if (menu_active == false)
				selector.select_next_page();
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
		void focus_list() {
			if (menu_active == false)
				return;
			menu_active = false;
			menu_selector.hide_selection(false);
			selector.show_selection();
		}
		void focus_menu() {
			if (menu_active == true)
				return;
			menu_active = true;
			selector.hide_selection(false);
			menu_selector.show_selection();
		}
		void toggle_focus() {
			if (menu_active)
				focus_list();
			else
				focus_menu();
		}
		void activate_selected() {
			if (menu_active) {
				// menu_item selected
				MenuItemActionType action = menu_selector.selected_item().action;
				switch(action) {
					case MenuItemActionType.CANCEL:
						event_loop_done = true;
						break;
					case MenuItemActionType.SAVE:
						save_requested = true;
						event_loop_done = true;
						break;
					default:
						break;										
				}
				return;
			}
			// item selected
			ListItemActionType action = ListItemActionType.INSERT_BELOW;
			Rect rect = selector.get_selected_item_rect();
			if (selector.item_count > 0) {
				var selected_item = selector.selected_item();
				bool move_ok = (selector.item_count > 1);
				action = new ListItemActionSelector("item_action_selector", rect.x + (int16)rect.w, rect.y, 
					can_edit(selected_item), can_delete(selected_item), move_ok, can_insert())
					.run();				
			}
			switch(action) {
				case ListItemActionType.EDIT:
					if (edit_list_item((ListItem<G>)selector.selected_item(), selector.selected_index) == true) {
						selector.reset();
						update();						
					}
					break;
				case ListItemActionType.INSERT_ABOVE:
					G item;
					if (create_item(rect, out item) == false)
						break;
					var list_item = get_list_item(item);
					selector.insert_item_before_selected(list_item);
					update();
					if (can_edit(list_item) == true) {
						var index = selector.selected_index;										
						if (edit_list_item(list_item, index) == true) {
							selector.reset();
						} else {
							selector.remove_selected_item();
						}
						update();
					}					
					break;
				case ListItemActionType.INSERT_BELOW:
					G item;
					if (create_item(rect, out item) == false)
						break;
					var list_item = get_list_item(item);
					selector.insert_item_after_selected(list_item);
					update();
					if (can_edit(list_item) == true) {
						var index = selector.selected_index;
						if (edit_list_item(list_item, index) == true) {
							selector.reset();
							update();
						} else {
							selector.remove_selected_item();
							selector.select_item(index, false);
							update();
						}
					}
					break;
				case ListItemActionType.MOVE:
					selector.move_start();
					move_active = true;
					break;				
				case ListItemActionType.DELETE:
					// todo: confirmation "dialog"
					if (confirm_deletion() == true) {
						if (new DeleteConfirmation("delete_confirmation", rect.x + (int16)rect.w, rect.y).run() == false)
							break;
					}
					if (on_delete(selector.selected_item()) == true) {
						selector.remove_selected_item();
						update();
					}					
					break;
				default:
					break;
			}

		}
		class DeleteConfirmation : StringSelector
		{
			const string CANCEL_TEXT = ".. cancel";
			const string CONFIRM_TEXT = "!! Confirm";
			public DeleteConfirmation(string id, int16 xpos, int16 ypos)
			{
				base(id, xpos, ypos, 200);
				for(int index=0;index<7;index++)
					add_item(CANCEL_TEXT);
				add_item(CONFIRM_TEXT);
				add_item(CANCEL_TEXT);
				add_item(CANCEL_TEXT);
			}
			public new bool run(uchar screen_alpha=128, uint32 rgb_color=0) {
				base.run(screen_alpha, rgb_color);
				return (selected_item() == CONFIRM_TEXT);
			}
		}
	}
}
