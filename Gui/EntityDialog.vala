using Gee;
using Gtk;
using YamlDB;
using yayafe.Gui;
using yayafe.Gui.Fields;

public class EntityDialog<T> : Dialog
{
	public static TEntity create<TEntity>(DataInterface data_interface, string? type_name=null) throws FileError, RuntimeError, YamlError
		requires(typeof(TEntity).is_a(typeof(Entity)))
	{
		string title = "Add new " + (type_name ?? typeof(TEntity).name());
		var dialog = new EntityDialog<TEntity>(data_interface, title);
		dialog.show();
		var response = dialog.run();
		if (response == ResponseType.OK) {
			dialog.update_entity();
			data_interface.save(dialog.entity);
			return dialog.entity;
		}
		return null;
	}
	public static bool edit<TEntity>(DataInterface data_interface, TEntity entity, string? type_name=null) throws FileError, RuntimeError, YamlError
		requires(typeof(TEntity).is_a(typeof(Entity)))
	{
		string title = "Edit " + (type_name ?? typeof(TEntity).name());
		string name = "";
		var namedEntity = entity as NamedEntity;
		if (namedEntity != null)
			name = namedEntity.Name.chug();
		if (name == "")
			name = ((Entity)entity).ID;
		var dialog = new EntityDialog<TEntity>.from_existing(data_interface, entity, title + ": " + name);
		dialog.show();
		var response = dialog.run();
		if (response == ResponseType.OK) {
			dialog.update_entity();
			data_interface.save(dialog.entity);
			return true;
		}
		return false;
	}
	DataInterface data_interface;
	Entity entity;
	ArrayList<LabeledField> fields;
	
	internal EntityDialog(DataInterface data_interface, string title) {
		this.data_interface = data_interface;
		this.title = title;
		this.entity = GLib.Object.new(typeof(T)) as Entity;
		initialize();
		build();
	}
	internal EntityDialog.from_existing(DataInterface data_interface, T entity, string title) {
		this.data_interface = data_interface;
		this.title = title;
		this.entity = (Entity)entity;
		initialize();
		build();
	}
	
	void initialize() {
		fields = new ArrayList<LabeledField>();
		this.has_separator = true;
		this.border_width = 5;
		set_default_size(350, 100);
	}
	void build() {
		// add widgets
//		controls_hbox = new HBox(false, 10);
//		this.vbox.pack_start(controls_hbox, true, true, 0);
//		label_vbox = new VBox(false, 8);
//		controls_hbox.pack_start(label_vbox, false, true, 0);
//		value_vbox = new VBox(false, 8);
//		controls_hbox.pack_start(value_vbox, true, true, 0);
//
		var builder = new DialogBuilder(data_interface);
		if (typeof(T).is_a(typeof(GuiEntity)))
			((GuiEntity)entity).i_build_dialog(builder);
		else
			builder.add_object_properties(entity);

		foreach(var field in builder.labeled_fields()) {
			fields.add((LabeledField)field);
			this.vbox.pack_start(field.widget, false,false, 4);
		}

		//add_properties();

		// add buttons
		add_button (Stock.CANCEL, ResponseType.CANCEL);
		add_button (Stock.SAVE, ResponseType.OK);

		show_all();
	}

	void update_entity() {
		var reader = new DialogReader();
		if (typeof(T).is_a(typeof(GuiEntity)))
			((GuiEntity)entity).i_apply_dialog(reader);
		else {
			foreach(var field in fields) {
				if (field.is_dirty)
					entity.set_property(field.name, field.value);
			}
		}
	}
}
