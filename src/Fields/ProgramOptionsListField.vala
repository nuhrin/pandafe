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
		OptionSet option_set;
		public ProgramOptionsListField(string id, string name, string? help=null, OptionSet value, string? title=null) {
			base(id, name, help, value, title);
			this.option_set = value;
		}

		public OptionSet options() { return (OptionSet)base.get_field_value(); }

		protected override Gee.List<Option> create_new_value_list() { return new OptionSet(); }
		protected override ListEditor<Option> get_list_editor(string? title) {
			return new ProgramOptionsListEditor(id, title ?? name, null, option_set, o=>o.name);
		}
		
		class ProgramOptionsListEditor : ListEditor<Option>
		{
			OptionSet options;
			public ProgramOptionsListEditor(string id, string name, string? help=null,OptionSet options, owned MapFunc<string?, Option> get_name_string) {
				base(id, name, help, options, (owned)get_name_string);
				this.options = options;
			}
			protected override bool create_item(Rect selected_item_rect, out Option item) {
				item = null;
				var selector = new StringSelector.from_array("choose_option_type", 
					selected_item_rect.x + (int16)selected_item_rect.w, selected_item_rect.y, 250,
					OptionType.get_names());
				selector.run();
				if (selector.was_canceled)
					return false;
				Option? option = OptionType.create_option_from_name(selector.selected_item_name(), options);
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
