using Gtk;

namespace yayafe.Gui.Widgets
{
	public abstract class ComboButton : ToggleButton
	{
		Label combo_label;
		bool is_opened;
		bool is_openning;

		public ComboButton(string initial_text="")
		{
			GLib.Object();
			var hbox = new HBox(false, 0);
			var alignment = new Alignment(0f, 0.5f, 0f, 1f);
			combo_label = new Label(initial_text ?? "");
			alignment.add(combo_label);
			hbox.pack_start(alignment, true, true, 0);
			hbox.pack_start(new VSeparator(), false, true, 0);
			var arrow = new Arrow(ArrowType.DOWN, ShadowType.NONE);
			hbox.pack_start(arrow, false, true, 0);
			this.add(hbox);
		}

		public bool popup_below { get; set; }
		public bool popup_natural_width { get; set; }


		protected abstract Widget get_popup_widget();
		//protected abstract string get_popup_widget_state_string();
		//protected abstract Value get_popup_widget_value();
		//protected abstract void set_popup_widget_value(Value value);


		public override void toggled()
		{
			if (this.active == true)
			{
				if (is_openning == false)
					open_popup();
			} else {
				close_popup();
			}
		}
		public override bool button_press_event(Gdk.EventButton event)
		{
			var ewidget = get_event_widget((Gdk.Event*)(&event));
			if (ewidget == popup_window)
				return true;
			if (ewidget != this || this.active == true)
				return false;

			if (this.has_focus == false)
				this.grab_focus();

			open_popup();
			this.active = true;
			this.is_openning = true;

			return true;
		}
		public override bool button_release_event(Gdk.EventButton event)
		{
			bool is_openning = false;
			if (this.is_openning == true) {
				is_openning = true;
				this.is_openning = false;
			}
			var ewidget = get_event_widget((Gdk.Event*)(&event));

			if (ewidget != popup_window_widget) {
				if (ewidget == this && is_openning == false && this.active == true) {
					close_popup();
					return true;
				}
				if (ewidget != this) {
					close_popup();
					return true;
				}
				return false;
			}

			return true;
		}
		bool popup_key_press_event (Gdk.EventKey event) {
			if (event.keyval == Gdk.Keysym.Escape)
			{
				close_popup();
				return false;
			}
			return true;
		}

		protected void open_popup() {
			if (is_opened == true)
				return;
			var toplevel = this.get_toplevel() as Window;
			if (toplevel != null)
				toplevel.get_group().add_window(popup_window);

			int window_x, window_y;
			this.window.get_origin(out window_x, out window_y);
			int ypos = window_y + allocation.y;
			if (this.popup_below == true)
				ypos += allocation.height;
			popup_window.move(window_x + allocation.x, ypos);
			if (this.popup_natural_width == false)
				popup_window.set_size_request(allocation.width, -1);
			popup_window.show();
			popup_window.grab_focus();
			if (popup_window_widget.has_focus == false)
				popup_window_widget.grab_focus();
			if (grab_input() == false) {
				popup_window.hide();
				return;
			}
			Gtk.grab_add(popup_window);
			is_opened = true;
		}
		protected void close_popup() {
			if (is_opened == false)
				return;
			Gtk.grab_remove(popup_window);
			popup_window.hide();
			this.active = false;
			is_opened = false;
		}

		bool grab_input() {
			var activate_time = Gdk.CURRENT_TIME;
			if (Gdk.pointer_grab(popup_window.window, true,
				Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.POINTER_MOTION_MASK,
				null, null, activate_time) != Gdk.GrabStatus.SUCCESS)
				return false;
			if (Gdk.keyboard_grab(popup_window.window, true, activate_time) != Gdk.GrabStatus.SUCCESS)
				return false;

    		return true;
		}

		Window popup_window {
			get {
				if (_window == null) {
					_window = new Window(WindowType.POPUP);
					_window.type_hint = Gdk.WindowTypeHint.COMBO;
					var toplevel = this.get_toplevel() as Window;
					if (toplevel != null) {
						//toplevel.get_group().add_window(_window);
						_window.set_transient_for(toplevel);
					}
					_window.set_screen(this.get_screen());
					_window.resizable = false;
				    _window.decorated = false;
					_window.deletable = false;
					_window.focus_on_map = true;
					_window.accept_focus = true;
					_window.skip_taskbar_hint = true;
					_window.add(popup_window_widget);

					_window.button_press_event.connect((w,e)=>this.button_press_event(e));
					_window.button_release_event.connect((w,e)=>this.button_release_event(e));
				}
				return _window;
			}
		}
		Window _window;
		Widget popup_window_widget
		{
			get {
				if (_popup_widget == null) {
					_popup_widget = get_popup_widget();
					_popup_widget.button_press_event.connect((w,e)=>this.button_press_event(e));
					_popup_widget.button_release_event.connect((w,e)=>this.button_release_event(e));
					_popup_widget.show_all();
				}
				return _popup_widget;
			}
		}
		Widget _popup_widget;

	}
}
