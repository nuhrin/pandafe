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
		const string SELECTOR_ID = "folder_selector";
		string root_path;
		string? selected_path;

		public FolderChooser(string id, string title, string? root_path=null) {			
			base(id, title);
			if (root_path != null && FileUtils.test(root_path, FileTest.IS_DIR) == true)
				this.root_path = root_path;
			else
				this.root_path = "/";			
		}

		protected override string get_first_run_key(string starting_key) { 
			if (starting_key.has_prefix(root_path) == true) {
				if (FileUtils.test(starting_key, FileTest.IS_DIR) == false)
					return get_first_run_key(Path.get_dirname(starting_key));
				return starting_key;
			}
			return root_path;
		}

		protected override string? get_run_result() { return selected_path; }
		
		protected override ChooserSelector create_selector(string key, int16 xpos, int16 ypos) {
			return new FolderSelector(SELECTOR_ID, xpos, ypos, key, (key == root_path));
		}		
		
		protected override void update_header(ChooserHeader header, ChooserSelector selector) {
			header.path = ((FolderSelector)selector).path;
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
