using Gee;
using SDL;
using Catapult;
using Data;
using Layers.Controls;
using Layers.Controls.List;
using Menus;
using Menus.Fields;
using Data.Options;

namespace Fields
{
	public class ProgramOptionsListField : ListField<Option>
	{
		public ProgramOptionsListField(string id, string name, string? help=null, OptionSet value) {
			base(id, name, help, value);
		}

		public OptionSet options() { return (OptionSet)base.get_field_value(); }

		protected override ListEditor<Option> get_list_editor() {
			return new ProgramOptionsListEditor(id, name, null, value, o=>o.name);
		}
		
		class ProgramOptionsListEditor : ListEditor<Option>
		{
			public ProgramOptionsListEditor(string id, string name, string? help=null, Gee.List<Option> list, owned MapFunc<string?, Option> get_name_string) {
				base(id, name, help, list, (owned)get_name_string);
			}
			protected override bool create_item(Rect selected_item_rect, out Option item) {
				item = null;
				var selector = new StringSelector.from_array("choose_option_type", 
					selected_item_rect.x + (int16)selected_item_rect.w, selected_item_rect.y, 250,
					OptionType.get_names());
				selector.run();
				if (selector.was_canceled)
					return false;
				Option? option = OptionType.create_option_from_name(selector.selected_item_name());
				if (option != null) {
					item = option;
					return true;
				}
				
				return false;
			}
			protected override bool edit_list_item(ListItem<Option> item, uint index) {
				var name = item.value.option_type.name();
				string title = (name != "") ? "Edit %s Option".printf(name) : "Edit Option";
				return ObjectMenu.edit(title, item.value);				
			}
		}
	}
}
