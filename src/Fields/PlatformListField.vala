using Gtk;
using Gee;
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
		DataInterface data_interface;
		public PlatformListField(string id, string name, string? help=null, Gee.List<Platform> value, DataInterface data_interface) {
			base(id, name, help, value);
			this.data_interface = data_interface;			
		}

		protected override ListEditor<Platform> get_list_editor() {
			return new PlatformListEditor(id, name, value, p=>p.name);
		}
		
		class PlatformListEditor : ListEditor<Platform>
		{
			public PlatformListEditor(string id, string name, Gee.List<Platform> list, owned MapFunc<string?, Platform> get_name_string) {
				base(id, name, list, (owned)get_name_string);
			}
			protected override bool create_item(out Platform item) {
				item = new Platform() {
					name = "",
					platform_type = PlatformType.ROM
				};				
				return true;
			}
			protected override bool edit_list_item(ListItem<Platform> item, uint index) {
				new MenuBrowser(new ObjectMenu("Edit Platform", null, item.value), 40, 40).run();
				return false;
			}
			protected override bool can_edit(ListItem<Platform> item) { return !(item.value is NativePlatform); }
			protected override bool can_delete(ListItem<Platform> item) { return !(item.value is NativePlatform); }
		}
	}
}
