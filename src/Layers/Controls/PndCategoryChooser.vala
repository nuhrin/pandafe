using Gee;
using SDL;
using SDLTTF;
using Layers;
using Layers.Controls.Chooser;
using Layers.MenuBrowser;
using Data.Pnd;

namespace Layers.Controls
{
	public class PndCategoryChooser : ChooserBase
	{				
		const string SELECTOR_ID = "category_selector";
		string? selected_path;

		public PndCategoryChooser(string id, string title) {			
			base(id, title);					
		}

		protected override string? get_run_result() { return selected_path; }
		
		protected override ChooserSelector create_selector(string key, int16 xpos, int16 ypos) {
			return new PndCategorySelector(SELECTOR_ID, xpos, ypos, key);
		}		
		
		protected override void update_header(ChooserHeader header, ChooserSelector selector) {
			header.path = ((PndCategorySelector)selector).path;
		}
		protected override bool process_activation(ChooserSelector selector) {
			var category_selector = (PndCategorySelector)selector;
			if (category_selector.is_choose_item_selected) {
				// choose this category
				selected_path = category_selector.selected_path();				
				return true;
			}
			return false;
		}
		protected override string get_selected_key(ChooserSelector selector) { return ((PndCategorySelector)selector).selected_path(); }
		protected override string get_parent_key(ChooserSelector selector) { return Path.get_dirname(((PndCategorySelector)selector).path); }
		protected override string get_parent_child_name(ChooserSelector selector) { return Path.get_basename(((PndCategorySelector)selector).path); }
	}
}
