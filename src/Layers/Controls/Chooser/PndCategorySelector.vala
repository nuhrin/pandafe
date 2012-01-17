using Gee;
using SDL;
using SDLTTF;
using Layers;
using Layers.MenuBrowser;
using Data.Pnd;

namespace Layers.Controls.Chooser
{
	public class PndCategorySelector : ChooserSelector
	{
		const string CURRENT_ITEM_NAME = "(Choose this category)";
		
		public PndCategorySelector(string id, int16 xpos, int16 ypos, string path) {
			var category = Data.pnd_data().get_category_from_path(path);
			base(id, xpos, ypos, (category == null), CURRENT_ITEM_NAME);			
			this.path = (category != null) ? path : "";
		}
		
		public string path { get; private set; }						
		public string selected_path() { 
			if (is_choose_item_selected)
				return path;
			if (is_go_back_item_selected)
				return Path.get_dirname(path);
				
			return Path.build_filename(path, selected_item());
		}
		public CategoryBase? selected_category() { return Data.pnd_data().get_category_from_path(selected_path()); }
		
		protected override void populate_items(Gee.List<ChooserSelector.Item> items) {			
			var category = Data.pnd_data().get_category_from_path(path);
			if (category != null) {
				Category main = category as Category;
				if (main != null) {
					foreach(var sub in main.subcategories)
						items.add(create_folder_item(sub.name));
				}
			} else {
				foreach(string cat in Data.pnd_data().get_main_category_names())
					items.add(create_folder_item(cat));
			}				
			items.sort();			
		}

	}
}
