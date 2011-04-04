using Gtk;

namespace yayafe.Gui.Fields
{
	public abstract class LabeledField : Field
	{
		protected LabeledField(string name, string? label=null)
		{
			base(name);
			this.label = (label != null) ? label : "_" + name;
		}
 		public virtual string label
		{
			get { return label_widget.label; }
			set { label_widget.label = value; }
		}

		protected abstract Widget target_widget { get; }

		protected override Widget build_widget() {
			var hbox = new HBox(false, 8);
			hbox.pack_start(label_widget, false, false, 0);
			hbox.pack_start(target_widget, true, true, 0);
			return hbox;
		}

		Label label_widget {
			get {
				if (lbl == null) {
					lbl = new Gtk.Label(null);
					lbl.use_underline = true;
					lbl.set_mnemonic_widget(target_widget);
				}
				return lbl;
			}
		}
		Label lbl;
	}
}