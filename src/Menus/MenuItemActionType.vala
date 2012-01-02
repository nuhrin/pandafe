
namespace Menus
{
	public enum MenuItemActionType
	{
		NONE,
		CANCEL,
		SAVE,
		QUIT,
		SAVE_AND_QUIT;	
		
		public unowned string name() {
			ensure_menu_item_action_names();
			int index = (int)this;
			return menu_item_action_names[index];
		}
		public static MenuItemActionType from_name(string name) {
			ensure_menu_item_action_names();
			for(int index=0;index<menu_item_action_names.length;index++) {
				if (name == menu_item_action_names[index])
					return (MenuItemActionType)index;
			}
			warning("No MenuItemActionType found for action name '%s'.", name);
			return MenuItemActionType.NONE;
		}				
	}
	static string[] menu_item_action_names;
	static void ensure_menu_item_action_names() {
		if (menu_item_action_names != null)
			return;
		menu_item_action_names = {
			"",
			"Cancel",
			"Save",
			"Quit",
			""
		};	
	}
}
