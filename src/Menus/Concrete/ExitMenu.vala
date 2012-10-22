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
			items.add(new MenuItem.custom("Quit", "Exit Pandafe", "", () => {
				do_quit();
			}));
			items.add(new SwitchGuiMenu("Switch Gui", "Switch to another gui"));
			items.add(new MenuItem.custom("Reboot", "Reboot system now", "Rebooting...", () => {
				do_quit();
				do_shutdown(true);
			}));
			items.add(new MenuItem.custom("Shutdown", "Shutdown system now", "Shutting down...", () => {
				do_quit();
				do_shutdown(false);
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
