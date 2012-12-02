/* SpawningResult.vala
 * 
 * Copyright (C) 2012 nuhrin
 * 
 * This file is part of Pandafe.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *      nuhrin <nuhrin@oceanic.to>
 */

using Gtk;
using Data.Pnd;

public class SpawningResult
{
	string _cmdline;
	string? _stdout;
	string? _stderr;
	string? _error;
	
	public SpawningResult(bool success, string command_line, string standard_output, string standard_error, int exit_status) {
		this.success = success;
		_cmdline = command_line;
		_stdout = standard_output;
		_stderr = standard_error;
		this.exit_status = exit_status;
	}
	public SpawningResult.error(string error) {
		success = false;
		_error = error;
		_cmdline = "";
		exit_status = -1;		
	}
	public SpawningResult.error_with_command_line(string error, string command_line) {
		success = false;
		_error = error;
		_cmdline = command_line;
		exit_status = -1;		
	}
	
	public bool success { get; private set; }	
	public unowned string? error_message { get { return _error; } }
	
	public unowned string command_line { get { return _cmdline; } }
	
	public string? standard_output { get { return _stdout; } }
	public string? standard_error { get { return _stderr; } }
	public int exit_status { get; private set; }
	
	public string get_verbose_result_message() {
		StringBuilder sb = new StringBuilder();
		sb.append_printf("\n********************************************************************************\n");
		sb.append_printf("Spawning Result\n\n");
		sb.append_printf("Command: %s\n", command_line);
		sb.append_printf("Success: %s\n", success.to_string());
		if (error_message != null) {
			sb.append_printf("Error: %s\n", error_message);
			sb.append_printf("********************************************************************************\n\n");
			return sb.str;
		}
		sb.append_printf("Exit Status: %d\n\n", exit_status);
		sb.append_printf("Standard Output:\n%s\n\n", standard_output);
		sb.append_printf("Standard Error:\n%s\n\n", standard_error);
		sb.append_printf("********************************************************************************\n\n");
		return sb.str;
	}
	public void show_result_dialog(string? primary_message=null, string? secondary_message=null) {
		@interface.ensure_gtk_init();
		
		string primary = "<b><big>%s</big></b>".printf(primary_message ?? "Spawn error");
		
		// manually implement most MessageDialog behavior, to allow it to be a toplevel, and for easy customization
		var dialog = new Dialog();
		dialog.title = "";
		dialog.set_default_size (@interface.screen_width, @interface.screen_height);
		dialog.border_width = 5;
		dialog.vbox.spacing = 14;
		dialog.action_area.border_width = 5;
		dialog.action_area.spacing = 6;
		var hbox = new HBox(false, 12);
		hbox.border_width = 5;
		dialog.vbox.pack_start(hbox, false, false, 0);
		var image = new Image.from_stock((success == true) ? Stock.DIALOG_INFO : Stock.DIALOG_ERROR, IconSize.DIALOG);
		image.set_alignment(0.5f, 0.0f);
		var message_vbox = new VBox(false, 12);
		hbox.pack_start(image, false, false, 0);
		hbox.pack_start(message_vbox, true, true, 0);
		var primary_label = new Label(primary);
		primary_label.use_markup = true;
		primary_label.selectable = true;
		primary_label.set_alignment(0.0f, 0.0f);
		var secondary_label = new Label(secondary_message);
		secondary_label.use_markup = true;
		secondary_label.selectable = true;
		secondary_label.set_alignment(0.0f, 0.0f);
		secondary_label.wrap = true;
		secondary_label.wrap_mode = Pango.WrapMode.CHAR;
		secondary_label.set_size_request(@interface.screen_width - 105, -1);
		message_vbox.pack_start(primary_label, false, false, 0);
		message_vbox.pack_start(secondary_label, true, true, 0);
		dialog.add_button(Stock.CLOSE, ResponseType.CLOSE);
				
		var text_buffer = new TextBuffer(null);
		var text_view = new TextView.with_buffer(text_buffer);
		text_view.editable = false;
		var sw = new ScrolledWindow(null, null);
		sw.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
		sw.shadow_type = ShadowType.ETCHED_IN;
		sw.add(text_view);
		dialog.vbox.pack_end(sw, true, true, 0);
	
		text_buffer.tag_table.add(new TextTag("bold") { weight = Pango.Weight.BOLD });
		text_buffer.tag_table.add(new TextTag("wrapchar") { wrap_mode = WrapMode.CHAR });
		if (error_message != null) {
			append_text(text_buffer, error_message, "bold");
		} else {
			append_text(text_buffer, "Command:\n", "bold");
			append_text(text_buffer, command_line, "wrapchar");
			append_text(text_buffer, "\nExit Status: ", "bold");
			append_text(text_buffer, exit_status.to_string());
			append_text(text_buffer, "\n\nStandard Output:\n", "bold");
			append_text(text_buffer, standard_output, "wrapchar");
			append_text(text_buffer, "\n\nStandard Error:\n", "bold");
			append_text(text_buffer, standard_error, "wrapchar");
		}
		
		dialog.response.connect((response_id) => {
			dialog.destroy();
			Gtk.main_quit();
		});
		
		dialog.show_all();
		Gtk.main();
	}
	void append_text(TextBuffer buffer, string text, string? style_name=null) {
		TextIter end;
		buffer.get_end_iter(out end);
		if (style_name == null)
			buffer.insert_with_tags_by_name(end, text, text.length);
		else
			buffer.insert_with_tags_by_name(end, text, text.length, style_name);
	}
}
