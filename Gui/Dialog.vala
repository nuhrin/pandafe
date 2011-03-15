using Gtk;
using YamlDB;

public class EntityDialog<T> : Dialog
{
	DataInterface db;
	Entity entity;
	HBox controls_hbox;
	VBox label_vbox;
	VBox value_vbox;
	
	protected EntityDialog(DataInterface db) {
		this.db = db;
		this.entity = GLib.Object.new(typeof(T)) as Entity;
		initialize();
		create_widgets();
	}
	protected EntityDialog.from_existing(DataInterface db, T entity) {
		this.db = db;
		this.entity = (Entity)entity;
		initialize();
		create_widgets();
	}
	
	void initialize() {
		this.title = "Entity dialog test";
		this.has_separator = true;
		this.border_width = 5;
		set_default_size(350, 100);		
	}
	void create_widgets() {
		// add widgets
		controls_hbox = new HBox(false, 10);
		this.vbox.pack_start(controls_hbox, true, true, 0);
		label_vbox = new VBox(false, 8);
		controls_hbox.pack_start(label_vbox, false, true, 0);
		value_vbox = new VBox(false, 8);
		controls_hbox.pack_start(value_vbox, true, true, 0);
		
		add_properties();
			
		// add buttons
		add_button (Stock.CANCEL, ResponseType.CANCEL);
		add_button (Stock.OK, ResponseType.OK);
		
		this.response.connect (on_response);
		
		show_all();
	}

	void add_properties() {
		unowned ObjectClass klass = entity.get_class();
	    var properties = klass.list_properties();
	    foreach(var prop in properties)
	    {
		    if ((prop.flags & ParamFlags.READWRITE) == ParamFlags.READWRITE)
		    	add_property_widgets(prop);
	    }
	}
	protected virtual void add_property_widgets(ParamSpec property) {
		var entry = new Entry();
		value_vbox.pack_start(entry, false,false,0);
		var label = new Label.with_mnemonic("_"+property.name);
		label.mnemonic_widget = entry;
		label_vbox.pack_start(label, false, false, 0);
		
	}
		
	void on_response (Dialog source, int response_id) {
		switch (response_id) {
			case ResponseType.OK:
				message("Okay!");
				break;
			case ResponseType.CANCEL:
				destroy ();
				break;
		}
	}

}
