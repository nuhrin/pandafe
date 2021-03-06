/* MainMenu.vala
 * 
 * Copyright (C) 2012 nuhrin
 * 
 * This file is part of Pandafe.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *      nuhrin <nuhrin@oceanic.to>
 */

using Gee;
using Catapult;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class MainMenu : Menu
	{
		public MainMenu() {
			base("Pandafe " + Build.BUILD_VERSION);
		}
		protected override void populate_items(Gee.List<MenuItem> items) {
			items.add(new MenuBrowserItem("Config", "Show configuration menu", new ConfigurationMenu()));
			items.add(new MenuBrowserItem("Data", "Show data management menu", new DataMenu()));
			items.add(new MenuItem.custom("Scan PNDs", "Scan system for new pnd apps, and rescan native platform", "Scanning PNDs...", () => {
				Data.rescan_pnd_data();
				Data.platforms().get_native_platform().rebuild(f=> this.message("Scanning folder '%s'...".printf(f.unique_name())));
				refresh(2);
			}));
			
			items.add(new MenuItemSeparator());
			if (MainClass.was_run_as_gui == true) {
				items.add(new MenuBrowserItem("Quit", "Exit Pandafe", new ExitMenu()));
			} else {
				items.add(new MenuItem.custom("Quit", "Exit Pandafe", "", () => {
					@interface.cleanup_and_exit(msg => this.message(msg));
				}));
			}
		}
	}
	class ConfigurationMenu : Menu
	{		
		public ConfigurationMenu() { 
			base("Pandafe Configuration");
		}

		protected override void populate_items(Gee.List<MenuItem> items) { 			
			items.add(ObjectMenu.get_browser_item("Preferences", "Pandafe Preferences", "Edit preferences", Data.preferences()));
			var platform_folders_field = new PlatformFolderListField.root("folders", "Platforms", "Edit platform folders", Data.platforms().get_platform_folder_data().folders);
			var platform_folders_item_index = items.size;
			field_connect(platform_folders_field, (f)=> f.changed.connect(() => {
				string? error;
				Data.platforms().get_platform_folder_data().folders = platform_folders_field.value;
				if (Data.platforms().save_platform_folder_data(out error) == true)
					refresh(platform_folders_item_index);
				else
					this.error(error);
			}));
			items.add(platform_folders_field);
			
			if (MainClass.was_run_as_gui)
				return;
			
			items.add(new MenuItemSeparator());			
			if (is_pandafe_gui_installed == false) {
				items.add(new MenuItem.custom("Install Gui", "Install Pandafe for SwitchGui", "", () => {
					install_pandafe_gui();
				}));
			} else {
				items.add(new MenuItem.custom("Uninstall Gui", "Uninstall Pandafe for SwitchGui", "", () => {
					uninstall_pandafe_gui();
				}));
			}			
		}
		static bool is_pandafe_gui_installed {
			get {
				if (_is_pandafe_gui_installed == null)
					_is_pandafe_gui_installed = GuiInstaller.is_pandafe_gui_installed();
				return _is_pandafe_gui_installed;
			}
		}
		static bool? _is_pandafe_gui_installed;
		void install_pandafe_gui() {
			var app = Data.pnd_data().get_app(Build.PND_APP_ID);
			if (app == null) {
				this.error("Unable to determine Pandafe pnd path. Run Scan PNDs?");
				return;
			}
			var result = GuiInstaller.install_pandafe_gui(app.get_fullpath());
			if (result.success == false) {
				result.show_result_dialog("Error installing Pandafe for SwitchGui");
				return;
			}
			
			_is_pandafe_gui_installed = true;
			refresh(3);
		}
		void uninstall_pandafe_gui() {
			var result = GuiInstaller.uninstall_pandafe_gui();
			if (result.success == false) {
				result.show_result_dialog("Error uninstalling Pandafe for SwitchGui");
			}
			
			_is_pandafe_gui_installed = false;
			refresh(3);
		}
	}
	class DataMenu : Menu
	{
		public DataMenu() { 
			base("Pandafe Data Management");
		}
				
		protected override void populate_items(Gee.List<MenuItem> items) { 
			var platforms_field = new PlatformListField("platforms", "Platforms", "Add/Edit/Delete platform definitions", Data.platforms().get_all_platforms().to_list(), "Platforms Data");
			items.add(platforms_field);
			var programs_field = new ProgramDataListField("programs", "Programs", "Add/Edit/Delete program definitions", Data.programs().get_all_programs().to_list(), "Programs Data");
			items.add(programs_field);
			var gamesettings_field = new GameSettingsListField("settings", "Game Settings", "Edit/Delete all game settings", "Game Settings Data");
			items.add(gamesettings_field);
		}
	}
}
