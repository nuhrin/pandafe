using Gee;
using Fields;
using Catapult;
using Catapult.Gui;
using Catapult.Gui.Fields;
using Catapult.Gui.Fieldsets;

namespace Data
{
	public class Preferences : Entity, GuiEntity
	{
		const string DEFAULT_FONT_PATH  = "/usr/share/fonts/truetype/";

		internal const string ENTITY_ID = "preferences";
		protected override string generate_id() { return ENTITY_ID; }

		construct {
			platform_order = new ArrayList<string>();
			// default colors
			var color = Gdk.Color();
			if (Gdk.Color.parse("#ffffffffffff", out color) == true)
				item_color = color; // white
			if (Gdk.Color.parse("#00006464ffff", out color) == true)
				selected_item_color = color; // blue-green
		}

		public string font { get; set; }
		public Gdk.Color background_color { get; set; }
		public Gdk.Color item_color { get; set; }
		public Gdk.Color selected_item_color { get; set; }
		public Gee.List<string> platform_order { get; set; }

		public SDL.Color background_color_sdl() { return get_sdl_color(background_color); }
		public SDL.Color item_color_sdl() { return get_sdl_color(item_color); }
		public SDL.Color selected_item_color_sdl() { return get_sdl_color(selected_item_color); }
		SDL.Color get_sdl_color(Gdk.Color color) {
			return { convert_color(color.red), convert_color(color.green), convert_color(color.blue) };
		}
		uchar convert_color(uint16 color) {
			return (255*color)/65535;
		}

		public void update_platform_order(Iterable<Platform> platforms) {
			platform_order.clear();
			foreach(var platform in platforms)
				platform_order.add(platform.id);
		}

		protected override Yaml.Node? build_unhandled_value_node(Yaml.NodeBuilder builder, Value value) {
			if (value.holds(typeof(Gdk.Color))) {
				return ColorField.color_to_node((Gdk.Color)value);
			}
			return null;
		}
		protected override bool apply_unhandled_value_node(Yaml.Node node, string property_name, Yaml.NodeParser parser) {
			if (property_name == "item-color") {
				item_color = ColorField.node_to_color(node);
				return true;
			}
			else if (property_name == "selected-item-color") {
				selected_item_color = ColorField.node_to_color(node);
				return true;
			}
			else if (property_name == "background-color") {
				background_color = ColorField.node_to_color(node);
				return true;
			}
			return false;
		}
		protected void populate_field_box(FieldBox box) {
			// add notebook
			var notebook = new NotebookFieldset("preferences_notebook");
			notebook.show_tabs = false;
			// add single page
			var first_page = notebook.add_page("first_page", "Page");
			var frame = new FrameFieldset("frame", "Preferences");
			first_page.add_field(frame);
			//frame.add_string("test", "_Test", this.test);
			var font_field = new FileField("font", "_Font", font);
			if (font == null || font == "")
				font_field.current_folder = DEFAULT_FONT_PATH;
			font_field.add_pattern("*.ttf");
			frame.add_field(font_field);
			var item_color_field = new ColorField("item-color", "Item _Color", item_color);
			frame.add_field(item_color_field);
			var selected_item_color_field = new ColorField("selected-item-color", "_Selected Item Color", selected_item_color);
			frame.add_field(selected_item_color_field);
			var background_color_field = new ColorField("background-color", "_Background Color", background_color);
			frame.add_field(background_color_field);

			box.add_field(notebook);
			box.set_field_packing(notebook, true, true, 0, Gtk.PackType.START);
		}

	}
}
