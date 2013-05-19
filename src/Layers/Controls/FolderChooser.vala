/* FolderChooser.vala
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
	public class FolderChooser : ChooserBase
	{
		const string DEFAULT_STARTING_PATH = "/media";
		const string SELECTOR_ID = "folder_selector";
		string root_path;
		string? selected_path;
		string? fallback_starting_path;
		
		public FolderChooser(string id, string title, string? root_path=null) {			
			base(id, title);
			if (root_path != null && FileUtils.test(root_path, FileTest.IS_DIR) == true)
				this.root_path = root_path;
			else
				this.root_path = "/";			
		}
		
		
		public void set_fallback_starting_path(string path) { 
			fallback_starting_path = path;
		}
		public string? most_recent_path { get; private set; }
		
		protected override void on_selector_scanning() { this.message("Reading directory..."); }
		protected override void on_selector_scanned() { this.message(null); }

		protected override string get_first_run_key(string starting_key) { 
			if (starting_key.has_prefix(root_path) == true) {
				if (FileUtils.test(starting_key, FileTest.IS_DIR) == false)
					return get_first_run_key(Path.get_dirname(starting_key));
				return starting_key;
			}
			return fallback_starting_path ?? DEFAULT_STARTING_PATH;
		}

		protected override string? get_run_result() { return selected_path; }
		
		protected override ChooserSelector create_selector(string key, int16 xpos, int16 ypos, int16 max_height) {
			return new FolderSelector(SELECTOR_ID, xpos, ypos, max_height, key, (key == root_path));
		}		
		
		protected override void update_header(ChooserHeader header, ChooserSelector selector) {
			header.path = ((FolderSelector)selector).path;
			most_recent_path = header.path;
		}
		protected override bool process_activation(ChooserSelector selector) {
			var folder_selector = (FolderSelector)selector;
			if (folder_selector.is_choose_item_selected) {
				// choose this folder
				selected_path = folder_selector.selected_path();				
				return true;
			}
			return false;
		}
		protected override string get_selected_key(ChooserSelector selector) { return ((FolderSelector)selector).selected_path(); }
		protected override string get_parent_key(ChooserSelector selector) { return Path.get_dirname(((FolderSelector)selector).path); }
		protected override string get_parent_child_name(ChooserSelector selector) { return Path.get_basename(((FolderSelector)selector).path); }
	}
}
