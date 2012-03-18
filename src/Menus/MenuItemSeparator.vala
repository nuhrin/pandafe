using SDL;

namespace Menus
{
	public class MenuItemSeparator : MenuItem
	{
		public MenuItemSeparator() {
			base("");
		}
		
		public override void activate(MenuSelector selector) {}
		
		protected override bool is_initially_enabled() { return false; }
		protected override bool can_change_enabled_state() { return false; }
	}
}
