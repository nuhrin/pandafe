namespace Menus
{
	public interface MenuObject : Object
	{
		protected virtual void build_menu(MenuBuilder builder) {
			builder.add_object_properties(this);
		}
		internal void i_build_menu(MenuBuilder builder) { build_menu(builder); }
		protected abstract bool apply_menu(Menu menu);
		internal bool i_apply_menu(Menu menu) { return apply_menu(menu); }
		
	}
}
