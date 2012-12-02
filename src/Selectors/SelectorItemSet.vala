/* SelectorItemSet.vala
 * 
 * Copyright (C) 2012 nuhrin
 * 
 * This file is part of Pandafe.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *      nuhrin <nuhrin@oceanic.to>
 */

using Gee;
using SDL;
using SDLTTF;
using Catapult;

public class SelectorItemSet : Object
{
	const RegexCompileFlags REGEX_COMPILE_FLAGS = RegexCompileFlags.CASELESS | RegexCompileFlags.MULTILINE | RegexCompileFlags.NEWLINE_LF;
	const RegexMatchFlags REGEX_MATCH_FLAGS = RegexMatchFlags.NEWLINE_LF;

	GameBrowserUI ui;
	Selector selector;
	Surface[] item_renderings;
	int items_rendered_count;
	int[] item_positions;
	Gee.List<int> folder_item_indexes;
	string items_str;
	int first_rendered_item;
	int last_rendered_item;
		
	public SelectorItemSet(Selector selector, GameBrowserUI? ui=null) {
		this.ui = ui ?? @interface.game_browser_ui;
		this.selector = selector;

		flush_renderings();

		// concatenate items into single string and note indexes (for quick regex searching)
		int item_count = selector.item_count;
		var sb = new StringBuilder();
		item_positions = new int[item_count];
		folder_item_indexes = new ArrayList<int>();
		for(int index=0; index<item_count; index++) {
			string name = selector.get_item_name(index);
			item_positions[index] = (int)sb.len;
			if (name.has_suffix("/") == true) {
				folder_item_indexes.add(index);
				sb.append("\n");
			} else {
				sb.append("%s\n".printf(selector.get_item_name(index).strip()));
			}
		}
		folder_item_indexes = folder_item_indexes.read_only_view;
		items_str = sb.str;

		first_rendered_item = item_count / 2;
		last_rendered_item = first_rendered_item;
		@interface.connect_idle_function("selector_item_set", rendering_iteration);
		ui.font_updated.connect(flush_renderings);
		ui.colors_updated.connect(flush_renderings);
	}

	public Gee.List<int> get_folder_indexes() { return folder_item_indexes; }

	public bool search(string pattern, out Gee.List<int> matching_indexes) {
		matching_indexes = null;
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

		int matched_item_index = 0;
		int last_item_index = item_positions.length - 1;
		MatchInfo match_info;
		regex.match(items_str, 0, out match_info);
		while((matched_item_index < item_positions.length) && match_info.matches()) {
			int match_position;
			if (match_info.fetch_pos(0, out match_position, null) == true) {
				if (match_position >= item_positions[matched_item_index]) {
					while(match_position >= item_positions[matched_item_index + 1] && (matched_item_index < last_item_index))
						matched_item_index++;

					filter_match_indexes.add(matched_item_index);
					matched_item_index++;
				}
			}
			try {
				match_info.next();
			} catch(RegexError e) {
				debug("Error during search: %s", e.message);
				break;
			}
		}
		matching_indexes = filter_match_indexes.read_only_view;
		return (filter_match_indexes.size > 0);
	}

	//
	// rendering related
	//
	public bool all_items_rendered { get { return (items_rendered_count == item_renderings.length); } }
	public unowned Surface get_item_rendering(int index) {
		if (index < 0 || index >= item_renderings.length)
			GLib.error("Index (%d) out of range.", index);

		if (item_renderings[index] == null)
			item_renderings[index] = ui.render_text(selector.get_item_name(index));

		return item_renderings[index];
	}
	public Surface get_item_selected_rendering(int index) {
		if (index < 0 || index >= item_renderings.length)
			GLib.error("Index (%d) out of range.", index);
		
		return ui.render_text_selected(selector.get_item_full_name(index));
	}
	public void flush_renderings() {
		item_renderings = new Surface[selector.item_count];
		items_rendered_count = 0;
	}
	void rendering_iteration() {
		bool done = true;
		if (first_rendered_item > 0) {
			first_rendered_item--;
			get_item_rendering(first_rendered_item);
			done = false;
		}
		if (last_rendered_item < selector.item_count - 1) {
			last_rendered_item++;
			get_item_rendering(last_rendered_item);
			done = false;
		}
		if (done == true)
			@interface.disconnect_idle_function("selector_item_set");
	}
}
