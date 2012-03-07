using Data.Platforms;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class PlatformFolderMenu : Menu  
	{	
		PlatformFolder platform_folder;
		PlatformFolder? parent_folder;
		public PlatformFolderMenu(PlatformFolder platform_folder, PlatformFolder? parent=null, string? name=null) {
			base("%s: %s".printf(name ?? "Folder", platform_folder.name));
			title = "Platform Folder: " + platform_folder.name;
			this.platform_folder = platform_folder;
			this.parent_folder = parent;
			ensure_items();		
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Edit", null, null, () => {
				if (ObjectMenu.edit("Edit Platform Folder", platform_folder) == true) {
					string? error;
					if (Data.platforms().save_platform_folder_data(out error) == false) {
						this.error(error);
					} else {
						refresh(0);
						saved();
					}					
				}
			}));
			if (parent_folder != null) {
				var parent_folder_menu = new PlatformFolderMenu(parent_folder, null, "Parent");
				var parent_folder_item_index = items.size;
				parent_folder_menu.saved.connect(() => refresh(parent_folder_item_index));
				items.add(parent_folder_menu);
			}
		}						
	}

}
