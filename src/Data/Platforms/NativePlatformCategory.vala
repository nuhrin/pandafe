using Gee;
using Catapult;
using Menus;
using Fields;

namespace Data.Platforms
{
	public class NativePlatformCategory : Object, MenuObject
	{
		construct {
			excluded_subcategories = new ArrayList<string>();
			excluded_apps = new ArrayList<string>();
		}
		public string name { get; set; }

		public Gee.List<string> excluded_subcategories { get; set; }
		public Gee.List<string> excluded_apps { get; set; }
		
		// menu
		protected void build_menu(MenuBuilder builder) {
			subcategories_field = new NativePlatformSubCategoryListField("excluded_subcategories", "SubCategories to exclude", null, this);
			builder.add_field(subcategories_field);
		}
		
		NativePlatformSubCategoryListField subcategories_field;
	}
}
