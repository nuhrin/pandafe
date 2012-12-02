/* FileSelector.vala
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
using Layers.MenuBrowser;

namespace Layers.Controls.Chooser
{
	public class FileSelector : ChooserSelector
	{
		Regex? regex_file_filter;
		bool path_is_dir;
		string original_path;
		
		public FileSelector(string id, int16 xpos, int16 ypos, int16 max_height, string path, Regex? regex_file_filter=null, bool is_root=false) {
			base(id, xpos, ypos, max_height, is_root);
			path_is_dir = FileUtils.test(path, FileTest.IS_DIR);
			original_path = path;
			this.path = (path_is_dir == false || path.has_suffix(Path.DIR_SEPARATOR_S) == true) 
				? Path.get_dirname(path)
				: path;
			this.regex_file_filter = regex_file_filter;			
		}
		
		public string path { get; private set; }
		public string selected_path() { 
			if (is_go_back_item_selected)
				return Path.get_dirname(path);
				
			return Path.build_filename(path, selected_item());
		}

		protected override void populate_items(Gee.List<ChooserSelector.Item> items) {
			var files = new ArrayList<string>();
			try {
				var directory = File.new_for_path(path);
				var enumerator = directory.enumerate_children("standard::*", FileQueryInfoFlags.NONE);
				FileInfo file_info;
				while ((file_info = enumerator.next_file ()) != null) {
					var type = file_info.get_file_type();
					var name = file_info.get_name();
					if (name.has_prefix(".") == true)
						continue;
					if (type == FileType.DIRECTORY)
						items.add(create_folder_item(name + "/"));
					else
						files.add(name);
				}				
				items.sort();
				if (regex_file_filter != null)
					files = get_matching_files(files);
				files.sort();
				foreach(var file in files)
					items.add(create_file_item(file));
			}
			catch(GLib.Error e)
			{
				warning("Error while getting children of '%s': %s", path, e.message);
			}
		}
		protected override string? get_initial_selected_item_name() {
			if (path_is_dir == false)
				return Path.get_basename(original_path);
			
			return null;
		}
		ArrayList<string> get_matching_files(ArrayList<string> file_names) {
			var sb = new StringBuilder();
			var item_positions = new int[file_names.size];
			for(int index=0; index<file_names.size; index++) {
				item_positions[index] = (int)sb.len;
				sb.append("%s\n".printf(file_names[index]));
			}
			var items_str = sb.str;
			var matched_names = new ArrayList<string>();

			int matched_item_index = 0;
			int last_item_index = file_names.size - 1;
			MatchInfo match_info;
			regex_file_filter.match(items_str, 0, out match_info);
			while((matched_item_index < file_names.size) && match_info.matches()) {
				int match_position;
				if (match_info.fetch_pos(0, out match_position, null) == true) {
					if (match_position >= item_positions[matched_item_index]) {
						while(match_position >= item_positions[matched_item_index + 1] && (matched_item_index < last_item_index))
							matched_item_index++;

						matched_names.add(file_names[matched_item_index]);
						matched_item_index++;
					}
				}
				try {
					match_info.next();
				} catch(RegexError e) {
					warning("Error during file extension matching: %s", e.message);
					break;
				}
			}

			return matched_names;
		}
		
	}
}
