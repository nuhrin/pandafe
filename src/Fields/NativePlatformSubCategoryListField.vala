using Gee;
using SDL;
using Catapult;
using Data;
using Data.Platforms;
using Data.Pnd;
using Layers.Controls;
using Layers.Controls.List;
using Menus;
using Menus.Fields;

namespace Fields
{
	public class NativePlatformSubCategoryListField : StringListField
	{
		NativePlatformCategory category;
		Category? main_category;
		public NativePlatformSubCategoryListField(string id, string name, string? help=null, NativePlatformCategory category) {
			base(id, name, help, category.excluded_subcategories);
			this.category = category;
			main_category = Data.pnd_data().get_category(category.name);
		}
		
		protected override void activate(MenuSelector selector) {
			if (main_category == null || main_category.subcategories.size == 0) {
				message("No subcategories found for category " + category.name);
				return;
			}
			base.activate(selector);
		}
		protected override StringListEditor get_list_editor() {
			return new NativePlatformSubCategoryListEditor(id, name, help, main_category, value);
		}
		
		class NativePlatformSubCategoryListEditor : StringListEditor
		{
			Category? category;
			public NativePlatformSubCategoryListEditor(string id, string name, string? help=null, Category? category, Gee.List<string> list) {
				base(id, name, help, list);
				this.category = category;
			}
			protected override bool create_item(Rect selected_item_rect, out string item) {
				item = "";
				if (category == null)
					return false;
				var all_subcategory_names = new Enumerable<CategoryBase>(category.subcategories).select<string>(c=>c.name);
				var existing_names = (this.items.size == 0) 
					? new ArrayList<string>()
					: new Enumerable<ListItem<string>>(this.items).select<string>(i=>i.value).to_list();
				var additional_names = all_subcategory_names.where(name=>(existing_names.contains(name) == false)).to_list();
				if (additional_names.size == 0) {
					return false;
				}
				var selector = new StringSelector("native_subcategory_selector", 
					selected_item_rect.x + (int16)selected_item_rect.w, selected_item_rect.y, 250, additional_names);
				selector.can_select_single_item = true;
				selector.run();
				if (selector.was_canceled)
					return false;
				item = selector.selected_item_name();
				return true;
			}
			protected override bool edit_list_item(ListItem<string> item, uint index) {
				return true;
			}
			protected override bool can_edit(ListItem<string> item) { return false; }
			protected override bool can_insert() { return (category != null && items.size < category.subcategories.size); }			
		}
	}
}
