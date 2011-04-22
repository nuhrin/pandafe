using Gtk;

namespace yayafe.Gui.Fields
{
	public abstract class ValueSelectionField : LabeledField
	{
		protected Type value_type;
		public ValueSelectionField(string name, string? label=null, Type value_type)
		{
			base(name, label);
			this.value_type = value_type;
		}

		protected void add_item(string name, Value value) {
			TreeIter iter;
			list_store.append(out iter);
			list_store.set_value(iter, 0, name);
			list_store.set_value(iter, 1, value);
		}
		protected override Value get_field_value() { return get_active_value(); }
		protected override void set_field_value(Value value) { set_active_value(value); }

		protected string? get_active_name() {
			TreeIter iter;
			if (combo_box.get_active_iter(out iter) == false)
				return null;
			Value name;
			list_store.get_value(iter, 0, out name);
			return (string)name;
		}
		protected Value get_active_value() {
			TreeIter iter;
			if (combo_box.get_active_iter(out iter) == false)
				return Value(value_type);
			return get_iter_value(iter);
		}
		Value get_iter_value(TreeIter iter) {
			Value value = Value(value_type);
			list_store.get_value(iter, 1, out value);
			return value;
		}
		protected bool set_active_value(Value value) {
			TreeIter iter;
			if (list_store.get_iter_first(out iter) == false)
				return false;
			int index = 0;
			do
			{
				if (values_are_equal(value, get_iter_value(iter))) {
					combo_box.active = index;
					return true;
				}
				index++;
			}
			while(list_store.iter_next(ref iter));
			return false;
		}
		protected abstract bool values_are_equal(Value a, Value b);

		protected override Widget target_widget { get { return combo_box; } }

		protected ComboBox combo_box {
			get {
				if (_combo_box == null) {
					_combo_box = new ComboBox();
					//_combo_box.set_property("appears-as-list", true);
					_combo_box.changed.connect(() => this.changed());
				}
				return _combo_box;
			}
		}
		ComboBox _combo_box;
		ListStore list_store {
			get {
				if (_list_store == null) {
					_list_store = new ListStore(2, typeof(string), value_type);
					combo_box.set_model(_list_store);
					var cell = new CellRendererText();
					combo_box.pack_start(cell, true);
					combo_box.add_attribute(cell, "text", 0);
				}
				return _list_store;
			}
		}
		ListStore _list_store;
	}
}
