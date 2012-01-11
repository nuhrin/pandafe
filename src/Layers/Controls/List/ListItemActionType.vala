
namespace Layers.Controls.List
{
	public enum ListItemActionType
	{
		NONE,
		EDIT,
		INSERT_ABOVE,
		INSERT_BELOW,
		DELETE,
		MOVE;
		
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
			"Insert Above",
			"Insert Below",
			"Delete",
			"Move"
		};	
	}
}
