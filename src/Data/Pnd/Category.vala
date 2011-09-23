using Gee;
using Catapult;

namespace Data.Pnd
{
	public class Category : CategoryBase
	{
		ArrayList<SubCategory> _subcategories;
		Gee.List<SubCategory> _subcategories_view;
		public Category(string name) {
			base(name);
			_subcategories = new ArrayList<SubCategory>();
			_subcategories_view = _subcategories.read_only_view;
		}

		public Gee.List<SubCategory> subcategories { get { return _subcategories_view; } }
		public SubCategory? get_subcategory(string subcategory_name) {
			foreach(var sub in _subcategories) {
				if (sub.name == subcategory_name)
					return sub;
			}
			return null;
		}

		internal SubCategory ensure_subcategory(string subcategory_name) {
			SubCategory sub = get_subcategory(subcategory_name);
			if (sub != null)
				return sub;
			sub = new SubCategory(subcategory_name);
			_subcategories.add(sub);
			return sub;
		}
	}

	public class SubCategory : CategoryBase
	{
		public SubCategory(string name) { base(name); }
	}
	public abstract class CategoryBase : Object
	{
		string _name;
		ArrayList<AppItem> _apps;
		Gee.List<AppItem> _apps_view;
		public CategoryBase(string name) {
			_name = name;
			_apps = new ArrayList<AppItem>();
			_apps_view = _apps.read_only_view;
		}

		public unowned string name { get { return _name; } }

		public Gee.List<AppItem> apps { get { return _apps_view; } }

		internal void add_app(AppItem app) {
			_apps.add(app);
		}
	}
}
