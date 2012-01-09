
namespace Layers.Controls.List
{
	public enum ListItemActionType
	{
		NONE,
		EDIT,
		MOVE,
		INSERT_ABOVE,
		INSERT_BELOW,
		DELETE;
		
		public static string[] names() {
			ensure_list_item_action_names();			
			return list_item_action_names;
		}
		
	}
	static string[] list_item_action_names;
	static void ensure_list_item_action_names() {
		if (list_item_action_names != null)
			return;
		list_item_action_names = {
			"Edit",
			"Move",
			"Insert Above",
			"Insert Below",
			"Delete"
		};	
	}
}
