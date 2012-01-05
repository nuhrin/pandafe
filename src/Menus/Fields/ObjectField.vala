using Gee;
using SDL;
using Catapult;
using Layers.Controls;
using Layers.MenuBrowser;

namespace Menus.Fields
{
	public class ObjectField : MenuItemField
	{
		Object obj;
		Type type;
		
		public ObjectField(string id, string name, string? help=null, Object obj) {
			base(id, name, help);
			this.obj = obj;
			type = obj.get_type();
		}

		public new Object value {
			get { return obj; }
			set { change_value(value); }
		}
		

		public override string get_value_text() { return "..."; }
		
		protected override Value get_field_value() { return obj; }
		protected override void set_field_value(Value value) { change_value(value.get_object()); }

		protected override void activate(MenuSelector selector) {
			new MenuBrowser(new ObjectMenu(name, null, obj), 40, 40).run();
		}

		void change_value(Object obj) {
			if (obj != this.obj) {
				this.obj = obj;
				changed();
			}
		}
		
	}
}
