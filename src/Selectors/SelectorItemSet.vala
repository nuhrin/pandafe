using Gee;
using SDL;
using SDLTTF;
using Catapult;

public class SelectorItemSet : Object
{
	const RegexCompileFlags REGEX_COMPILE_FLAGS = RegexCompileFlags.CASELESS | RegexCompileFlags.MULTILINE | RegexCompileFlags.NEWLINE_LF;
	const RegexMatchFlags REGEX_MATCH_FLAGS = RegexMatchFlags.PARTIAL | RegexMatchFlags.NEWLINE_LF;

	TFunc2<Selector,int, string> get_item_func;
	Selector selector;
	Surface[] item_renderings;
	int items_rendered_count;
	int[] item_positions;
	string items_str;

	InterfaceHelper @interface;

	public class SelectorItemSet(InterfaceHelper @interface, Selector selector, TFunc2<Selector,int, string> get_item_func) {
		this.@interface = @interface;
		@interface.font_updated.connect(flush_renderings);
		@interface.colors_updated.connect(flush_renderings);
		this.selector = selector;
		this.get_item_func = get_item_func;

		flush_renderings();

		// concatenate items into single string and note indexes (for quick regex searching)
		int item_count = selector.get_item_count();
		var sb = new StringBuilder();
		item_positions = new int[item_count];
		for(int index=0; index<item_count; index++) {
			item_positions[index] = (int)sb.len;
			sb.append("%s\n".printf(get_item_func(selector, index).strip()));
		}
		items_str = sb.str;
	}

	public bool search(string pattern, out ArrayList<int> matching_indexes, out bool is_partial) {
		if (item_positions.length == 0)
			return false;

		Regex regex = null;
		try {
			regex = new Regex(pattern, REGEX_COMPILE_FLAGS, REGEX_MATCH_FLAGS);
		} catch(RegexError e) {
			debug("Error during search: %s", e.message);
			return false;
		}
		var filter_match_indexes = new ArrayList<int>();
		bool has_full_match = false;

		int matched_item_index = 0;
		int last_item_index = item_positions.length - 1;
		MatchInfo match_info;
		regex.match(items_str, 0, out match_info);
		while((matched_item_index < item_positions.length) && match_info.matches()) {
			if (has_full_match == false && match_info.is_partial_match() == false)
				has_full_match = true;

			int match_position;
			if (match_info.fetch_pos(0, out match_position, null) == true) {
				if (match_position < item_positions[matched_item_index])
					continue;
				while(match_position >= item_positions[matched_item_index + 1] && (matched_item_index < last_item_index))
					matched_item_index++;

				filter_match_indexes.add(matched_item_index);
				matched_item_index++;
			}
			try {
				match_info.next();
			} catch(RegexError e) {
				debug("Error during search: %s", e.message);
				break;
			}
		}
		matching_indexes = filter_match_indexes;
		is_partial = !has_full_match;
		return (filter_match_indexes.size > 0);
	}

	//
	// rendering related
	//
	public bool all_items_rendered { get { return (items_rendered_count == item_renderings.length); } }
	public unowned Surface get_item_rendering(int index) {
		if (index < 0 || index >= item_renderings.length)
			GLib.error("Index out of range.");

		if (item_renderings[index] == null)
			item_renderings[index] = @interface.render_text(get_item_func(selector, index));

		return item_renderings[index];
	}
	public Surface get_item_selected_rendering(int index) {
		if (index < 0 || index >= item_positions.length)
			GLib.error("Index out of range.");
		return @interface.render_text_selected(get_item_func(selector, index));
	}
	public Surface get_item_blank_rendering(int index) {
		if (index < 0 || index >= item_positions.length)
			GLib.error("Index out of range.");
		return @interface.render_text_blank(get_item_func(selector, index));
	}
	void flush_renderings() {
		item_renderings = new Surface[selector.get_item_count()];
		items_rendered_count = 0;
	}
}
