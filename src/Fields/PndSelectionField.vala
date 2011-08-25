using Gtk;
using Gee;
using Catapult.Gui.Fields;
using Data.Pnd;

namespace Fields
{
	public class PndSelectionField : ValueSelectionField
	{
		PndData data;
		public PndSelectionField(PndData data, string id, string? label=null, string? pnd_id) {
			base(id, label, typeof(string));
			this.data = data;
			populate_items(pnd_id);
			make_clean();
			build_target_with_buttons();
		}

		public new string? value {
			owned get { return (string)get_active_value(); }
			set { set_active_value(value); }
		}

		public PndItem? get_selected_pnd() {
			return data.get_pnd(value);
		}

		public void rescan() {
			var selected_id = value;
			clear_items();
			data.rescan();
			populate_items(selected_id);
			if (value == selected_id)
				make_clean();
		}
		void populate_items(string? selected_id) {
			add_item("None", "");
			int index=1;
			bool found_given_value = false;
			foreach(var pnd in data.get_all_pnds()) {
				add_item(pnd.pnd_id, pnd.pnd_id);
				if (selected_id != null && pnd.pnd_id == selected_id) {
					found_given_value = true;
					combo_box.active = index;
				}
				index++;
			}
			if (combo_box.active == -1 && index > 1)
				combo_box.active = 0;
		}

		protected override Widget target_widget { get { return hbox; } }

		protected override bool values_are_equal(Value a, Value b) {
			return a.get_string() == b.get_string();
		}

		void build_target_with_buttons() {
			hbox = new PndSelectionBox(false, 4, combo_box);
			hbox.pack_start(combo_box, true, true, 0);
			var rescanBtn = new Button();
			rescanBtn.image = new Image.from_stock(Stock.REFRESH, IconSize.BUTTON);
			rescanBtn.can_focus = false;
			rescanBtn.clicked.connect(() => this.rescan_clicked());
			hbox.pack_start(rescanBtn, false, false, 0);
		}
		HBox hbox;

		void rescan_clicked() {
			debug("rescan clicked");
			rescan();
		}

		class PndSelectionBox : HBox {
			public PndSelectionBox(bool homogeneous, int spacing, Widget mnemonic_widget) {
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
