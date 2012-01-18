
namespace Layers.Controls.List
{
	public class ListItemActionSelector : StringSelector
	{		
		public ListItemActionSelector(string id, int16 xpos, int16 ypos, bool can_edit=true, bool can_delete=true) {
			base.from_array(id, xpos, ypos, 200);
			if (can_edit)
				add_action(ListItemActionType.EDIT);
			add_action(ListItemActionType.INSERT_ABOVE);
			add_action(ListItemActionType.INSERT_BELOW);
			if (can_delete)
				add_action(ListItemActionType.DELETE);
			add_action(ListItemActionType.MOVE);
		}
		
		public new ListItemActionType run(uchar screen_alpha=128, uint32 rgb_color=0) {
			base.run(screen_alpha, rgb_color);
			if (was_canceled)
				return ListItemActionType.NONE;
			return ListItemActionType.from_name(base.selected_item());
		}
		
		public void add_action(ListItemActionType action) {
			add_item(action.name());
		}
	}
}
