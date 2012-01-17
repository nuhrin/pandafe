using Gtk;
using Gee;
using Catapult.Gui.Fields;
using Data.Pnd;

namespace Fields
{
	public class PndAppSelectionField : ValueSelectionField
	{
		PndData data;
		public PndAppSelectionField(PndData data, string id, string? label=null, string? pnd_id, string? app_id) {
			base(id, label, typeof(string));
			this.data = data;
			populate_items(pnd_id, app_id);
			make_clean();
		}

		public new AppItem? value {
			owned get { return (AppItem)get_active_value(); }
			set {
				clear_items();
				if (value == null)
					populate_items(null, null);
				else
					populate_items(value.package_id, value.id);
			}
		}
		public string app_id { get { return (value != null) ? value.id : ""; } }
		public string pnd_id { get { return (value != null) ? value.package_id : ""; } }

		public void reload(string? pnd_id) {
			string? selected_id = null;
			if (value != null)
				selected_id = value.id;
			clear_items();
			populate_items(pnd_id, selected_id);
			make_clean();
		}

		void populate_items(string? pnd_id, string? selected_app_id) {
			add_item("None", Value(typeof(string)));
			if (pnd_id == null)
				return;
			var pnd = data.get_pnd(pnd_id);
			if (pnd == null)
				return;
			int index=1;
			bool found_given_value = false;
			foreach(var app in pnd.apps) {
				add_item(app.title, app.id);
				if (selected_app_id != null && app.id == selected_app_id) {
					value = app;
					found_given_value = true;
					combo_box.active = index;
				}
				index++;
			}
			if (combo_box.active == -1 && index > 1)
				combo_box.active = 0;
		}

		protected override bool values_are_equal(Value a, Value b) {
			return a.get_string() == b.get_string();
		}
	}
}
