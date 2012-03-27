using Layers.GameBrowser;

namespace Layers.Preview
{
	public class BrowserPreview : SurfaceLayer 
	{
		GameBrowserUI ui;
		HeaderLayer header;
		StatusMessageLayer status_message;
		int16 selector_ypos;
		PreviewSelector selector;
		
		public BrowserPreview(int16 ypos, GameBrowserUI ui) {
			base("browser_preview", @interface.screen_width, @interface.screen_height - ypos - ui.font_height - 30,
				0, ypos, ui.background_color_rgb);
			this.ui = ui;
			set_layers();
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
		}
		void update_font() {
			clear();
			set_layers();			
			update();
		}
		void set_layers() {
			var header = new HeaderLayer("header", 20, ui);
			if (this.header == null)
				add_layer(header);
			else
				replace_layer(header.id, header);
			this.header = header;
			this.header.set_text("Platform", "(Game Browser Preview)", "Folder", false);
			
			selector_ypos = header.ypos + (int16)header.height + (ui.font_height);
			var selector = new PreviewSelector(100, selector_ypos, ui);
			if (this.selector == null)
				add_layer(selector);
			else
				replace_layer(selector.id, selector);
			this.selector = selector;
			
			var status_message = new StatusMessageLayer("status-message", ui, (int16)this.height);
			if (this.status_message == null)
				add_layer(status_message);
			else
				replace_layer(status_message.id, status_message);
			this.status_message = status_message;
			this.status_message.set(null, "2 / 3", null, true);
		}
	}
}
