using Gtk;
using Gee;
using Data;
using Data.Pnd;
using Layers.Controls;
using Menus;
using Menus.Fields;

namespace Fields
{
	public class CustomCommandField : MenuItemField
	{
		const string DEFAULT_MIME_TYPE="application/x-shellscript";
		const string DEFAULT_OPEN_FILE_TITLE="Choose PND script...";
		const string DEFAULT_VALUE = "#/bin/sh\n";
		
		string _title;
		string? _title_prefix;
		string? _script_name;
		string? _mime_type;
		string? _open_file_title;
		MountSet mountset;
		string? mounted_id;
		string? mounted_path;
		string _value;
		string _stock;
				
		public CustomCommandField(string id, string name, string? help=null, Program? program, string? value=null, string? title_prefix=null) {
			base(id, name, help);
			_title_prefix = title_prefix;
			_value = value;
			if (program != null) {
				set_program_name(program.name);
				app = program.get_app();
			} else {
				set_program_name("(Unknown)");
			}
			mountset = Data.pnd_mountset();
		}
		~CustomCommandField() {
			ensure_unmount();
		}

		public new string? value {
			get { return _value; }
			set { change_value(value); }
		}
		
		public AppItem? app { 
			get { return _app; }
			set {
				ensure_unmount();
				_app = value;
				changed();
			}
		}
		AppItem? _app;

		public void set_program_name(string name) {
			_title = (_title_prefix ?? "Command for ") + name;
		}
		public void set_script_name(string script_name) {
			_script_name = script_name;
		}
		public bool is_secondary_command { get; set; }
		public string mime_type { 
			owned get { return _mime_type ?? DEFAULT_MIME_TYPE; }
			set { _mime_type = value; }
		}
		public string open_file_title { 
			owned get { return _open_file_title ?? DEFAULT_OPEN_FILE_TITLE; }
			set { _open_file_title = value; }
		}
		
		public override string get_value_text() { 
			if (is_secondary_command)
				return "...";
			return (has_value() || app == null) ? "(custom)" : app.exec_command; 
		}
		public override int get_minimum_menu_value_text_length() { return 0; }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((string)value); }		
		protected override bool has_value() { return (_value != null && _value.strip() != ""); }

