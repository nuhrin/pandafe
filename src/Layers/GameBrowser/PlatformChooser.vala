using Gee;
using SDL;
using SDLTTF;
using Catapult;
using Layers.Controls;
using Layers.MenuBrowser;

namespace Layers.GameBrowser
{
	public class PlatformChooser : Layer
	{
		const int16 SELECTOR_YPOS = 100;
		const int SELECTOR_MIN_CHAR_WIDTH = 10;
		MenuHeaderLayer header;
		ValueSelector<Platform> selector;
		public PlatformChooser(string id) {
			base(id);
			header = add_layer(new MenuHeaderLayer(id+"_header")) as MenuHeaderLayer;
			header.set_text(null, "Choose Platform", null, false);
		}
		
		public Platform? run(Platform? current_platform, uchar screen_alpha=128, uint32 rgb_color=0) {
			var platforms = Data.platforms().get_all_platforms().to_list();
			selector = get_platform_selector(platforms, current_platform);
			
			@interface.push_layer(this, screen_alpha, rgb_color);
			uint selected_index = selector.run_no_push();
			@interface.pop_layer();
			
			if (selector.was_canceled)
				return null;
			return platforms[(int)selected_index];
		}
		
		protected override void draw() {
			draw_rectangle_outline(header.xpos-1, header.ypos-1, (int16)header.width + 2, (int16)header.height + 2, @interface.white_color);
		}

		ValueSelector<Platform> get_platform_selector(Gee.List<Platform> platforms, Platform? current_platform) {
			int max_chars = SELECTOR_MIN_CHAR_WIDTH;
			int found_index=-1;
			for(int index=0;index<platforms.size;index++) {
				var platform = platforms[index];
				if (found_index == -1 && current_platform != null && current_platform.id == platform.id)
					found_index = index;
				if (platform.name.length > max_chars)
					max_chars = platform.name.length;
			}
			uint selected_index = (found_index > 0) ? (uint)found_index : 0;
			
			int16 max_width = @interface.get_monospaced_font_width(max_chars) + 15;
			int16 xpos = ((int16)@interface.screen_width - max_width) / 2;
			var selector_id = id + "_selector";
			var new_selector = new ValueSelector<Platform>(selector_id, xpos, SELECTOR_YPOS, max_width, p=>p.name, platforms, selected_index);
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
