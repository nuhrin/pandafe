namespace Menus
{
	public interface MenuObject : Object
	{
		protected virtual void build_menu(MenuBuilder builder) {
			builder.add_object_properties(this);
		}
		internal void i_build_menu(MenuBuilder builder) { build_menu(builder); }
		protected virtual bool apply_menu(Menu menu) {
			var fields = menu.fields();
			foreach(var field in fields) {
				if (field.has_changes()) {
					this.set_property(field.id, field.value);
				}
			}
			return true;
		}
		internal bool i_apply_menu(Menu menu) { return apply_menu(menu); }
		
		protected virtual bool save_object(Menu menu) { return true; }
		internal bool i_save_object(Menu menu) { return save_object(menu); }
	}
}
