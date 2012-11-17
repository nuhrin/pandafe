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
	public class PlatformListField : ListField<Platform>
	{
		public PlatformListField(string id, string name, string? help=null, Gee.List<Platform> value, string? title=null) {
			base(id, name, help, value, title);
		}

		protected override ListEditor<Platform> get_list_editor(string? title) {
			return new PlatformListEditor(id, title ?? name, null, value, p=>p.name);
		}
		
		class PlatformListEditor : ListEditor<Platform>
		{
			public PlatformListEditor(string id, string title, string? help=null, Gee.List<Platform> list, owned MapFunc<string?, Platform> get_name_string) {
				base(id, title, help, list, (owned)get_name_string);
				save_on_return = true;
			}
			protected override bool create_item(Rect selected_item_rect, out Platform item) {
				item = null;
				var selector = new StringSelector.from_array("choose_platform_type", 
					selected_item_rect.x + (int16)selected_item_rect.w, selected_item_rect.y, 250);
				selector.add_item("Rom Based");
				selector.add_item("Program Based");
				var selected_index = selector.run();
				if (selector.was_canceled)
					return false;				
				
				if (selected_index == 0)
					item = new RomPlatform();
				else
					item = new ProgramPlatform();
				item.name = "";
				
				return true;
			}
			protected override bool edit_list_item(ListItem<Platform> item, uint index) {
				string type = (item.value.platform_type == PlatformType.ROM) ? "Rom" : "Program";
				return ObjectMenu.edit("Edit %s Platform".printf(type), item.value);
			}
			protected override bool confirm_deletion() { return true; }
			protected override bool on_delete(ListItem<Platform> item) {
				string? error;
				if (Data.platforms().remove_platform(item.value, out error) == true)
					return true;
				warning(error);				
				return false;
			}
			protected override bool can_delete(ListItem<Platform> item) { return !(item.value is NativePlatform); }
			protected override string? get_cancel_item_text() { return null; }
			protected override string? get_save_item_text() { return "Return"; }
		}
	}
}
