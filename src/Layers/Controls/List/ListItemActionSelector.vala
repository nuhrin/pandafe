
namespace Layers.Controls.List
{
	public class ListItemActionSelector : StringSelector
	{		
		public ListItemActionSelector(string id, int16 xpos, int16 ypos) {
			base.from_array(id, xpos, ypos, 200, ListItemActionType.names());
		}
		
		public new ListItemActionType run(uchar screen_alpha=128, uint32 rgb_color=0) {
			var result = base.run(screen_alpha, rgb_color);
			if (was_canceled)
				return ListItemActionType.NONE;
			return (ListItemActionType)((int)result+1);
		}
	}
}
