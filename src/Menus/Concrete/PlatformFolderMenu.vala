using Data.Platforms;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class PlatformFolderMenu : Menu  
	{	
		PlatformFolder platform_folder;
		public PlatformFolderMenu(PlatformFolder platform_folder, string? help=null, string? name=null) {
			base("%s: %s".printf(name ?? "Folder", platform_folder.name), help);
			title = "Platform Folder: " + platform_folder.name;
			this.platform_folder = platform_folder;
			ensure_items();		
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Edit", "Edit the platform folder", null, () => {
				if (ObjectMenu.edit("Edit Platform Folder", platform_folder) == true) {
					string? error;
					if (Data.platforms().save_platform_folder_data(out error) == false) {
						this.error(error);
					} else {
						title = "Platform Folder: " + platform_folder.name;
						refresh(0);
						saved();
					}					
				}
			}));
			if (platform_folder.parent != null) {
				items.add(new MenuItemSeparator());
				
				var parent_folder_menu = new PlatformFolderMenu(platform_folder.parent, "Show a menu for the parent of this platform folder", "Parent");
				var parent_folder_item_index = items.size;
				parent_folder_menu.saved.connect(() => refresh(parent_folder_item_index));
				items.add(parent_folder_menu);
			}
		}						
	}

}
