/* FolderSelector.vala
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
	public class FolderSelector : ChooserSelector
	{
		const string CURRENT_FOLDER_ITEM_NAME = "(Choose this folder)";
		const string CREATE_FOLDER_ITEM_NAME = "(Create folder)";
		
		public FolderSelector(string id, int16 xpos, int16 ypos, int16 max_height, string path, bool is_root=false) {			
			base(id, xpos, ypos, max_height, is_root, CURRENT_FOLDER_ITEM_NAME);
			this.path = path;
		}
		public bool allow_folder_creation { get; set; }
		
		public string path { get; private set; }						
		public string selected_folder() { return selected_item(); }
		public string selected_path() { 
			if (is_choose_item_selected)
				return path;
			if (is_create_item_selected)
				return Path.build_filename(path, selected_item_secondary_id());			
			if (is_go_back_item_selected)
				return Path.get_dirname(path);
				
			return Path.build_filename(path, selected_folder());
		}
		public bool is_create_item_selected { get { return (selected_item() == CREATE_FOLDER_ITEM_NAME); } }
		
		
		protected override void populate_items(Gee.List<ChooserSelector.Item> items) {			
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
						items.add(create_folder_item(name));
				}
				items.sort();
				if (allow_folder_creation)
					items.add(create_folder_item(CREATE_FOLDER_ITEM_NAME));
			}
			catch(GLib.Error e)
			{
				warning("Error while getting children of '%s': %s", path, e.message);
			}
		}
	}
}
