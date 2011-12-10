using SDL;
using SDLTTF;
using Gee;

namespace Layers.Controls
{
	public class ValueSelector<G> : ValueSelectorBase<G>
	{		
		MapFunc<string, G> getItemName;
		
		public ValueSelector(string id, int16 xpos, int16 ypos, int16 max_width, owned MapFunc<string, G> getItemName, Iterable<G>? items=null, uint selected_index=0) {
			base(id, xpos, ypos, max_width, items, selected_index);
			this.getItemName = (owned)getItemName;			
		}
		
		protected override string get_item_name(int index) {
			return getItemName(get_item_at(index));
		}
	}
}
