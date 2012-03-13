using SDL;

namespace Layers.GameBrowser
{
	public class StatusMessageLayer : SurfaceLayer
	{		
		GameBrowserUI ui;
		GLib.Queue<StatusMessage> status_message_stack;
		
		public StatusMessageLayer(string id, GameBrowserUI? ui=null, int16 layer_height=480) {
			GameBrowserUI resolved_ui = ui ?? @interface.game_browser_ui;
			base(id, 780, resolved_ui.font_height, 10, layer_height - resolved_ui.font_height - 10, resolved_ui.background_color_rgb);
			status_message_stack = new GLib.Queue<StatusMessage>();
			this.ui = resolved_ui;
		}
		
		public void push(string? left=null, string? center=null, string? right=null, bool flip_screen=true) {				
			status_message_stack.push_head(new StatusMessage(left, center, right));
			update(flip_screen);
		}
		public void pop(bool flip_screen=true) {
			if (status_message_stack.is_empty() == true)
				return;
			status_message_stack.pop_head();
			update(flip_screen);
		}
		public void flush(bool flip_screen=true) {
			if (status_message_stack.is_empty() == true)
	 			return;
 			status_message_stack.clear();
 			update(flip_screen);
		}
		public bool text_will_fit(string text) {
			return (ui.render_text_selected_fast(text).w <= width);
		}
		
		protected override void draw() {
			if (status_message_stack.is_empty() == true)
				return;
				
			var sm = status_message_stack.peek_head();
			Rect rect = {0, 0};
			if (sm.left != null && sm.left != "") {
				blit_surface(ui.render_text_selected_fast(sm.left), null, rect);
			}
			Surface rendered_message;
			if (sm.center != null && sm.center != "") {
				rendered_message = ui.render_text_selected_fast(sm.center);
				rect.x = (int16)(surface.w/2 - rendered_message.w/2);
				blit_surface(rendered_message, null, rect);
			}
			if (sm.right != null && sm.right != "") {
				rendered_message = ui.render_text_selected_fast(sm.right);
				rect.x = (int16)(surface.w - rendered_message.w);
				blit_surface(rendered_message, null, rect);
			}			
		}
		
		class StatusMessage : Object {
			public StatusMessage(string? left=null, string? center=null, string? right=null) {
				this.left = left;
				this.center = center;
				this.right = right;
			}
			public string? left;
			public string? center;
			public string? right;
		}
	}
}
