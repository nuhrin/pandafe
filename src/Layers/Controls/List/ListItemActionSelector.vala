
namespace Layers.Controls.List
{
	public class ListItemActionSelector : StringSelector
	{		
		public ListItemActionSelector(string id, int16 xpos, int16 ypos, bool can_edit=true, bool can_delete=true, bool can_move=true, bool can_insert=true) {
			base.from_array(id, xpos, ypos, 200);
			can_select_single_item = true;
			if (can_edit)
				add_action(ListItemActionType.EDIT);
			if (can_insert) {
				add_action(ListItemActionType.INSERT_ABOVE);
				add_action(ListItemActionType.INSERT_BELOW);
			}
			if (can_delete)
				add_action(ListItemActionType.DELETE);
			if (can_move)
				add_action(ListItemActionType.MOVE);
		}
		
		public new ListItemActionType run(uchar screen_alpha=128, uint32 rgb_color=0) {
			if (item_count == 0)
				return ListItemActionType.NONE;
				
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
