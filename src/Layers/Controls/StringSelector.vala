using SDL;
using SDLTTF;
using Gee;

namespace Layers.Controls
{
	public class StringSelector : ValueSelectorBase<string>
	{		
		public StringSelector(string id, int16 xpos, int16 ypos, int16 max_width, Iterable<string>? items=null, uint selected_index=0) {
			base(id, xpos, ypos, max_width, items, selected_index);
		}
		public StringSelector.from_array(string id, int16 xpos, int16 ypos, int16 max_width, string[]? items=null, uint selected_index=0) {
			base.from_array(id, xpos, ypos, max_width, items, selected_index);
		}
		
		protected override string get_item_name(int index) {
			return get_item_at(index);
		}
	}
}
