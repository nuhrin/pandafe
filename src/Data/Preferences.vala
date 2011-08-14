using Gee;
using Catapult;
using Catapult.Gui;
using Catapult.Gui.Fields;
using Catapult.Gui.Fieldsets;

namespace Data
{
	public class Preferences : Entity, GuiEntity
	{
		public const string FONT = "/usr/share/fonts/truetype/ttf-dejavu/DejaVuSansMono.ttf";

		internal const string ENTITY_ID = "preferences";
		protected override string generate_id() { return ENTITY_ID; }

		construct {
			platform_order = new ArrayList<string>();
		}

		public string test { get; set; }
		public Gee.List<string> platform_order { get; set; }

		public void update_platform_order(Iterable<Platform> platforms) {
			platform_order.clear();
			foreach(var platform in platforms)
				platform_order.add(platform.id);
		}

		protected void populate_field_box(FieldBox box) {
			// add notebook
			var notebook = new NotebookFieldset("preferences_notebook");
			notebook.show_tabs = false;
			// add single page
			var first_page = notebook.add_page("first_page", "Page");
			var frame = new FrameFieldset("frame", "Preferences");
			first_page.add_field(frame);
			frame.add_string("test", "_Test", this.test);
			box.add_field(notebook);
			box.set_field_packing(notebook, true, true, 0, Gtk.PackType.START);
		}

	}
}
