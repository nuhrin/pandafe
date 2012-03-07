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
				
				var selector = new StringSelector("create_type_selector",
					selected_item_rect.x + (int16)selected_item_rect.w, selected_item_rect.y, 250);
				selector.add_item("Existing");
				selector.add_item("New");
				var selected_index = selector.run();
				if (selector.was_canceled)
					return false;
				
				if (selected_index == 0) {
					item = select_other_existing(selected_item_rect);
					return (item != null);
				}
				
				var new_platform = new Platform() {
					name = "",
					platform_type = PlatformType.ROM
				};
				if (ObjectMenu.edit("New Platform", new_platform) == false)
					return false;					
				item = new PlatformNode(new_platform, folder);				
				return true;
			}
			PlatformNode? select_other_existing(Rect selected_item_rect) {
				var all_platforms = Data.platforms().get_all_platforms();
				var existing_names = (this.items.size == 0) 
					? new ArrayList<string>()
					: new Enumerable<ListItem<PlatformNode>>(this.items).select<string>(i=>i.value.name).to_list();
				var additional_platforms = all_platforms.where(p=>(existing_names.contains(p.name) == false)).to_list();
				if (additional_platforms.size == 0) {
					return null;
				}
				var selector = new ValueSelector<Platform>("platform_node_selector",
					selected_item_rect.x + (int16)selected_item_rect.w, selected_item_rect.y, 250,
					p => p.name, additional_platforms);
				selector.can_select_single_item = true;
				int selected_index = (int)selector.run();
				if (selector.was_canceled)
					return null;
				return new PlatformNode(additional_platforms[selected_index], folder);
				
			}
			protected override bool edit_list_item(ListItem<PlatformNode> item, uint index) {
				return true;
			}
			protected override bool can_edit(ListItem<PlatformNode> item) { return false; }			
		}
	}
}
