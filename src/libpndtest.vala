using Pandora;
namespace yayafe.libpndtest
{
	public void test_search() {
		//print_all_apps();
		print_all_pnds();
	}
	public void print_all_pnds() {
		foreach(var pnd in Apps.get_all_pnds()) {
 			print("%s%s\n", pnd.path, pnd.filename);
			print("  - id: %s\n", pnd.id);
			print("  - package_id: %s\n", pnd.package_id);
			print("  Apps:\n");
			foreach(var app in pnd.apps) {
				print("  * %s [%s]\n", app.title, app.id);
				print("    - path: %s%s\n", app.path, app.filename);
				print("    - description: %s\n", app.description);
				print("    - clockspeed: %d\n", app.clockspeed);
				//print("    - object_type: %d\n", (int)app.info.object_type);
				print("    - object_flags: %d\n", (int)app.flags);
				print("    - subapp_number: %d\n", (int)app.subapp_number);
				print("    - package_id: %s\n", app.package_id);
				print("    - appdata_dirname: %s\n", app.appdata_dirname);
				print("    - icon: %s\n", app.icon);
				print("    - exec: %s\n", app.exec_command);
				print("    - execargs: %s\n", app.exec_arguments);
				print("    - startdir: %s\n", app.startdir);
				print("    - option_no_x11: %d\n", app.exec_option_x11);
				print("    - main_category: %s\n", app.main_category);
				print("    - main_category1: %s\n", app.main_category1);
				print("    - main_category2: %s\n", app.main_category2);
				print("    - alt_category: %s\n", app.alt_category);
				print("    - alt_category1: %s\n", app.alt_category1);
				print("    - alt_category2: %s\n", app.alt_category2);
				print("    - preview_pic1: %s\n", app.preview_pic1);
				print("    - preview_pic2: %s\n", app.preview_pic2);
				print("    - mkdir_sp: %s\n", app.mkdir_sp);
				print("    - info_name: %s\n", app.info_name);
				print("    - info_filename: %s\n", app.info_filename);
				print("    - info_type: %s\n", app.info_type);
			}
			print("\n");
		}
		print("seachpath: %s\n", Pandora.Config.apps_searchpath());
	}

	public void print_all_apps() {
		foreach(var app in Apps.get_all_pnd_apps()) {
				print("  * %s [%s]\n", app.title, app.id);
				print("    - path: %s%s\n", app.path, app.filename);
				print("    - description: %s\n", app.description);
				print("    - clockspeed: %d\n", app.clockspeed);
				print("    - object_flags: %d\n", (int)app.flags);
				print("    - subapp_number: %d\n", (int)app.subapp_number);
				print("    - package_id: %s\n", app.package_id);
				print("    - appdata_dirname: %s\n", app.appdata_dirname);
				print("    - icon: %s\n", app.icon);
				print("    - exec: %s\n", app.exec_command);
				print("    - execargs: %s\n", app.exec_arguments);
				print("    - startdir: %s\n", app.startdir);
				print("    - option_no_x11: %d\n", app.exec_option_x11);
				print("    - main_category: %s\n", app.main_category);
				print("    - main_category1: %s\n", app.main_category1);
				print("    - main_category2: %s\n", app.main_category2);
				print("    - alt_category: %s\n", app.alt_category);
				print("    - alt_category1: %s\n", app.alt_category1);
				print("    - alt_category2: %s\n", app.alt_category2);
				print("    - preview_pic1: %s\n", app.preview_pic1);
				print("    - preview_pic2: %s\n", app.preview_pic2);
				print("    - mkdir_sp: %s\n", app.mkdir_sp);
				print("    - info_name: %s\n", app.info_name);
				print("    - info_filename: %s\n", app.info_filename);
				print("    - info_type: %s\n", app.info_type);
			}
			print("\n");

		print("seachpath: %s\n", Pandora.Config.apps_searchpath());
	}


}
