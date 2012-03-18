using Layers.GameBrowser;

namespace Layers.Preview
{
	public class BrowserPreview : SurfaceLayer 
	{
		GameBrowserUI ui;
		HeaderLayer header;
		StatusMessageLayer status_message;
		PreviewSelector selector;
		
		public BrowserPreview(int16 ypos, GameBrowserUI ui) {
			base("browser_preview", @interface.screen_width, @interface.screen_height - ypos - ui.font_height - 30,
				0, ypos, ui.background_color_rgb);
			this.ui = ui;
			header = add_layer(new HeaderLayer("header", 20, ui)) as HeaderLayer;
			header.set_text("Platform", "(Game Browser Preview)", "Folder", false);
			status_message = add_layer(new StatusMessageLayer("status-message", ui, (int16)this.height)) as StatusMessageLayer;
			status_message.set(null, "2 / 5", null, false);
			selector = add_layer(new PreviewSelector(100, 60, ui)) as PreviewSelector;			
			ui.colors_updated.connect(update_colors);
			ui.font_updated.connect(update_font);			
		}		
		
		public override void draw() {
			draw_rectangle_outline(0, 0, (int16)width - 2, (int16)height - 2, @interface.white_color);
		}
		
		void update_colors() {
			header.set_rgb_color(ui.background_color_rgb);
			status_message.set_rgb_color(ui.background_color_rgb);
			this.set_rgb_color(ui.background_color_rgb);
			selector.rebuild();
			update();
		}
		void update_font() {
			update();
		}
	}
}
