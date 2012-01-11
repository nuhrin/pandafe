using Gee;
using Layers.Controls;

namespace Menus.Fields
{
	public class StringListField : MenuItemField
	{
		Gee.List<string> _value;
		string? character_mask_regex;
		string? value_mask_regex;
		public StringListField(string id, string name, string? help=null, Gee.List<string> value, string? character_mask_regex=null, string? value_mask_regex=null) {
			base(id, name, help);
			_value = value;
			this.character_mask_regex = character_mask_regex;
			this.value_mask_regex = value_mask_regex;
		}

		public new Gee.List<string> value {
			get { return _value; }
			set { change_value(value); }
		}

		public override string get_value_text() { return "..."; }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((Gee.List<string>)value); }

		protected override void activate(MenuSelector selector) {
			var editor = new StringListEditor(id + "_editor", name, _value);
			if (editor.run() == true) {
				change_value(editor.list);
			}			
		}
		
		void change_value(Gee.List<string> new_value) {
			_value = new_value;
			changed();
		}
	}
}