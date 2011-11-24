using SDL;

namespace Layers.GameBrowser
{
	public class StatusMessageLayer : SurfaceLayer
	{		
		public StatusMessageLayer(string id) {
			base(id, 780, @interface.font_height, 10, 470 - @interface.font_height, @interface.background_color_rgb);
			status_message_stack = new GLib.Queue<StatusMessage>();
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
		
		protected override void draw() {
			if (status_message_stack.is_empty() == true)
				return;
				
			var sm = status_message_stack.peek_head();
			Rect rect = {0, 0};
			if (sm.left != null) {
				blit_surface(@interface.render_text_selected_fast(sm.left), null, rect);
			}
			Surface rendered_message;
			if (sm.center != null) {
				rendered_message = @interface.render_text_selected_fast(sm.center);
				rect.x = (int16)(surface.w/2 - rendered_message.w/2);
				blit_surface(rendered_message, null, rect);
			}
			if (sm.right != null) {
				rendered_message = @interface.render_text_selected_fast(sm.right);
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
		GLib.Queue<StatusMessage> status_message_stack;
	}
}
