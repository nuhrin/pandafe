using Gee;
using Layers.Controls;

namespace Menus.Fields
{
	public abstract class ListField<G> : MenuItemField
	{
		Gee.List<G> _value;
		public ListField(string id, string name, string? help=null, Gee.List<G> value) {
			base(id, name, help);
			_value = value;
		}

		public new Gee.List<G> value {
			get { return _value; }
			set { change_value(value); }
		}

		public override string get_value_text() { return "..."; }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((Gee.List<G>)value); }

		protected override void activate(MenuSelector selector) {
			var editor = get_list_editor();
			if (editor.run() == true) {
				change_value(editor.list);
			}			
		}
		
		protected abstract ListEditor<G> get_list_editor();
		
		void change_value(Gee.List<G> new_value) {
			_value = new_value;
			changed();
		}
	}
}
