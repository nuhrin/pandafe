using SDL;
using Catapult;

namespace Data
{
	public class Color : YamlObject
	{
		uchar _red;
		uchar _green;
		uchar _blue;
		uint8 _hue;
		uint8 _saturation;
		uint8 _value;
		string _spec;
		
		public Color(uchar red=0, uchar green=0, uchar blue=0) {
			set_rgb(red, green, blue);
		}		
		public Color.from_sdl(SDL.Color color) {
			this(color.r, color.g, color.b);
		}
		public Color.from_gdk(Gdk.Color color) {
			set_gdk_color(color);
		}
		public Color.from_hsv(uint8 hue, uint8 saturation, uint8 value) {
			set_hsv(hue, saturation, value);
		}
		Color.from_other(Color color) {
			copy_from(color);
		}
		
		public static bool parse(string spec, out Color color) {
			Gdk.Color gcolor;
			if (Gdk.Color.parse(spec, out gcolor) == true) {
				color = new Color.from_gdk(gcolor);
				color._spec = spec;
				return true;
			}
			color = null;
			return false;
		}
		public static SDL.Color parse_sdl(string spec) {
			Color color;
			if (parse(spec, out color) == true)
				return color.get_sdl_color();
			return {0,0,0};
		}
		public Color copy() {
			return new Color.from_other(this);
		}
		public void copy_from(Color other) {
			_red = other._red;
			_green = other._green;
			_blue = other._blue;
			_hue = other._hue;
			_saturation = other._saturation;
			_value = other._value;
			_spec = other._spec;
		}

		public uchar red {
			get { return _red; }
			set {
				_red = value;
				update_hsv_from_rgb();
				update_hex();
			}
		}
		public uchar green {
			get { return _green; }
			set {
				_green = value;
				update_hsv_from_rgb();
				update_hex();
			}
		}
		public uchar blue {
			get { return _blue; }
			set {
				_blue = value;
				update_hsv_from_rgb();
				update_hex();
			}
		}
		public uint8 hue {
			get { return _hue; }
			set {
				assert(value <= 360);
				_hue = value;
				update_rgb_from_hsv();
				update_hex();
			}
		}
		public uint8 saturation {
			get { return _saturation; }
			set {
				assert(value <= 100);
				_saturation = value;
				update_rgb_from_hsv();
				update_hex();
			}
		}
		public uint8 value {
			get { return _value; }
			set {
				assert(value <= 100);
				_value = value;
				update_rgb_from_hsv();
				update_hex();
			}
		}
		public void set_rgb(uchar red, uchar green, uchar blue) {
			_red = red;
			_green = green;
			_blue = blue;
			update_hsv_from_rgb();
			update_hex();
		}
		public void set_hsv(uint8 hue, uint8 saturation, uint8 value) {
			assert(hue <= 360);
			assert(saturation <= 100);
			assert(value <= 100);
			_hue = hue;
			_saturation = saturation;
			_value = value;
			update_rgb_from_hsv();
			update_hex();
		}
						
		public string spec {
			get { return _spec; }
			set {
				if (value == _spec)
					return;
				Gdk.Color parsed;
				if (Gdk.Color.parse(value, out parsed) == true) {
					set_gdk_color(parsed);
					_spec = value;
				} else {
					warning("Unable to parse color spec: %s", value);
				}
			}
		}
		
		public SDL.Color get_sdl_color() { return {_red, _green, _blue}; }
		public void set_sdl_color(SDL.Color color) { set_rgb(color.r, color.g, color.b); }
		
		public Gdk.Color get_gdk_color() {
			Gdk.Color color;
			if (Gdk.Color.parse(spec, out color) == false)
				GLib.error("Internal error: unable to parse color spec '%s'", spec);
			return color;
		}		
		public void set_gdk_color(Gdk.Color color) {
			_red = (uchar)scale_round((double)color.red / (double)uint16.MAX, 255);
			_green = (uchar)scale_round((double)color.green / (double)uint16.MAX, 255);
			_blue = (uchar)scale_round((double)color.blue / (double)uint16.MAX, 255);
			update_hsv_from_rgb();
			update_hex();
		}
		
		void update_hsv_from_rgb() {
			// derived from gtkhsv.c, rgb_to_hsv()
			double h;
			double s;
			double v;
			double min;
			double max;
			double delta;
  
			double red = (double)_red / (double)255;
			double green = (double)_green / (double)255;
			double blue = (double)_blue / (double)255;
			
			h = 0.0;
			
			if (red > green) {
				if (red > blue)
					max = red;
				else
					max = blue;
      
				if (green < blue)
					min = green;
				else
					min = blue;
			} else {
				if (green > blue)
					max = green;
				else
					max = blue;
      
				if (red < blue)
					min = red;
				else
					min = blue;
			}
  
			v = max;
  
			if (max != 0.0)
				s = (max - min) / max;
			else
				s = 0.0;
  
			if (s == 0.0) {
				h = 0.0;
			} else {
				delta = max - min;
      
				if (red == max)
					h = (green - blue) / delta;
				else if (green == max)
					h = 2 + (blue - red) / delta;
				else if (blue == max)
					h = 4 + (red - green) / delta;
      
				h /= 6.0;
      
				if (h < 0.0)
					h += 1.0;
				else if (h > 1.0)
					h -= 1.0;
			}
			
			_hue = (uint8)scale_round(h, 360);
			_saturation = (uint8)scale_round(s, 100);
			_value = (uint8)scale_round(v, 100);
		}
		void update_rgb_from_hsv() {
			// derived from gtkhsv.c, hsv_to_rgb()
			if (_saturation == 0.0) {
				_red = (uchar)scale_round(_value, 255);
				_green = _red;
				_blue = _green;
				return;
			}
			double hue;
			double saturation;
			double value;
			double f;
			double p;
			double q;
			double t;
			
			double red;
			double green;
			double blue;
			
			hue = ((double)_hue / (double)360) * 6.0;
			saturation = (double)_saturation / (double)100;
			value = (double)_value / (double)100;
			
			if (hue == 6.0)
				hue = 0.0;
				
			f = hue - (int)hue;
			p = value * (1.0 - saturation);
			q = value * (1.0 - saturation * f);
			t = value * (1.0 - saturation * (1.0 - f));
			
			switch ((int) hue) {
				case 0:
					red = value;
					green = t;
					blue = p;
					break;
				case 1:
					red = q;
					green = value;
					blue = p;
					break;
				case 2:
					red = p;
					green = value;
					blue = t;
					break;
				case 3:
					red = p;
					green = q;
					blue = value;
					break;
				case 4:
					red = t;
					green = p;
					blue = value;
					break;
				case 5:
					red = value;
					green = p;
					blue = q;
					break;
				default:
					assert_not_reached();
			}
			
			_red = (uchar)scale_round(red, 255);
			_green = (uchar)scale_round(green, 255);
			_blue = (uchar)scale_round(blue, 255);
		}
		void update_hex() {
			_spec = "#%2X%2X%2X".printf(_red, _green, _blue).replace(" ", "0");
		}
		
		uint scale_round(double val, double factor) {
			double retVal = Math.floor(val * factor + 0.5);
			retVal = double.max(retVal, 0);
			retVal = double.min(retVal, factor);
			return (uint)retVal;
		}

		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			return new Yaml.ScalarNode(_spec);
		}
		protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var scalar = node as Yaml.ScalarNode;
			if (scalar != null)
				spec = scalar.value;
		}
	}
}
