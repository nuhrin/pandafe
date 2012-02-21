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
		public NativePlatformSubCategoryListField(string id, string name, string? help=null, NativePlatformCategory category) {
			base(id, name, help, category.excluded_subcategories);
			this.category = category;
		}
		
		protected override StringListEditor get_list_editor() {
			return new NativePlatformSubCategoryListEditor(id, name, category, value);
		}
		
		class NativePlatformSubCategoryListEditor : StringListEditor
		{
			NativePlatformCategory category;
			public NativePlatformSubCategoryListEditor(string id, string name, NativePlatformCategory category, Gee.List<string> list) {
				base(id, name, list);
				this.category = category;
			}
			protected override bool create_item(Rect selected_item_rect, out string item) {
				item = "";
				var main_cat = Data.pnd_data().get_category(category.name);
				if (main_cat == null)
					return false;
				var all_subcategory_names = new Enumerable<CategoryBase>(main_cat.subcategories).select<string>(c=>c.name);
				var additional_names = all_subcategory_names.where(name=>(list.contains(name) == false));
				var selector = new StringSelector("native_subcategory_selector", 
					selected_item_rect.x + (int16)selected_item_rect.w, selected_item_rect.y, 250, additional_names);
				selector.run();
				if (selector.was_canceled)
					return false;
				item = selector.selected_item_name();
				return true;
			}
			protected override bool can_edit(ListItem<string> item) { return false; }			
		}
	}
}
