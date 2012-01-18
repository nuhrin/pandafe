
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
		
		public unowned string name() {
			ensure_list_item_action_names();
			int index = (int)this;
			return list_item_action_names[index];
		}
		public static ListItemActionType from_name(string name) {
			ensure_list_item_action_names();
			for(int index=0;index<list_item_action_names.length;index++) {
				if (name == list_item_action_names[index])
					return (ListItemActionType)index;
			}
			warning("No ListItemActionType found for action name '%s'.", name);
			return ListItemActionType.NONE;
		}				
		
	}
	static string[] list_item_action_names;
	static void ensure_list_item_action_names() {
		if (list_item_action_names != null)
			return;
		list_item_action_names = {
			"",
			"Edit",
			"Insert Above",
			"Insert Below",
			"Delete",
			"Move"
		};	
	}
}
