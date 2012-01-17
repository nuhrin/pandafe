using Gtk;
using Catapult;
using Catapult.Gui.Fields;

namespace GtkFields
{
	public class GtkColorField : LabeledField
	{
		ColorButton chooser;
		public GtkColorField(string id, string? label=null, Gdk.Color? value=null, string? title=null) {
			base(id, label);
			chooser = new ColorButton();
			chooser.title = (title != null) ? title : "Choose a color";
			if (value != null)
				chooser.set_color(value);
			chooser.color_set.connect(() => this.changed());
		} 
		public new Gdk.Color value {
			get { return chooser.color; }
			set { chooser.color = value; }
		}

		protected override Value get_field_value() { return this.value; }
		protected override void set_field_value(Value value) {
			Gdk.Color color = (Gdk.Color)value;
			chooser.color = color;
		}

		protected override Widget target_widget { get { return chooser; } }

		public static Yaml.Node color_to_node(Gdk.Color color) {			
			return new Yaml.ScalarNode(null, null, "#%2X%2X%2X".printf(scale_color(color.red), scale_color(color.green), scale_color(color.blue)));
		}
		public static Gdk.Color node_to_color(Yaml.Node node) {
			var scalar = node as Yaml.ScalarNode;
			if (scalar != null) {
				Gdk.Color color = Gdk.Color();
				if (color.parse(scalar.value, out color) == true)
					return color;
			}
			return Gdk.Color();
		}
		
		static uint scale_color(uint16 color) {
			double val = (double)color / (double)uint16.MAX;
			val = Math.floor(val * 255 + 0.5);
			val = double.max(val, 0);
			val = double.min(val, 255);
			return (uint)val;
		}
	}
}
