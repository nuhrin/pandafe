using Layers.Controls;
using Data.Pnd;
using Menus.Fields;

namespace Fields
{
	public class PndAppField : MenuItemField
	{
		AppItem? _value;
		public PndAppField(string id, string name, string? help=null, string? app_id=null, string? pnd_id=null) {
			base(id, name, help);
			_value = Data.pnd_data().get_app(app_id, pnd_id);
		}

		public new AppItem? value {
			get { return _value; }
			set { change_value(value); }
		}		
		public string pnd_app_id { get { return (value != null) ? value.id : ""; } }
		public string pnd_id { get { return (value != null) ? value.package_id : ""; } }

		public override string get_value_text() { 
			if (_value == null)
				return "";
			
			return _value.title;
		}
		public override int get_minimum_menu_value_text_length() { return -1; }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((AppItem?)value); }
		protected override bool has_value() { return (_value != null); }

		protected override void activate(Menus.MenuSelector selector) {
			var chooser = new PndAppChooser("app_chooser", "Choose App: " + name);
			AppItem? new_app = chooser.run(_value);
			if (new_app != null && change_value(new_app)) {			
				selector.update_selected_item_value();
				selector.update();
			}
		}
		
		bool change_value(AppItem? new_value) {
			if (new_value == _value) {
				if (new_value.id == pnd_app_id && new_value.package_id == pnd_id)
					return false;
			}
			_value = new_value;
			changed();
			return true;
		}
	}
}
