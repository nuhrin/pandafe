using Gee;
using Catapult;
using Fields;
using Menus;
using Menus.Fields;

namespace Data.Platforms
{
	public class PlatformFolder : Object, PlatformListNode, MenuObject
	{
		PlatformFolder? _parent;		
		public PlatformFolder(string name, PlatformFolder parent) {
			this.name = name;
			_parent = parent;
			init();
		}
		public PlatformFolder.root(string name) {
			this.name = name;
			init();
		}		
		void init() {
			folders = new ArrayList<PlatformFolder>();
			platforms = new ArrayList<PlatformNode>();
		}
		
		public string name { get; set; }
		public PlatformFolder? parent { get { return _parent; } }

		public Gee.List<PlatformFolder> folders { get; set; }
		public Gee.List<PlatformNode> platforms { get; set; }
				
		public Enumerable<Platform> get_all_platforms() {
			return Data.platforms().get_platform_folder_data().get_all_platforms(this);
		}
		
		public int index_of_platform(Platform platform) {
			int found_platform_index = -1;
			for(int index=0;index<platforms.size;index++) {
				if (platforms[index].platform == platform) {
					found_platform_index = index;
					break;
				}
			}
			return found_platform_index;
		}
		
		public GameBrowserAppearance? appearance { get; set; }		
		GameBrowserAppearance get_fallback_appearance() {
			PlatformFolder? source = _parent;
			GameBrowserAppearance? fallback = null;
			while (source != null && fallback == null) {
				fallback = source.appearance;
				source = source.parent;
			}
			if (fallback == null)
				fallback = Data.preferences().appearance;
			return fallback;
		}
		
		// menus
		protected void build_menu(MenuBuilder builder) {
			var name_field = builder.add_string("name", "Name", null, this.name);
			name_field.required = true;

			platforms_field = new PlatformNodeListField("platforms", "Platforms", null, this);
			builder.add_field(platforms_field);
			
			var appearance_field = new GameBrowserAppearanceField("appearance", "Appearance", null, name + " Appearance", appearance, get_fallback_appearance());
			builder.add_field(appearance_field);

			folders_field = new PlatformFolderListField("folders", "Subfolders", null, this);
			builder.add_field(folders_field);			
		}
		protected bool validate_menu(Menus.Menu menu) {
			if (folders_field.value.size == 0 && platforms_field.value.size == 0) {
				menu.error("At least on child folder or platform is required.");
				return false;
			}
			return true;
		}
		protected void release_fields() {
			folders_field = null;
			platforms_field = null;
		}
		PlatformFolderListField folders_field;
		PlatformNodeListField platforms_field;		
	}
}
