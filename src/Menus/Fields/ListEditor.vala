using SDL;
using Gee;
using Layers.Controls.List;

namespace Layers.Controls
{
	public abstract class ListEditor<G> : ListEditorBase<G>
	{
		MapFunc<string, G> get_name_string;
		public ListEditor(string id, string name, Gee.List<G> list, owned MapFunc<string, G> get_name_string) {
			base(id, name, list);
			this.get_name_string = (owned)get_name_string;
		}
		
		protected override ListItem get_list_item(G item) {
			return new GenericListItem<G>(item, (owned)get_name_string);
		}
		
	}
}