		protected override void activate(MenuSelector selector) {
			string? contents;
			bool had_value = has_value();
			if (run_dialog(out contents) == true) {
				if (contents != null && contents != _value && mounted_path != null && app != null) {
					// remove custom script, if it already exists, so it will be updated on next run
					string script_name = _script_name ?? Spawning.get_custom_command_script_name(app);
					string custom_script_path = Path.build_filename(mounted_path, script_name);
					if (FileUtils.test(custom_script_path, FileTest.EXISTS) == true)
						FileUtils.remove(custom_script_path);
				}
				change_value(contents);
				if (has_value() != had_value) {
					selector.update_selected_item_value();
					selector.update();
				}
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
			var language = manager.get_language("sh");
			var source_buffer = (language != null)
				? new SourceBuffer.with_language(language)
				: new SourceBuffer(null);
			var source_view = new SourceView.with_buffer(source_buffer);
			var sw = new ScrolledWindow(null, null);
			sw.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			sw.shadow_type = ShadowType.ETCHED_IN;
			sw.add(source_view);
			Widget buffer_widget = sw;
			Label frame_label = null;
			if (is_secondary_command == false) {
				var frame = new Frame("<b>Custom</b>");
				frame_label = frame.label_widget as Label;
				frame_label.use_markup = true;
				frame.shadow_type = ShadowType.NONE;
				frame.add(sw);
				buffer_widget = frame;
			}
			var notebook = new Notebook();
				
			// dialog
			var dialog = new Dialog();
			dialog.title = _title;
			dialog.add_button (Stock.CANCEL, ResponseType.CANCEL);
			dialog.add_button(Stock.OK, ResponseType.OK);
			dialog.set_default_size (@interface.screen_width, @interface.screen_height);
			
			ensure_stock_text();
			bool stock_supported = (is_secondary_command == false && _stock != null && app != null);
			bool stock_active = false;
			
			if (mounted_path != null) {
				notebook.show_border = false;
				notebook.append_page(buffer_widget, new Label("Content"));
				notebook.page = 0;
				
				dialog.vbox.pack_end(notebook, true, true, 0);
			} else
				dialog.vbox.pack_end(buffer_widget, true, true, 0);
			
						
			// revert, stock buttons
			var btnRevert = new Button.with_mnemonic("_Revert");
			var btnStock = new ToggleButton.with_mnemonic("_Stock");
			btnRevert.clicked.connect(() => {
				if (stock_supported == true && has_value() == false) {
					btnStock.active = true;
				} else {
					btnStock.active = false;
					source_buffer.set_text(_value ?? DEFAULT_VALUE);
				}
			});
			btnStock.toggled.connect(() => {
				if (btnStock.active == false) {
					frame_label.label = "<b>Custom</b>";
					stock_active = false;
					return;
				}
				frame_label.label = "<b>%s</b>".printf(app.exec_command);
				source_buffer.set_text(_stock);
				stock_active = true;
			});
			source_buffer.changed.connect(() => {
				if (stock_active == true)
					btnStock.active = false;
			});
			
			// open button
			var btnOpen = new Button.with_mnemonic("_Open");				
			if (mounted_path != null) {				
				btnOpen.clicked.connect(() => {
					var chooser = new FileChooserDialog(open_file_title, dialog, FileChooserAction.OPEN);
					var filter = new FileFilter();
					filter.add_mime_type(mime_type);
					chooser.filter = filter;
					chooser.set_current_folder(mounted_path);
					chooser.add_button(Stock.CANCEL, ResponseType.CANCEL);
					chooser.add_button(Stock.OK, ResponseType.OK);
					chooser.set_default_size (@interface.screen_width, @interface.screen_height);
					chooser.set_transient_for(dialog);
					string? new_contents = null;
					chooser.response.connect((response_id) => {
						if (response_id == ResponseType.OK) {
							try {
								FileUtils.get_contents(chooser.get_filename(), out new_contents);
							} catch(FileError e) {			
							}							
						}
						chooser.destroy();
						Gtk.main_quit();
					});
					chooser.show_all();
					Gtk.main();
					if (new_contents != null)
						source_buffer.set_text(new_contents);
				});
			}

			var buttonbox = dialog.get_action_area() as HButtonBox;
			buttonbox.pack_start(btnRevert, false, false, 0);
			buttonbox.set_child_secondary(btnRevert, true);
			
			if (mounted_path != null) {
				buttonbox.pack_start(btnOpen, false, false, 0);
				buttonbox.set_child_secondary(btnOpen, true);
			}
			if (stock_supported) {
				buttonbox.pack_start(btnStock, false, false, 0);
				buttonbox.set_child_secondary(btnStock, true);
			}
			
			if (stock_supported == false || has_value() == true) {
				source_buffer.set_text(_value ?? DEFAULT_VALUE);
			} else {
				btnStock.active = true;
			}
			if (mounted_path != null) {
				var terminal_sw = new ScrolledWindow(null, null);
				terminal_sw.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
				terminal_sw.shadow_type = ShadowType.ETCHED_IN;
				notebook.show_tabs = true;
				notebook.append_page(terminal_sw, new Label("Terminal"));
				notebook.switch_page.connect((page,num) => {
					if (num == 0) {
						btnRevert.visible = true;
						btnOpen.visible = true;
						btnStock.visible = true;
					} else if (num == 1) {
						btnRevert.visible = false;
						btnOpen.visible = false;
						btnStock.visible = false;
						
						if (terminal_sw.child == null) {
							var vte = new Vte.Terminal();
							terminal_sw.add(vte);
							vte.show_all();
							vte.fork_command("/bin/bash", null, null, mounted_path, false, false, false);
//~ 							try {								
//~ 								Pid pid;
//~ 								vte.fork_command_full(Vte.PtyFlags.DEFAULT, mounted_path, new string[] { Vte.get_user_shell() }, null, 0, null, out pid);
//~ 							}
//~ 							catch(GLib.Error e) {
//~ 							}
						}
					}
				});
			}
			
			
			// response handling
			bool ok_clicked = false;
			string? buffer = null;
			dialog.response.connect((response_id) => {
				if (response_id == ResponseType.OK) {
					if (stock_active == false) {
						buffer = get_buffer_text(source_buffer);
						if (buffer._strip() == "")
							buffer = null;
					}
					ok_clicked = true;
				}
				dialog.destroy();
				Gtk.main_quit();
			});
			
			// run it
			dialog.show_all();
			Gtk.main();
						
			// done
			contents = buffer;
			return ok_clicked;
		}
		bool ensure_mount() {
			if (app == null)
				return false;
			
			bool is_new_mount = (mountset.is_mounted(app.package_id) == false && 
								 mountset.mount(app.id, app.package_id) == true);
			
			mounted_path = mountset.get_mounted_path(app.package_id);
			if (mounted_path != null) {
				mounted_id = app.package_id;
				return true;
			} else if (is_new_mount == true) {
				mountset.unmount(app.package_id);				
			}
			mounted_path = null;
			mounted_id = null;
			return false;
		}
		void ensure_unmount() {
			if (mounted_id != null) {
				mountset.unmount(mounted_id);
				mounted_id = null;
				mounted_path = null;
				_stock = null;
			}
		}
		void ensure_stock_text() {
			if (app == null) {
				_stock = null;
				return;
			}
			if (ensure_mount() == false) {
				_stock = null;
				return;
			}

			if (_stock != null)
				return;
						
			var path = mounted_path + "/" + app.exec_command;
			try {
				FileUtils.get_contents(path, out _stock);
			} catch(FileError e) {
				warning("Error while loading '%s' contents: %s", path, e.message);
				_stock = null;
			}			
		}
		
		string get_buffer_text(SourceBuffer buffer) {
			TextIter start;
			TextIter end;
			buffer.get_bounds(out start, out end);
			return buffer.get_text(start, end, true);
		}
	}
}
