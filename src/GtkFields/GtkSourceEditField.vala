using Gtk;
using Catapult;
using Catapult.Gui.Fields;

namespace GtkFields
{
	public class GtkSourceEditField : LabeledField
	{
		string contents;
		public GtkSourceEditField(string id, string? label=null, string mimetype, string title, string? contents=null) {
			base(id, label);
			this.contents = contents;
			create_edit_dialog(title, mimetype);
			contents_changed.connect(() => this.changed());
			edit_btn = new Button.from_stock(Stock.EDIT);
			edit_btn.clicked.connect(() => this.clicked());
		}
		public new string value {
			owned get { return contents ?? ""; }
			set { contents = value; }
		}

		protected override Value get_field_value() { return contents; }
		protected override void set_field_value(Value value) { contents = (string)value; }
		protected override Widget target_widget { get { return edit_btn; } }

		protected signal void contents_changed();
		protected virtual signal void clicked() {
			if (contents != null)
				source_buffer.set_text(contents);
			dialog.show_all();
			var response = dialog.run();
			if (response == ResponseType.OK) {
				TextIter start;
				TextIter end;
				source_buffer.get_bounds(out start, out end);
				contents = source_buffer.get_text(start, end, true);
				if (contents._strip() == "")
					contents = null;
				contents_changed();
			}
			dialog.hide_all();
			source_buffer.set_text("");
		}
		void create_edit_dialog(string title, string mimetype) {
			var manager = new SourceLanguageManager();
			var language = manager.guess_language(null, mimetype);
			source_buffer = (language != null)
				? new SourceBuffer.with_language(language)
				: new SourceBuffer(null);
			source_view = new SourceView.with_buffer(source_buffer);
			var sw = new ScrolledWindow(null, null);
			sw.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			sw.shadow_type = ShadowType.ETCHED_IN;
			sw.add(source_view);

			dialog = new Dialog();
			dialog.title = title;
			dialog.vbox.pack_end(sw, true, true, 0);
			dialog.add_button (Stock.CANCEL, ResponseType.CANCEL);
			dialog.add_button(Stock.OK, ResponseType.OK);
			dialog.set_default_size (800, 400);
			//dialog.fullscreen();
		}
		Button edit_btn;
		protected Dialog dialog;
		protected SourceView source_view;
		protected SourceBuffer source_buffer;
	}
}
