using Gee;
using SDL;
using SDLTTF;
using Layers;
using Layers.Controls.Chooser;
using Layers.MenuBrowser;

namespace Layers.Controls
{
	public class FileChooser : ScreenLayer
	{		
		const RegexCompileFlags REGEX_COMPILE_FLAGS = RegexCompileFlags.OPTIMIZE | RegexCompileFlags.CASELESS |
													  RegexCompileFlags.MULTILINE | RegexCompileFlags.NEWLINE_LF;
		const RegexMatchFlags REGEX_MATCH_FLAGS = RegexMatchFlags.NEWLINE_LF;
		const int16 SELECTOR_XPOS = 100;
		const int16 SELECTOR_YPOS = 70;
		const string SELECTOR_ID = "folder_selector";
		
		bool event_loop_done;
		ChooserHeader header;
		
		string root_path;
		HashMap<string, FileSelector> selector_hash;
		FileSelector selector;
		string? selected_path;
		Regex? regex_file_filter;

		public FileChooser(string id, string title, string? file_extensions=null, string? root_path=null) {			
			base(id);
			if (root_path != null && FileUtils.test(root_path, FileTest.IS_DIR) == true)
				this.root_path = root_path;
			else
				this.root_path = "/";
									
			selector_hash = new HashMap<string, FileSelector>();
			if (file_extensions != null)
				regex_file_filter = get_file_extensions_regex(file_extensions);
			header = add_layer(new ChooserHeader("header")) as ChooserHeader;
			header.title = title;
		}

		public string? run(string starting_path) {
			bool is_dir = FileUtils.test(starting_path, FileTest.IS_DIR);
			if (starting_path.has_prefix(root_path) == true) {
				selector = (is_dir == false)
					? get_selector(Path.get_dirname(starting_path))
					: selector = get_selector(starting_path);				
			} else {
				selector = get_selector(root_path);
			}
			add_layer(selector);
			@interface.push_screen_layer(this);
			update_chooser();
			if (is_dir == true)
				selector.select_first();
			else
				selector.select_item_named(Path.get_basename(starting_path));
			while(event_loop_done == false) {
				process_events();
				@interface.execute_idle_loop_work();
			}
			@interface.pop_screen_layer();
			
			return selected_path;
		}
				
		FileSelector get_selector(string path) {
			if (selector_hash.has_key(path) == true)
				return selector_hash[path];
				
			var new_selector = new FileSelector(SELECTOR_ID, SELECTOR_XPOS, SELECTOR_YPOS, path, regex_file_filter, (path == root_path));
			new_selector.changed.connect(() => on_selector_changed());
			selector_hash[path] = new_selector;
			return new_selector;
		}
		
		Regex? get_file_extensions_regex(string file_extensions) {
			var parts = file_extensions.split_set(" .;,");
			var exts = new ArrayList<string>();
			foreach(var part in parts) {
				part = part.strip();
				if (part != "")
					exts.add(part);
			}
			if (exts.size == 0)
				return null;

			try {
				if (exts.size == 1)
					return new Regex("\\.%s$".printf(exts[0]), REGEX_COMPILE_FLAGS, REGEX_MATCH_FLAGS);

				var sb = new StringBuilder("\\.(");
				bool have_first = false;
				foreach(var ext in exts) {
					if (have_first == true) {
						sb.append("|");
						sb.append(ext);
					} else {
						sb.append(ext);
						have_first = true;
					}
				}
				sb.append(")$");
				return new Regex(sb.str, REGEX_COMPILE_FLAGS, REGEX_MATCH_FLAGS);
			} catch(RegexError e) {
				debug("Error creating file extension regex: %s", e.message);
			}
			return null;
		}
		
		//
		// screen updates
		void update_chooser() {
			header.path = selector.path;
		}
		void on_selector_changed() {
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
			if (selector.is_folder_selected == false) {
				// choose this file
				selected_path = selector.selected_path();
				this.event_loop_done = true;
				return;
			}			
			if (selector.is_go_back_item_selected) {
				go_back();
				return;
			}
			
			selector = get_selector(selector.selected_path());
			replace_layer(SELECTOR_ID, selector);
			clear();
			update_chooser();
			selector.select_first();
		}

		void go_back() {
			string path = selector.path;
			if (path == root_path)
				return;
			
			selector = get_selector(Path.get_dirname(path));
			replace_layer(SELECTOR_ID, selector);
			clear();
			update_chooser();
			if (selector.select_item_named(Path.get_basename(path) + Path.DIR_SEPARATOR_S) == false)
				selector.select_first();
		}		

	}
}
