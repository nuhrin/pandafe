using Layers.Controls;

namespace Menus.Fields
{
	public class FolderField : MenuItemField
	{
		string? _value;
		string? root_path;
		public FolderField(string id, string name, string? help=null, string? path=null, string? root_path=null) {
			base(id, name, help);

			_value = path;
			this.root_path = root_path;
		}

		public new string? value {
			get { return _value; }
			set { change_value(value); }
		}

		public override string get_value_text() { return (_value == null) ? "" : Path.get_basename(_value); }
		public override int get_minimum_menu_value_text_length() { return -1; }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((string?)value); }
		protected override bool has_value() { return (_value != null && _value.strip() != ""); }

		protected override void activate(MenuSelector selector) {
			var chooser = new FolderChooser("folder_chooser", "Choose Folder: " + name, root_path);
			var new_path = chooser.run(_value);
			if (new_path != null && change_value(new_path)) {			
				selector.update_selected_item_value();
				selector.update();
			}
		}
		
		bool change_value(string? new_value) {
			if (new_value == _value)
				return false;
			
			_value = new_value;
			changed();
			return true;
		}
	}
}
