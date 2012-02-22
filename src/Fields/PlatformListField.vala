using Gee;
using SDL;
using Catapult;
using Data;
using Layers.Controls;
using Layers.Controls.List;
using Menus;
using Menus.Fields;

namespace Fields
{
	public class PlatformListField : ListField<Platform>
	{
		public PlatformListField(string id, string name, string? help=null, Gee.List<Platform> value) {
			base(id, name, help, value);
		}

		protected override ListEditor<Platform> get_list_editor() {
			return new PlatformListEditor(id, name, null, value, p=>p.name);
		}
		
		class PlatformListEditor : ListEditor<Platform>
		{
			public PlatformListEditor(string id, string name, string? help=null, Gee.List<Platform> list, owned MapFunc<string?, Platform> get_name_string) {
				base(id, name, help, list, (owned)get_name_string);
				save_on_return = true;
			}
			protected override bool create_item(Rect selected_item_rect, out Platform item) {
				item = new Platform() {
					name = "",
					platform_type = PlatformType.ROM
				};				
				return true;
			}
			protected override bool edit_list_item(ListItem<Platform> item, uint index) {
				return ObjectMenu.edit("Edit Platform", item.value);
			}
			protected override bool can_delete(ListItem<Platform> item) { return !(item.value is NativePlatform); }
			protected override string? get_cancel_item_text() { return null; }
			protected override string? get_save_item_text() { return "Return"; }
		}
	}
}
