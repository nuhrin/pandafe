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
			subcategories_field = new NativePlatformSubCategoryListField("excluded_subcategories", "Excluded SubCategories", 
				"If specified, apps in these subcategories will be excluded.", this);
			builder.add_field(subcategories_field);
			apps_field = new NativePlatformCategoryAppListField("excluded_apps", "Excluded Apps",
				"If specified, these specific apps will be excluded.", this);
			builder.add_field(apps_field);
		}
		
		NativePlatformSubCategoryListField subcategories_field;
		NativePlatformCategoryAppListField apps_field;
	}
}
