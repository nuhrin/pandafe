using Gtk;

namespace yayafe.Gui.Fields
{
	public abstract class Field : GLib.Object
	{
		protected Field(string name) {
			this.name = name;
			this.changed.connect((f)=> f.is_dirty = true);
		}
		public string name { get; private set; }

		public Value value {
			owned get { return get_field_value(); }
			set { set_field_value(value); }
		}

		public Widget widget {
			get {
				if (_widget == null)
					_widget = build_widget();
				return _widget;
			}
		}
		Widget _widget;

		public signal void changed();
		public bool is_dirty { get; private set; }
		public void make_clean() { is_dirty = false; }

		protected abstract Value get_field_value();
		protected abstract void set_field_value(Value value);
		protected abstract Widget build_widget();

	}
}