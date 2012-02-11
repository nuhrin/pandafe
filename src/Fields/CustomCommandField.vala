using Gtk;
using Gee;
using Data.Pnd;
using Layers.Controls;
using Menus;
using Menus.Fields;

namespace Fields
{
	public class CustomCommandField : MenuItemField
	{
		const string MIME_TYPE="application/x-shellscript";
		const string DEFAULT_VALUE = "#/bin/sh\n";
		
		string _title;
		MountSet mountset;
		HashSet<string> mounted_id_set;
		string? _pnd_id;
		string? _pnd_app_id;
		
		string _value;
				
		public CustomCommandField(string id, string name, string? help=null, string? program_name=null, string? value=null, string? app_id=null, string? pnd_id=null) {
			base(id, name, help);
			_title = "Custom command " + ((program_name != null && program_name != "") ? "for " + program_name : null);
			_value = value;
			_pnd_id = pnd_id;
			_pnd_app_id = app_id;
			mountset = Data.pnd_mountset();
			mounted_id_set = new HashSet<string>();			
		}

		public new string? value {
			get { return _value; }
			set { change_value(value); }
		}

		public string? pnd_app_id { get { return _pnd_app_id; } }
		public string? pnd_id { get { return _pnd_id; } }
		public void set_app(string? pnd_app_id, string? pnd_id) {
			_pnd_app_id = pnd_app_id;
			_pnd_id = pnd_id;
		}

		public override string get_value_text() { return "..."; }
		public override int get_minimum_menu_value_text_length() { return 0; }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((string)value); }

		protected override void activate(MenuSelector selector) {
			string? contents;
			if (run_dialog(out contents) == true) {
				change_value(contents);
				//selector.update_selected_item_value();
				//selector.update();
			}			
		}
		
		bool change_value(string? new_value) {
			_value = new_value;
			changed();
			return true;
		}
		
		bool run_dialog(out string? contents) {			
			@interface.ensure_gtk_init();
			
			// source buffer
			var manager = new SourceLanguageManager();
			var language = manager.guess_language(null, MIME_TYPE);
			var source_buffer = (language != null)
				? new SourceBuffer.with_language(language)
				: new SourceBuffer(null);
			source_buffer.set_text(_value ?? DEFAULT_VALUE);
			var source_view = new SourceView.with_buffer(source_buffer);
			var sw = new ScrolledWindow(null, null);
			sw.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			sw.shadow_type = ShadowType.ETCHED_IN;
			sw.add(source_view);

			// dialog
			var dialog = new Dialog();
			dialog.title = _title;
			dialog.vbox.pack_end(sw, true, true, 0);
			dialog.add_button (Stock.CANCEL, ResponseType.CANCEL);
			dialog.add_button(Stock.OK, ResponseType.OK);
			dialog.set_default_size (@interface.screen_width, @interface.screen_height);
			
			// revert button
			var buttonbox = dialog.get_action_area() as HButtonBox;
			var btnRevert = new Button.with_label("_Revert");
			btnRevert.use_underline = true;
			btnRevert.clicked.connect(() => {
				source_buffer.set_text(_value ?? DEFAULT_VALUE);
			});
			buttonbox.pack_start(btnRevert, false, false, 0);
			buttonbox.set_child_secondary(btnRevert, true);

			// pnd script loading
			var combo = new ComboBox.text();
			var hbox = new PndFileBox(false, 4, combo);
			hbox.pack_start(new Label("Load Pnd Script: "), false, false, 0);
			hbox.pack_start(combo, true, true, 0);
			var loadBtn = new Button.with_label("Load");
			var scanBtn = new Button.with_label("Scan Pnd");
			//scanBtn.image = new Image.from_stock(Stock.REFRESH, IconSize.BUTTON);
			scanBtn.can_focus = false;
			scanBtn.no_show_all = true;
			scanBtn.visible = true;
			scanBtn.clicked.connect(() => {
				dialog.sensitive = false;
				string selected = combo.get_active_text();
				clear_items(combo);
				populate_items(selected, dialog, combo, scanBtn, loadBtn);
				dialog.sensitive = true;
			});
			hbox.pack_start(scanBtn, false, false, 0);
			loadBtn.no_show_all = true;
			loadBtn.visible = false;
			loadBtn.can_focus = false;
			loadBtn.clicked.connect(() => {
				var selected = combo.get_active_text();
				if (selected == null)
					return;
				string path = mountset.get_mounted_path(pnd_app_id ?? pnd_id);
				if (path == null)
					return;
				path = path + "/" + selected;
				string file_contents;
				try {
					if (FileUtils.get_contents(path, out file_contents) == true)
						source_buffer.set_text(file_contents ?? "");					
				} catch(FileError e) {
					debug("Error while loading '%s' contents: %s", path, e.message);
				}
			});
			hbox.pack_start(loadBtn, false, false, 0);
			dialog.vbox.pack_start(hbox, false, false, 0);
			dialog.vbox.pack_start(new HSeparator(), false, false, 6);
			
			// response handling
			bool ok_clicked = false;
			string? buffer = null;
			dialog.response.connect((response_id) => {
				if (response_id == ResponseType.OK) {
					TextIter start;
					TextIter end;
					source_buffer.get_bounds(out start, out end);
					buffer = source_buffer.get_text(start, end, true);
					if (buffer._strip() == "")
						buffer = null;
					ok_clicked = true;
				}
				dialog.destroy();
				Gtk.main_quit();
			});
			
			// run it
			dialog.show_all();
			Gtk.main();
			
			// unmount pnds, if needed
			foreach(string id in mounted_id_set)
				mountset.unmount(id);
			
			// done
			contents = buffer;
			return ok_clicked;
		}
		
