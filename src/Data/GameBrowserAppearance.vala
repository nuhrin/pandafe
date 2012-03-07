using Gee;
using Catapult;

namespace Data
{
	public class GameBrowserAppearance : YamlObject
	{
		const string DEFAULT_FONT_PATH  = "/usr/share/fonts/truetype/";
		const string DEFAULT_FONT = "/usr/share/fonts/truetype/DejaVuSansMono.ttf";
		const string DEFAULT_ITEM_COLOR = "#ffffff";
		const string DEFAULT_SELECTED_ITEM_COLOR = "#0064ff";
		const string DEFAULT_BACKGROUND_COLOR = "#000000";
		
		construct {
		}

		public GameBrowserAppearance() {
		}
		public GameBrowserAppearance.default() {
			font = DEFAULT_FONT;
			item_color = build_color(DEFAULT_ITEM_COLOR);
			selected_item_color = build_color(DEFAULT_SELECTED_ITEM_COLOR);
			background_color = build_color(DEFAULT_BACKGROUND_COLOR);
		}

		public string? font { get; set; }
		public Data.Color? item_color { get; set; }
		public Data.Color? selected_item_color { get; set; }
		public Data.Color? background_color { get; set; }
		
		public GameBrowserAppearance copy() {
			var copy = new GameBrowserAppearance();
			copy.font = font;
			if (item_color != null)
				copy.item_color = item_color.copy();
			if (selected_item_color != null)
				copy.selected_item_color = selected_item_color.copy();
			if (background_color != null)
				copy.background_color = background_color.copy();
			return copy;			
		}
		
		public bool has_data() { return (font != null || item_color != null || selected_item_color != null || background_color != null); }
		public bool matches(GameBrowserAppearance other) {
			if (font != other.font)
				return false;
			if (color_matches(a=>a.item_color, this, other) == false)
				return false;
			if (color_matches(a=>a.selected_item_color, this, other) == false)
				return false;
			if (color_matches(a=>a.background_color, this, other) == false)
				return false;
			return true;
		}
		static bool color_matches(owned MapFunc<Data.Color?,GameBrowserAppearance> get_color, GameBrowserAppearance a, GameBrowserAppearance b) {
			var color_a = get_color(a);
			var color_b = get_color(b);
			if (color_a == null) {
				if (color_b != null)
					return false;
			} else {
				if (color_b == null)
					return false;
				if (color_a.spec != color_b.spec)
					return false;
			}
			return true;
		}

		public GameBrowserUI create_ui(GameBrowserAppearance? fallback_appearance=null) {
			unowned string? resolved_font = font;
			if (resolved_font == null && fallback_appearance == null)
				resolved_font = fallback_appearance.font;
			if (resolved_font == null)
				resolved_font = DEFAULT_FONT;
			SDL.Color item_color = {};
			resolve_color(ref item_color, c=>c.item_color, fallback_appearance, DEFAULT_ITEM_COLOR);
			SDL.Color selected_item_color = {};
			resolve_color(ref selected_item_color, c=>c.selected_item_color, fallback_appearance, DEFAULT_SELECTED_ITEM_COLOR);
			SDL.Color background_color = {};
			resolve_color(ref background_color, c=>c.background_color, fallback_appearance, DEFAULT_BACKGROUND_COLOR);
			return new GameBrowserUI(font, item_color, selected_item_color, background_color);
		}
		
		void resolve_color(ref SDL.Color color, owned MapFunc<Data.Color?,GameBrowserAppearance> get_color, GameBrowserAppearance? fallback_appearance, string default_spec) {			
			var resolved_color = get_color(this);
			if (resolved_color == null && fallback_appearance != null)
				resolved_color = get_color(fallback_appearance);
			if (resolved_color == null)
				resolved_color = build_color(default_spec);
			
			color = resolved_color.get_sdl_color();
		}
		Data.Color build_color(string spec) {
			Data.Color color;
			if (Data.Color.parse(spec, out color) == false)
				GLib.error("Unable to parse color constant: %s", spec);	
			return color;
		}
		
		// yaml
		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var mapping = new Yaml.MappingNode();
			if (font != null)
				mapping.set_scalar("font", builder.build_value(font));
			if (item_color != null)
				mapping.set_scalar("item-color", builder.build_value(item_color));
			if (selected_item_color != null)
				mapping.set_scalar("selected-item-color", builder.build_value(selected_item_color));
			if (background_color != null)
				mapping.set_scalar("background-color", builder.build_value(background_color));
			return mapping;	
		}
		protected override bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return false;
			foreach(var key in mapping.scalar_keys()) {
				switch(key.value) {
					case "font":					
						font = parser.parse<string>(mapping[key], DEFAULT_FONT);
						break;
					case "item-color":
						item_color = build_color(DEFAULT_ITEM_COLOR);
						item_color.spec = parser.parse<string>(mapping[key], DEFAULT_ITEM_COLOR);
						break;
					case "selected-item-color":
						selected_item_color = build_color(DEFAULT_SELECTED_ITEM_COLOR);
						selected_item_color.spec = parser.parse<string>(mapping[key], DEFAULT_SELECTED_ITEM_COLOR);
						break;
					case "background-color":
						background_color = build_color(DEFAULT_BACKGROUND_COLOR);
						background_color.spec = parser.parse<string>(mapping[key], DEFAULT_BACKGROUND_COLOR);
						break;
				}
			}
			return true;
		}
	}
}
