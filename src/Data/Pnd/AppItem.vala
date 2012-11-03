using Catapult;

namespace Data.Pnd
{
	public class AppItem : YamlObject
	{
		weak PndItem pnd;
		public AppItem() { }
		public AppItem.from_app(Pandora.Apps.App app) {
			id = app.id;
			appdata_dirname = app.appdata_dirname;
			title = app.title;
			description = app.description;
			clockspeed = app.clockspeed;
			exec_command = app.exec_command ?? "";
			exec_arguments = app.exec_arguments;
			startdir = app.startdir;
			main_category = app.main_category ?? "";
			subcategory1 = app.main_category1 ?? "";
			subcategory2 = app.main_category2 ?? "";
		}
		public string id { get; set; }
		public string appdata_dirname { get; set; }
		public string title { get; set; }
		public string description { get; set; }
		public uint clockspeed { get; set; }
		public string exec_command { get; set; }
		public string? exec_arguments { get; set; }
		public string? startdir { get; set; }
		public string main_category { get; set; }
		public string subcategory1 { get; set; }
		public string subcategory2 { get; set; }

		public string filename { get { ensure_pnd(); return pnd.filename; } }
		public string package_id { get { ensure_pnd(); return pnd.pnd_id; } }
		public string get_fullpath() {
			ensure_pnd();
			return pnd.get_fullpath();
		}

		internal void set_pnd(PndItem pnd) { this.pnd = pnd; }
		void ensure_pnd() {
			if (pnd == null)
				error("AppItem '%s' has not been associated with a PndItem.", id);
		}
	}
}
