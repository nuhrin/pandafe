using Layers.GameBrowser;

namespace Layers.Preview
{
	public class BrowserPreview : SurfaceLayer 
	{
		int16 ypos;
		GameBrowserUI ui;
		HeaderLayer header;
		StatusMessageLayer status_message;
		PreviewSelector selector;
		
		public BrowserPreview(int16 ypos, GameBrowserUI ui) {
			base("browser_preview", @interface.screen_width, @interface.screen_height - ypos, 0, ypos, ui.background_color_rgb);
			this.ypos = ypos;
			this.ui = ui;
			header = add_layer(new HeaderLayer("header", 20, ui)) as HeaderLayer;
			header.set_text("Platform", "(Game Browser Preview)", "Category", false);
			status_message = add_layer(new StatusMessageLayer("status-message", ui, (int16)this.height)) as StatusMessageLayer;
			status_message.push(null, "2 / 5", null, false);
			selector = add_layer(new PreviewSelector(100, 60, ui)) as PreviewSelector;			
			ui.colors_updated.connect(update_colors);
			ui.font_updated.connect(update_font);			
		}		
		
		public override void draw() {
		}
		
		void update_colors() {
			header.set_rgb_color(ui.background_color_rgb);
			status_message.set_rgb_color(ui.background_color_rgb);
			this.set_rgb_color(ui.background_color_rgb);
			update();
		}
		void update_font() {
			update();
		}
	}
}
