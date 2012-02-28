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
	public class PlatformFolderListField : ListField<PlatformFolder>
	{
		PlatformFolder? parent;
		public PlatformFolderListField(string id, string name, string? help=null, PlatformFolder folder) {
			base(id, name, help, folder.folders);
			this.parent = folder;
		}
		public PlatformFolderListField.root(string id, string name, string? help=null, Gee.List<PlatformFolder> folders) {
			base(id, name, help, folders);
		}
		
		protected override ListEditor<PlatformFolder> get_list_editor() {
			return new PlatformFolderListEditor(id, name, help, parent, value, n=>n.name);
		}
		
		class PlatformFolderListEditor : ListEditor<PlatformFolder>
		{
			PlatformFolder? parent;
			public PlatformFolderListEditor(string id, string name, string? help=null, PlatformFolder? parent, Gee.List<PlatformFolder> list, owned MapFunc<string?, PlatformFolder> get_name_string) {
				base(id, name, help, list, (owned)get_name_string);
				this.parent = parent;
			}
			protected override bool create_item(Rect selected_item_rect, out PlatformFolder item) {
				item = (parent == null)
					? new PlatformFolder.root("")
					: new PlatformFolder("", parent);
				return true;
			}
			protected override bool edit_list_item(ListItem<PlatformFolder> item, uint index) {
				return ObjectMenu.edit("Edit Platform Folder", item.value);
			}
			
		}
	}
}
