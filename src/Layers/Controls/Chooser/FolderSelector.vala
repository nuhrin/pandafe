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
		
		public FolderSelector(string id, int16 xpos, int16 ypos, int16 max_height, string path, bool is_root=false) {			
			base(id, xpos, ypos, max_height, is_root, CURRENT_FOLDER_ITEM_NAME);
			this.path = path;
		}
		
		public string path { get; private set; }						
		public string selected_folder() { return selected_item(); }
		public string selected_path() { 
			if (is_choose_item_selected)
				return path;
			if (is_go_back_item_selected)
				return Path.get_dirname(path);
				
			return Path.build_filename(path, selected_folder());
		}
		
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
			}
			catch(GLib.Error e)
			{
				warning("Error while getting children of '%s': %s", path, e.message);
			}		
		}
	}
}
