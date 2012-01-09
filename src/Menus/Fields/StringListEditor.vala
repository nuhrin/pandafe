using SDL;
using Gee;
using Layers.Controls.List;

namespace Layers.Controls
{
	public class StringListEditor : ListEditorBase<string>
	{
		public StringListEditor(string id, string name, Gee.List<string> list) {
			base(id, name, list);
		}
		
		protected override ListItem get_list_item(string item) {
			return new StringListItem(item);
		}
		
	}
}
