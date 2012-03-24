using Gee;
using SDL;
using SDLTTF;
using Layers;
using Layers.Controls.Chooser;
using Layers.MenuBrowser;
using Data.Pnd;

namespace Layers.Controls
{
	public class PndAppChooser : ChooserBase
	{				
		const string SELECTOR_ID = "app_selector";
		AppItem? app;
		CategoryBase? category;
		string? selected_app;
		string? selected_pnd;
		string? path;
		
		public PndAppChooser(string id, string title) {			
			base(id, title);					
		}
		
		public new AppItem? run(AppItem? starting_app=null) {
			string starting_path = "";
			var pnddata = Data.pnd_data();
			app = starting_app;			
			if (app != null) {
				category = pnddata.get_app_category(app);
				if (category != null)
					starting_path = category.get_path();
			}
			string? new_path = base.run(starting_path);
			var new_category = pnddata.get_category_from_path(new_path ?? "");
			if (new_category != null) {
				foreach(var app in new_category.apps) {
					if (app.id == selected_app && app.package_id == selected_pnd)
						return app;					
				}
			}			
			
			return this.app;
		}

		protected override uint get_first_run_selection_index(string starting_key) {
			if (app == null)
				return 0;
			return get_index_of_item_named(app.title);
		}
		protected override string? get_run_result() { return path; }
		
		protected override ChooserSelector create_selector(string key, int16 xpos, int16 ypos, int16 max_height) {
			return new PndAppSelector(SELECTOR_ID, xpos, ypos, max_height, key);
		}		
		
		protected override void update_header(ChooserHeader header, ChooserSelector selector) {
			header.path = ((PndAppSelector)selector).path;
		}
		protected override bool process_activation(ChooserSelector selector) {
			var app_selector = (PndAppSelector)selector;
			path = app_selector.path;
			if (app_selector.is_folder_selected == false) {
				// choose this app
				selected_app = app_selector.selected_item_id();
				selected_pnd = app_selector.selected_item_secondary_id();
				return true;
			}
			return false;
		}
		protected override string get_selected_key(ChooserSelector selector) { return ((PndAppSelector)selector).selected_path(); }
		protected override string get_parent_key(ChooserSelector selector) { return Path.get_dirname(((PndAppSelector)selector).path); }
		protected override string get_parent_child_name(ChooserSelector selector) { return Path.get_basename(((PndAppSelector)selector).path); }
	}
}
