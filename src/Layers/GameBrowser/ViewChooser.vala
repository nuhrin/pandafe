using Gee;
using SDL;
using SDLTTF;
using Catapult;
using Data;
using Data.Platforms;
using Layers.Controls;
using Layers.MenuBrowser;

namespace Layers.GameBrowser
{
	public class ViewChooser : Layer
	{
		const int16 SELECTOR_YPOS = 100;
		const int SELECTOR_MIN_CHAR_WIDTH = 10;
		MenuHeaderLayer header;
		ValueSelector<GameBrowserViewData> selector;
		public ViewChooser(string id) {
			base(id);
			header = add_layer(new MenuHeaderLayer(id+"_header")) as MenuHeaderLayer;
			header.set_text(null, "Choose View", null, false);
		}
		
		public GameBrowserViewData? run(GameBrowserViewData? current_view, uchar screen_alpha=128, uint32 rgb_color=0) {
			var views = get_view_data();
			selector = get_view_selector(views, current_view);
			
			@interface.push_layer(this, screen_alpha, rgb_color);
			uint selected_index = selector.run_no_push();
			@interface.pop_layer();
			
			if (selector.was_canceled)
				return null;
			return views[(int)selected_index];
		}
		
		protected override void draw() {
			draw_rectangle_outline(header.xpos-1, header.ypos-1, (int16)header.width + 2, (int16)header.height + 2, @interface.white_color);
		}
		
		Gee.List<GameBrowserViewData> get_view_data() {
			var data = new ArrayList<GameBrowserViewData>();
			data.add(new GameBrowserViewData(GameBrowserViewType.BROWSER));
			data.add(new GameBrowserViewData(GameBrowserViewType.FAVORITES));
			data.add(new GameBrowserViewData(GameBrowserViewType.ALL_GAMES));
			
			var folders = Data.platforms().get_platform_folder_data().get_all_folders()
				.select<GameBrowserViewData>(folder => new GameBrowserViewData.folder(folder))
				.to_list();
			data.add_all(folders);
			return data;
		}
		
		ValueSelector<GameBrowserViewData> get_view_selector(Gee.List<GameBrowserViewData> views, GameBrowserViewData? current_view) {
			int max_chars = SELECTOR_MIN_CHAR_WIDTH;
			int found_index=-1;
			for(int index=0;index<views.size;index++) {
				var view = views[index];
				if (found_index == -1 && current_view != null && current_view.equals(view))
					found_index = index;
				if (view.name.length > max_chars)
					max_chars = view.name.length;
			}
			uint selected_index = (found_index > 0) ? (uint)found_index : 0;
			
			int16 max_width = @interface.get_monospaced_font_width(max_chars) + 15;
			int16 xpos = ((int16)@interface.screen_width - max_width) / 2;
			var selector_id = id + "_selector";
			var new_selector = new ValueSelector<GameBrowserViewData>(selector_id, xpos, SELECTOR_YPOS, max_width, v=>v.name, views, selected_index);
			new_selector.can_select_single_item = true;
			
			if (selector == null)
				add_layer(new_selector);
			else
				replace_layer(selector_id, new_selector);
			
			selector = new_selector;
			selector.ensure_selection();
			return selector;
		}
		
		
	}
}
