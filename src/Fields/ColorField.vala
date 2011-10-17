using Gtk;
using Catapult;
using Catapult.Gui.Fields;

namespace Fields
{
	public class ColorField : LabeledField
	{
		ColorButton chooser;
		public ColorField(string id, string? label=null, Gdk.Color? value=null, string? title=null) {
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
			return new Yaml.ScalarNode(null, null, color.to_string());
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
	}
}
