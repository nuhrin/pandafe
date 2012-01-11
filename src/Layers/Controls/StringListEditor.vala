using SDL;
using Gee;
using Layers.Controls.List;

namespace Layers.Controls
{
	public class StringListEditor : ListEditorBase<string>
	{
		string? character_mask_regex;
		string? value_mask_regex;
		
		public StringListEditor(string id, string name, Gee.List<string> list, string? character_mask_regex=null, string? value_mask_regex=null) {
			base(id, name, list);
			this.character_mask_regex = character_mask_regex;
			this.value_mask_regex = value_mask_regex;
		}
		
		protected override ListItem<string> get_list_item(string item) {
			return new StringListItem(item);
		}
		protected override string create_item() { return ""; }
		protected override bool edit_list_item(ListItem<string> item, uint index) {
			Rect rect = get_selected_item_rect();
			var entry = new TextEntry("%s_item_%u".printf(id, index), rect.x - 4, rect.y, 300, item.value, character_mask_regex, value_mask_regex);			
			string? edited = entry.run();
			if (edited != item.value) {
				item.value = edited ?? "";
				return true;
			}
			
			return false;
		}
		
	}
}