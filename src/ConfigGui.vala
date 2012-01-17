using Gtk;
using Catapult;
using Catapult.Gui;
using Catapult.Gui.Fields;
using Catapult.Gui.Fieldsets;
using GtkFields;

public class ConfigGui : Window
{
	static bool gtk_is_initialized;
	static void ensure_gtk_init() {
		if (gtk_is_initialized == true)
			return;
		unowned string[] args = NULL_ARGS;
		Gtk.init(ref args);
	}
	static string[] NULL_ARGS = null;

	public static void run() {
		ensure_gtk_init();

		new ConfigGui().show_all();

		Gtk.main();
	}

	public static void edit_platform(Platform platform) {
		ensure_gtk_init();

		try {
			EntityDialog.edit(Data.data_interface(), platform);
		} catch(Error e) {
			debug("Error editing platform %s: %s", platform.name, e.message);
		}
		debug("all done platform!");
	}
	public static void edit_program(Platform platform, Data.Program program) {
		bool platform_owns_program = false;
		foreach(var prog in platform.programs) {
			if (prog == program) {
				platform_owns_program = true;
				break;
			}
		}
		if (platform_owns_program == false)
			return;

		ensure_gtk_init();

		try {
			var data_interface = Data.data_interface();
			if (EntityDialog.edit_object(data_interface, program, "Program", program.name, Gtk.Stock.SAVE) == true)
				data_interface.save(platform);
		} catch(Error e) {
			debug("Error editing program %s: %s", platform.name, e.message);
		}
		debug("all done program!");
	}

	NotebookFieldset platforms_notebook;
	NotebookPageFieldset preferences_page;
	Data.Preferences preferences;
	GtkPlatformListField platform_list_field;

	public ConfigGui() {
		var alignment = new Alignment(0, 0, 1, 1);
		var vbox = new VBox(false, 0);
		alignment.add(vbox);
		var main_notebook = new NotebookFieldset("main_notebook");
		main_notebook.tab_position = PositionType.BOTTOM;
		main_notebook.set_padding(0, 6, 0, 0);

		preferences_page = main_notebook.add_page("preferences_page", "Preferences");
		preferences_page.set_padding(6, 6, 6, 6);
		preferences = Data.preferences();
		preferences_page.add_gui_entity(preferences);

		var platforms_page = main_notebook.add_page("platforms_page", "Platforms");
		platforms_page.set_padding(6, 6, 6, 6);
		platforms_notebook = new NotebookFieldset("platforms_notebook");
		platforms_page.add_field(platforms_notebook);
		platforms_page.set_field_packing(platforms_notebook, true, true, 0, Gtk.PackType.START);

		var platform_list_page = platforms_notebook.add_page("list", "List");
		var frame = new FrameFieldset("frame", "Platforms");
		platform_list_field = new GtkPlatformListField("platform_list", null, Data.platforms());
		frame.add_field(platform_list_field);
		platform_list_page.add_field(frame);

		var buttons = new HButtonBox();
		buttons.layout_style = ButtonBoxStyle.END;
		var close_button = new Button.with_label("Close");
		close_button.can_focus = false;
		close_button.clicked.connect(close_requested);
		buttons.pack_start(close_button, false, false, 0);
		main_notebook.action_area_end.set_padding(6, 0, 0, 6);
		main_notebook.action_area_end.widget_pack_end(buttons, false, false, 0);
		main_notebook.action_area_end.widget.show_all();

		vbox.pack_start(main_notebook.widget, true, true, 0);
		this.add(alignment);


		title = "Pandafe Configuration";
		set_default_size (800, 480);
		fullscreen();
		decorated = false;
		destroy.connect(close_requested);
	}

//~ 	Widget create_main_buttons() {
//~ 		var box = new HButtonBox();
//~ 		box.layout_style = ButtonBoxStyle.START;
//~
//~ 		var preferences_button = new ToggleButton.with_label("Preferences");
//~ 		preferences_button.can_focus = false;
//~ 		preferences_button.active = true;
//~ 		box.pack_start(preferences_button, false, false, 12);
//~ 		var platforms_button = new ToggleButton.with_label("Platforms");
//~ 		platforms_button.can_focus = false;
//~ 		box.pack_start(platforms_button, false, false, 12);
//~
//~ 		preferences_button.button_release_event.connect((event) => {
//~ 			if (preferences_button.active == false) {
//~ 				preferences_button.active = true;
//~ 				platforms_button.active = false;
//~ 				main_notebook.current_page = 0;
//~ 			}
//~ 			return true;
//~ 		});
//~ 		platforms_button.button_release_event.connect((event) => {
//~ 			if (platforms_button.active == false) {
//~ 				platforms_button.active = true;
//~ 				preferences_button.active = false;
//~ 				main_notebook.current_page = 1;
//~ 			}
//~ 			return true;
//~ 		});
//~
//~ 		var close_button = new Button.with_label("Close");
//~ 		close_button.can_focus = false;
//~ 		close_button.clicked.connect(close_requested);
//~ 		box.pack_start(close_button, false, false, 12);
//~ 		box.set_child_secondary(close_button, true);
//~
//~ 		return box;
//~ 	}

	void close_requested() {
		// save preferences, if need be
		bool needs_save = false;
		if (preferences_page.has_changes()) {
			preferences_page.populate_object(preferences);
			needs_save = true;
		}
		if (platform_list_field.has_changes()) {
			preferences.update_platform_order(platform_list_field.get_items());
			Data.flush_platforms();
			needs_save = true;
		}
		if (needs_save == true)
			Data.save_preferences();

		// quit
		destroy();
		Gtk.main_quit();
	}
}

