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
	public class NativePlatformCategoryListField : ListField<NativePlatformCategory>
	{
		public NativePlatformCategoryListField(string id, string name, string? help=null, Gee.List<NativePlatformCategory> value, string? title=null) {
			base(id, name, help, value, title);
		}
		
		protected override ListEditor<NativePlatformCategory> get_list_editor(string? title) {
			return new NativePlatformCategoryListEditor(id, title ?? name, help, value, c=>c.name);
		}
		
		class NativePlatformCategoryListEditor : ListEditor<NativePlatformCategory>
		{
			public NativePlatformCategoryListEditor(string id, string name, string? help=null, Gee.List<NativePlatformCategory> list, owned MapFunc<string?, NativePlatformCategory> get_name_string) {
				base(id, name, help, list, (owned)get_name_string);
			}
			protected override bool create_item(Rect selected_item_rect, out NativePlatformCategory item) {
				item = null;
				var all_category_names = Data.pnd_data().get_main_category_names();
				var existing_names = (this.items.size == 0) 
					? new ArrayList<string>()
					: new Enumerable<ListItem<NativePlatformCategory>>(this.items).select<string>(i=>i.value.name).to_list();
				var additional_names = all_category_names.where(name=>(existing_names.contains(name) == false)).to_list();				
				if (additional_names.size < 2) {
					if (additional_names.size == 1) {
						item = new NativePlatformCategory() {
							name = additional_names[0]
						};
						return true;
					}
					return false;
				}
				var selector = new StringSelector("native_category_selector", 
					selected_item_rect.x + (int16)selected_item_rect.w, selected_item_rect.y, 250, additional_names);
				selector.run();
				if (selector.was_canceled)
					return false;
				item = new NativePlatformCategory() {
					name = selector.selected_item_name()
				};
				return true;
			}
			protected override bool edit_list_item(ListItem<NativePlatformCategory> item, uint index) {
				return ObjectMenu.edit("Edit Native Platform Category: " + item.value.name, item.value);
			}
			
		}
	}
}
