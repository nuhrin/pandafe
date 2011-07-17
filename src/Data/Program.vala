using Catapult;
using Catapult.Gui;
using Catapult.Gui.Fields;
using Catapult.Gui.Fieldsets;

public class Program : NamedEntity, GuiEntity
{
	public string pnd_id { get; set; }
	public string pnd_app_id { get; set; }
	public string exe_path { get; set; }

	public string options { get; set; }
	public uint clockspeed { get; set; }

	protected void populate_field_container(FieldContainer container) {
		var notebook = new NotebookFieldset("kupo");
		var page = notebook.add_page("page1", "Neat Page", false, 0);
		var page2 = notebook.add_page("page2", "Empty Page", false, 0);
		var frame = new FrameFieldset(this.Name ?? "new Program", "Program Fields", false, 8);
		page.add_field(frame);
		frame.add_string("Name", "_Name", this.Name);

		frame.add_object_properties(this);
		container.add_field(notebook);
	}

	protected void apply_fieldset(Fieldset fieldset) {
		var fields = fieldset.value_fields();
		foreach(var field in fields) {
			if (field.has_changes()) {
				debug("setting program field %s", field.id);
				this.set_property(field.id, field.value);
			}
		}
	}

	protected Field get_reference_selection_field(DataInterface data_interface, string id, string? label) {
		return new EntityReferenceField(data_interface, id, label, typeof(Program), (Name != null) ? this : null);
	}

}
