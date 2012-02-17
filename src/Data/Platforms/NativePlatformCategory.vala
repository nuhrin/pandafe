using Gee;
using Catapult;

namespace Data.Platforms
{
	public class NativePlatformCategory : Object
	{
		construct {
			excluded_subcategories = new ArrayList<string>();
			excluded_apps = new ArrayList<string>();
		}
		public string name { get; set; }

		public Gee.List<string> excluded_subcategories { get; set; }
		public Gee.List<string> excluded_apps { get; set; }
	}
}
