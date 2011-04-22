using Gtk;
using yayafe.Gui.Widgets;

namespace yayafe.Gui.Fields
{
	public abstract class ValueMultipleSelectionField : LabeledField
	{
		protected Type value_type;
		CheckListCombo combo;
		public ValueMultipleSelectionField(string name, string? label=null, Type value_type)
		{
			base(name, label);
			this.value_type = value_type;
			combo = new CheckListCombo(value_type);
		}

		protected void add_item(string name, Value value, bool active=false) {
			combo.add_item(name, value, active);
		}
		protected override Value get_field_value() { return Value(value_type); }
		protected override void set_field_value(Value value) {  }

		//protected abstract bool values_are_equal(Value a, Value b);

		protected override Widget target_widget { get { return combo; } }

		class CheckListCombo : ComboButton {
			protected Type value_type;
			public CheckListCombo(Type value_type) {
				base();
				this.value_type = value_type;
			}

			public void add_item(string name, Value value, bool active=false)
			{
				TreeIter iter;
				list_store.append(out iter);
				list_store.set_value(iter, 0, active);
				list_store.set_value(iter, 1, name);
				list_store.set_value(iter, 2, value);
			}

			protected override Widget get_popup_widget() { return tree_view; }
			//protected override Value get_popup_widget_value() { return entry.text; }
			//protected override void set_popup_widget_value(Value value) { entry.text = (string)value; }

			TreeView tree_view {
				get {
					if (_tree_view == null) {
						_tree_view = new TreeView();
				        _tree_view.set_headers_visible(false);
				  		_tree_view.hover_selection = true;
				  		_tree_view.get_selection().set_mode(SelectionMode.MULTIPLE);

				        _tree_view.set_model(list_store);

				        var column = new TreeViewColumn ();
						var toggle = new CellRendererToggle ();
				        toggle.toggled.connect ((toggle, path) => {
				            var tree_path = new TreePath.from_string (path);
				            TreeIter iter;
				            list_store.get_iter(out iter, tree_path);
				            list_store.set(iter, 0, !toggle.active);
				        });
				        column.pack_start (toggle, false);
				        column.add_attribute (toggle, "active", 0);

						var text = new CellRendererText ();
				        column.pack_start (text, true);
				        column.add_attribute (text, "text", 1);

				        _tree_view.append_column (column);
					}
					return _tree_view;
				}
			}
			TreeView _tree_view;

			ListStore list_store {
				get {
					if (_list_store == null) {
						_list_store = new ListStore(3, typeof(bool), typeof(string), value_type);
					}
					return _list_store;
				}
			}
			ListStore _list_store;
		}
	}
}

