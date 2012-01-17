using Layers.Controls;

namespace Menus.Fields
{
	public class PndCategoryField : MenuItemField
	{
		string? _value;
		public PndCategoryField(string id, string name, string? help=null, string? path=null) {
			base(id, name, help);
			_value = path;
		}

		public new string? value {
			get { return _value; }
			set { change_value(value); }
		}
		public Data.Pnd.CategoryBase? category() { return Data.pnd_data().get_category_from_path(_value ?? ""); }

		public override string get_value_text() { return (_value == null) ? "" : Path.get_basename(_value); }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((string?)value); }

		protected override void activate(MenuSelector selector) {
			var chooser = new PndCategoryChooser("category_chooser", "Choose Category: " + name);
			var new_path = chooser.run(_value ?? "");
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
