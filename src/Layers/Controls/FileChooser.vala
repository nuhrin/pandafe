/* FileChooser.vala
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
using Layers;
using Layers.Controls.Chooser;
using Layers.MenuBrowser;

namespace Layers.Controls
{
	public class FileChooser : ChooserBase
	{		
		const RegexCompileFlags REGEX_COMPILE_FLAGS = RegexCompileFlags.OPTIMIZE | RegexCompileFlags.CASELESS |
													  RegexCompileFlags.MULTILINE | RegexCompileFlags.NEWLINE_LF;
		const RegexMatchFlags REGEX_MATCH_FLAGS = RegexMatchFlags.NEWLINE_LF;
		const string SELECTOR_ID = "file_selector";
				
		string root_path;
		string? selected_path;
		Regex? regex_file_filter;

		public FileChooser(string id, string title, string? file_extensions=null, string? root_path=null) {			
			base(id, title);
			if (root_path != null && FileUtils.test(root_path, FileTest.IS_DIR) == true)
				this.root_path = root_path;
			else
				this.root_path = "/";
									
			if (file_extensions != null)
				regex_file_filter = get_file_extensions_regex(file_extensions);			
		}
	
		protected override void on_selector_scanning() { this.message("Reading directory..."); }
		protected override void on_selector_scanned() { this.message(null); }

		protected override string get_first_run_key(string starting_key) { 
			if (starting_key.has_prefix(root_path) == true) {
				if (FileUtils.test(starting_key, FileTest.EXISTS) == false)
					return get_first_run_key(Path.get_dirname(starting_key));
				if (FileUtils.test(starting_key, FileTest.IS_DIR))
					return Path.get_dirname(starting_key);
				return starting_key;
			}
			return root_path;
		}
		protected override uint get_first_run_selection_index(string starting_key) {
			if (FileUtils.test(starting_key, FileTest.IS_DIR))
				return 0;
			return get_index_of_item_named(Path.get_basename(starting_key));
		}
		protected override string? get_run_result() { return selected_path; }
		
		protected override ChooserSelector create_selector(string key, int16 xpos, int16 ypos, int16 max_height) {
			return new FileSelector(SELECTOR_ID, xpos, ypos, max_height, key, regex_file_filter, (key == root_path));
		}
				
		protected override void update_header(ChooserHeader header, ChooserSelector selector) {
			header.path = ((FileSelector)selector).path;
		}
		protected override bool process_activation(ChooserSelector selector) {
			var file_selector = (FileSelector)selector;
			if (file_selector.is_folder_selected == false) {
				// choose this this
				selected_path = file_selector.selected_path();				
				return true;
			}
			return false;
		}
		protected override string get_selected_key(ChooserSelector selector) { return ((FileSelector)selector).selected_path(); }
		protected override string get_parent_key(ChooserSelector selector) { return Path.get_dirname(((FileSelector)selector).path); }
		protected override string get_parent_child_name(ChooserSelector selector) { 
			return Path.get_basename(((FileSelector)selector).path) + Path.DIR_SEPARATOR_S; 
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
				warning("Error creating file extension regex: %s", e.message);
			}
			return null;
		}

	}
}