		void clear_items(ComboBox combo) {
			int count = combo.model.iter_n_children(null);
			for(int index=count-1;index>= 0; index--)
				combo.remove_text(index);
		}
		void populate_items(string? selected_file, Dialog dialog, ComboBox combo, Button scanBtn, Button loadBtn) {
			var unique_id = pnd_app_id ?? pnd_id;
			if (unique_id == null)
				return;

			// try to mount the pnd
			if (mountset.is_mounted(pnd_id) == false) {
				if (mountset.mount(unique_id, pnd_id) == false)
					return;
				mounted_id_set.add(pnd_id);
			}
			var path = mountset.get_mounted_path(pnd_id);
			if (path == null)
				return;			

			// search pnd for script files
			int existing_index = -1;
			try {
				existing_index = populate_folder_items(path + "/", null, combo, selected_file);
			} catch(Error e) {
				debug("Error while scanning pnd for script files: %s", e.message);
			}
			
			int count = combo.model.iter_n_children(null);
			
			if (existing_index != -1)
				combo.active = existing_index;
			else if (count > 0)
				combo.active = 0;
			
			scanBtn.visible = false;
			loadBtn.visible = true;
			loadBtn.sensitive = (count > 0);
		}
		int populate_folder_items(string root_path, string? relative_path=null, ComboBox combo, string? selected_file) throws GLib.Error
		{
			int existing_index = -1;
			var directory = File.new_for_path(root_path + relative_path);
			var enumerator = directory.enumerate_children("standard::*", FileQueryInfoFlags.NONE);
			FileInfo file_info;
			while ((file_info = enumerator.next_file ()) != null) {
				var type = file_info.get_file_type();
				var name = file_info.get_name();
				var path = (relative_path == null) ? name : relative_path + "/" + name;
				if (type == FileType.DIRECTORY) {
					int child_index = populate_folder_items(root_path, path, combo, selected_file);
					if (child_index != -1 && existing_index == -1)
						existing_index = child_index;
				}
				else if (type == FileType.REGULAR) {
					var content_type = file_info.get_content_type();
					if (content_type == MIME_TYPE) {
						if (existing_index == -1 && path == selected_file)
							existing_index = combo.model.iter_n_children(null);
						combo.append_text(path);
					}
				}
			}
			return existing_index;
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
