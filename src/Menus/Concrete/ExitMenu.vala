/* ExitMenu.vala
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

using Fields;
using Menus.Fields;
using Data.GameList;
using Data.Programs;

namespace Menus.Concrete
{
	public class ExitMenu : Menu  
	{	
		public ExitMenu() {
			base("Exit", "");
			ensure_items();		
		}
		protected override void populate_items(Gee.List<MenuItem> items) {
			items.add(new SwitchGuiMenu("Switch Gui", "Switch to another gui"));
			items.add(new MenuItem.custom("Reboot", "Reboot system now", "Rebooting...", () => {
				do_quit();
				do_shutdown(true);
			}));
			items.add(new MenuItem.custom("Shutdown", "Shutdown system now", "Shutting down...", () => {
				do_quit();
				do_shutdown(false);
			}));
			items.add(new MenuItem.custom("Logout", "Exit Pandafe", "", () => {
				do_quit();
			}));
		}
		void do_quit() {
			@interface.cleanup_and_exit(msg => this.message(msg));
		}
		void do_shutdown(bool reboot) {
			string cmd = (reboot == false)
				? "sudo /sbin/shutdown -h now"
				: "sudo /sbin/reboot";
			try {
				Process.spawn_command_line_async(cmd);
			} catch(SpawnError e) {
				this.error("%s error: %s".printf((reboot == true) ? "Reboot" : "Shutdown", e.message));
				return;
			}
		}
	}
}
