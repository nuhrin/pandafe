using Gee;
using Layers.Controls;

namespace Menus.Fields
{
	public abstract class ListField<G> : MenuItemField
	{
		Gee.List<G> _value;
		string? title;
		public ListField(string id, string name, string? help=null, Gee.List<G> value, string? title=null) {
			base(id, name, help);
			_value = create_new_value_list();
			_value.add_all(value);
			this.title = title;
		}

		public new Gee.List<G> value {
			get { return _value; }
			set { change_value(value); }
		}

		public override string get_value_text() { return ""; }
		public override int get_minimum_menu_value_text_length() { return 0; }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((Gee.List<G>)value); }
		protected override bool has_value() { return (_value.size > 0); }

		protected override void activate(MenuSelector selector) {
			var editor = get_list_editor(title);
			if (editor.run() == true) {
				change_value(editor.list);
			}			
		}
		
		protected virtual Gee.List<G> create_new_value_list() { return new ArrayList<G>(); }
		protected abstract ListEditor<G> get_list_editor(string? title);
		
		void change_value(Gee.List<G> new_value) {
			_value = new_value;
			changed();
		}
		
		public override bool is_menu_item() { return true; }
	}
}
