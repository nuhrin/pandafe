using Gee;
using SDL;
using Catapult;
using Data;
using Data.Platforms;
using Layers.Controls;
using Layers.Controls.List;
using Menus;
using Menus.Fields;

namespace Fields
{
	public class PlatformNodeListField : ListField<PlatformNode>
	{
		PlatformFolder folder;
		public PlatformNodeListField(string id, string name, string? help=null, PlatformFolder folder, string? title=null) {
			base(id, name, help, folder.platforms, title);
			this.folder = folder;
		}
		
		protected override ListEditor<PlatformNode> get_list_editor(string? title) {
			return new PlatformNodeListEditor(id, title ?? name, help, folder, value, n=>n.name);
		}
		
		class PlatformNodeListEditor : ListEditor<PlatformNode>
		{
			PlatformFolder folder;
			public PlatformNodeListEditor(string id, string name, string? help=null, PlatformFolder folder, Gee.List<PlatformNode> list, owned MapFunc<string?, PlatformNode> get_name_string) {
				base(id, name, help, list, (owned)get_name_string);
				this.folder = folder;
			}
			protected override bool create_item(Rect selected_item_rect, out PlatformNode item) {
				item = null;
				var all_platforms = Data.platforms().get_all_platforms();
				var existing_names = (this.items.size == 0) 
					? new ArrayList<string>()
					: new Enumerable<ListItem<PlatformNode>>(this.items).select<string>(i=>i.value.name).to_list();
				var additional_platforms = all_platforms.where(p=>(existing_names.contains(p.name) == false)).to_list();
				if (additional_platforms.size == 0) {
					return false;
				}
				var selector = new ValueSelector<Platform>("platform_node_selector",
					selected_item_rect.x + (int16)selected_item_rect.w, selected_item_rect.y, 250,
					p => p.name, additional_platforms);
				selector.can_select_single_item = true;
				int selected_index = (int)selector.run();
				if (selector.was_canceled)
					return false;
				item = new PlatformNode(additional_platforms[selected_index], folder);
				return true;
			}
			protected override bool edit_list_item(ListItem<PlatformNode> item, uint index) {
				return true;
			}
			protected override bool can_edit(ListItem<PlatformNode> item) { return false; }			
		}
	}
}
