using Gtk;
using Gee;
using Catapult.Gui.Fields;
using Data.Pnd;

namespace GtkFields
{
	public class GtkPndScriptFileField : StringSelectionField
	{
		MountSet mountset;
		HashSet<string> mounted_id_set;
		public GtkPndScriptFileField(string id, string? label=null, string? pnd_id=null, string? pnd_app_id=null) {
			base(id, label);
			mountset = Data.pnd_mountset(); //new MountSet("pandafe/configtmp/");
			mounted_id_set = new HashSet<string>();
			this.pnd_id = pnd_id;
			this.pnd_app_id = pnd_app_id;
			build_target_with_buttons();
		}
		public string? pnd_id { get; set; }
		public string? pnd_app_id { get; set; }

		public new string? value {
			owned get { return (string)get_active_value(); }
			set { set_active_value(value); }
		}

		public void rescan() {
			var selected_id = value;
			clear_items();
			populate_items(selected_id);
			if (value == selected_id)
				make_clean();
		}
		public void unmount_pnds() {
			foreach(string id in mounted_id_set)
				mountset.unmount(id);
			clear_items();
			loadBtn.visible = false;
			scanBtn.visible = true;
		}

		public signal void content_requested(string content);

		void populate_items(string? selected_file) {
			hbox.parent.sensitive = false;

			var unique_id = pnd_app_id ?? pnd_id;
			if (unique_id == null)
				return;

			// try to mount the pnd
			if (mountset.is_mounted(pnd_id) == false) {
				if (mountset.mount(unique_id, pnd_id) == false) {
					hbox.parent.sensitive = true;
					return;
				}
				mounted_id_set.add(pnd_id);
			}
			var path = mountset.get_mounted_path(pnd_id);
			if (path == null) {
				hbox.parent.sensitive = true;
				return;
			}

			// search pnd for script files
			try {
				populate_folder_items(path + "/");
			} catch(Error e) {
				debug("Error while scanning pnd for script files: %s", e.message);
			}

			for(int index=0; index<item_count; index++) {
				if (selected_file != null && selected_file == get_item(index)) {
					combo_box.active = index;
					break;
				}
			}

			if (combo_box.active == -1 && item_count > 0)
				combo_box.active = 0;

			scanBtn.visible = false;
			loadBtn.visible = true;
			loadBtn.sensitive = (item_count > 0);
			hbox.parent.sensitive = true;
		}

		void populate_folder_items(string root_path, string? relative_path=null) throws GLib.Error
		{
			var directory = File.new_for_path(root_path + relative_path);
			var enumerator = directory.enumerate_children("standard::*", FileQueryInfoFlags.NONE);
			FileInfo file_info;
			while ((file_info = enumerator.next_file ()) != null) {
				var type = file_info.get_file_type();
				var name = file_info.get_name();
				var path = (relative_path == null) ? name : relative_path + "/" + name;
				if (type == FileType.DIRECTORY) {
					populate_folder_items(root_path, path);
				}
				else if (type == FileType.REGULAR) {
					var content_type = file_info.get_content_type();
					if (content_type == GtkCustomCommandField.MIME_TYPE) {
						add_item(path);
					}
				}
			}
		}

		protected override Widget target_widget { get { return hbox; } }

		void build_target_with_buttons() {
			hbox = new PndFileBox(false, 4, combo_box);
			hbox.pack_start(combo_box, true, true, 0);
			scanBtn = new Button.with_label("Scan Pnd");
			//scanBtn.image = new Image.from_stock(Stock.REFRESH, IconSize.BUTTON);
			scanBtn.can_focus = false;
			scanBtn.no_show_all = true;
			scanBtn.visible = true;
			scanBtn.clicked.connect(() => this.scan_clicked());
			hbox.pack_start(scanBtn, false, false, 0);
			loadBtn = new Button.with_label("Load");
			loadBtn.no_show_all = true;
			loadBtn.visible = false;
			loadBtn.can_focus = false;
			loadBtn.clicked.connect(() => this.load_clicked());
			hbox.pack_start(loadBtn, false, false, 0);
		}
		HBox hbox;
		Button loadBtn;
		Button scanBtn;
		void scan_clicked() {
			rescan();
		}
		void load_clicked() {
			var selected = active_item;
			if (selected == null)
				return;
			string path = mountset.get_mounted_path(pnd_app_id ?? pnd_id);
			if (path == null)
				return;
			path = path + "/" + selected;
			string contents;
			try {
				if (FileUtils.get_contents(path, out contents) == true)
					content_requested(contents);
			} catch(FileError e) {
				debug("Error while loading '%s' contents: %s", path, e.message);
			}
		}

		class PndFileBox : HBox {
			public PndFileBox(bool homogeneous, int spacing, Widget mnemonic_widget) {
				this.homogeneous = homogeneous;
				this.spacing = spacing;
				this.mnemonic_widget = mnemonic_widget;
			}
			Widget mnemonic_widget;
			public override bool mnemonic_activate (bool group_cycling) {
				if (mnemonic_widget == null)
					return true;
				mnemonic_widget.grab_focus();
				return true;
			}
		}
	}
}
