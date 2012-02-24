using Menus.Fields;

namespace Menus
{
	public interface MenuObject : Object
	{
		protected virtual void build_menu(MenuBuilder builder) {
			builder.add_object_properties(this);
		}
		internal void i_build_menu(MenuBuilder builder) { build_menu(builder); }
		protected bool apply_menu(Menu menu) {
			var fields = menu.fields();
			foreach(var field in fields) {
				if (field.has_changes()) {
					if (apply_changed_field(menu, field) == false)
						this.set_property(field.id, field.value);
				}
			}
			return true;
		}
		internal bool i_apply_menu(Menu menu) { return apply_menu(menu); }
		protected virtual bool apply_changed_field(Menu menu, MenuItemField field) {
			return false;
		}
		
		protected virtual bool save_object(Menu menu) { return true; }
		internal bool i_save_object(Menu menu) { return save_object(menu); }
		
		protected virtual void release_fields() { }
		internal void i_release_fields() { release_fields(); }
	}
}
