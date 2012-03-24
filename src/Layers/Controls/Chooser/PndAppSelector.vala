using Gee;
using SDL;
using SDLTTF;
using Layers;
using Layers.MenuBrowser;
using Data.Pnd;

namespace Layers.Controls.Chooser
{
	public class PndAppSelector : ChooserSelector
	{		
		public PndAppSelector(string id, int16 xpos, int16 ypos, int16 max_height, string path) {
			var category = Data.pnd_data().get_category_from_path(path);
			base(id, xpos, ypos, max_height, (category == null));			
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
				var item_title_hash = new HashMap<string, ChooserSelector.Item>();
				foreach(var app in category.apps) {
					ChooserSelector.Item item;					
					if (item_title_hash.has_key(app.title) == false) {
						item = create_file_item(app.title, app.id);
						item_title_hash[app.title] = item;
						items.add(item);
					} else {
						item = item_title_hash[app.title];
					}
					item.add_secondary_id(app.package_id);					
				}
			} else {
				foreach(string cat in Data.pnd_data().get_main_category_names())
					items.add(create_folder_item(cat));
			}				
			items.sort();					
		}
//~ 		protected override string? get_initial_selected_item_name() {
//~ 			if (path_is_dir == false)
//~ 				return Path.get_basename(original_path);
//~ 			
//~ 			return null;
//~ 		}

	}
}
