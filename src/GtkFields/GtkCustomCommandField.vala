using Gtk;
using Gee;
using Catapult;
using Catapult.Gui.Fields;

namespace GtkFields
{
	public class GtkCustomCommandField : GtkSourceEditField
	{
		public const string MIME_TYPE="application/x-shellscript";
		const string DEFAULT_VALUE = "#/bin/sh\n";
		string? original_contents;
		public GtkCustomCommandField(string id, string? label=null, string? name=null, string? contents=null, string? pnd_id=null, string? pnd_app_id=null) {
			string title = "Custom command " + ((name != null && name != "") ? "for " + name : null);
			base(id, label, MIME_TYPE, title, contents ?? DEFAULT_VALUE);
			original_contents = contents;
			extend_edit_dialog(pnd_id, pnd_app_id);
		}

		public string? pnd_id {
			get { return file_field.pnd_id; }
			set { file_field.pnd_id = value; }
		}
		public string? pnd_app_id {
			get { return file_field.pnd_app_id; }
			set { file_field.pnd_app_id = value; }
		}

		protected override void clicked() {
			base.clicked();
			file_field.unmount_pnds();
		}

		void extend_edit_dialog(string pnd_id, string? pnd_app_id=null) {
			file_field = new GtkPndScriptFileField(this.id + "_file", "Load Pnd Script", pnd_id, pnd_app_id);
			file_field.content_requested.connect((content) => {
				source_buffer.set_text(content);
			});
			dialog.vbox.pack_start(file_field.widget, false, false, 0);
			dialog.vbox.pack_start(new HSeparator(), false, false, 6);
			var buttonbox = dialog.get_action_area() as HButtonBox;
			var btnRevert = new Button.with_label("_Revert");
			btnRevert.use_underline = true;
			btnRevert.clicked.connect(() => {
				source_buffer.set_text(original_contents);
			});
			buttonbox.pack_start(btnRevert, false, false, 0);
			buttonbox.set_child_secondary(btnRevert, true);
		}
		GtkPndScriptFileField file_field;


	}
}
