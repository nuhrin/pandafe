using SDL;
using SDLTTF;

namespace Layers.Controls
{
	public class UIntEntry : TextEntry
	{
		const string CHARACTER_MASK = "[\\d]";
		
		uint _value;
		uint min_value;
		uint max_value;
		uint step;
		
		public UIntEntry(string id, int16 x, int16 y, int16 width, uint value, uint min_value, uint max_value, uint step=1) {
			if (max_value < min_value)
				GLib.error("max_value (%u) < max_value (%u)", max_value, min_value);
			uint resolved_value = value;
			if (value < min_value)
				resolved_value = min_value;
			else if (value > max_value)
				resolved_value = max_value;
			base(id, x, y, width, value.to_string(), CHARACTER_MASK);
			this.min_value = min_value;
			this.max_value = max_value;
			this.step = step;
			this._value = value;
		}
		
		public new uint run(uchar screen_alpha=128, uint32 rgb_color=0) {
			string? text = base.run(screen_alpha, rgb_color);
			if (text == null)
				return _value;
			return (uint)int.parse(text);
		}
		
		public new uint value {
			get { return _value; }
			set { change_value(value); }			
		}
		
		protected override void on_text_changed() { 
			_value = (uint)int.parse(get_current_text_value());			
		}
		protected override bool is_valid_value() { 
			return !(_value < min_value || _value > max_value);
		}
		protected override void on_keydown_event(KeyboardEvent event) { 
			if (event.keysym.mod == KeyModifier.NONE) {
				switch(event.keysym.sym) {
					case KeySymbol.UP:
						change_value(_value + step);
						return;
					case KeySymbol.DOWN:
						if (_value < step)
							change_value(0);
						else 
							change_value(_value - step);
						return;
				}
			}
			base.on_keydown_event(event);
		}
		void change_value(uint new_value) {
			if (new_value < min_value)
				new_value = min_value;
			else if (new_value > max_value)
				new_value = max_value;
			if (new_value != _value)
				change_text(new_value.to_string());
		}		
	}
}
