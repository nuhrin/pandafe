using Fields;
using Menus.Fields;
using Data.GameList;
using Data.Programs;

namespace Menus.Concrete
{
	public class SwitchGuiMenu : Menu  
	{	
		const string GUI_CONF_PATH = "/etc/pandora/conf/gui.conf";
		const string NOSWITCH = "NOSWITCH";
		
		public SwitchGuiMenu(string title, string? help=null) {
			base(title, help);
		}
		protected override void populate_items(Gee.List<MenuItem> items) {
			populate_gui_items(items);
			items.add(new MenuItem.cancel_item());			
		}
		void populate_gui_items(Gee.List<MenuItem> items) {
			string? gui_conf_contents = null;
			try {
				FileUtils.get_contents(GUI_CONF_PATH, out gui_conf_contents);
			} catch(FileError e) {
			}
			if (gui_conf_contents == null) {
				this.error("Unable to read " + GUI_CONF_PATH);
				return;
			}
			string[] lines = gui_conf_contents.strip().split("\n");
			foreach(var line in lines) {
				if (line.index_of(NOSWITCH) != -1)
					continue;
				string[] parts = line.split(";");
				if (parts.length == 4) {
					string name = parts[0].strip();
					if (name == "Pandafe")
						continue;
					string desc = parts[1].strip();
					string start_cmd = parts[2].strip();
					string stop_cmd = parts[3].strip();
					if (name == "" || start_cmd == "" || stop_cmd == "")
						continue;
					items.add(new GuiMenuItem(name, desc, start_cmd, stop_cmd, this));
				}
			}
		}
		
		
		public class GuiMenuItem : MenuItem
		{
			const string GUI_LOAD_PATH = "/tmp/gui.load";
			const string GUI_STOPNEW_PATH = "/tmp/gui.stopnew";
			string start_cmd;
			string stop_cmd;
			weak Menu menu;
			public GuiMenuItem(string name, string desc, string start_cmd, string stop_cmd, Menu menu) {
				base(name, desc);
				this.start_cmd = start_cmd;
				this.stop_cmd = stop_cmd;
				this.menu = menu;
			}
			
			public override void activate(MenuSelector selector) { 
				// validate commands before continuing
				if (command_is_valid(start_cmd) == false) {
					menu.error("Invalid start command: " + start_cmd);
					return;
				}
				if (command_is_valid(stop_cmd) == false) {
					menu.error("Invalid stop command: " + start_cmd);
					return;
				}
				
				// execute /usr/pandora/scripts/op_switchgui.sh equivalent
				//
				// echo "$gui" > /tmp/gui.load
				if (write_file(GUI_LOAD_PATH, start_cmd) == false) {
					menu.error("Unable to set " + GUI_LOAD_PATH);
					return;
				}	
				// echo "$stopnew" > /tmp/gui.stopnew			
				if (write_file(GUI_STOPNEW_PATH, stop_cmd) == false) {
					menu.error("Unable to set " + GUI_STOPNEW_PATH);
					return;
				}
				
				// clean up
				@interface.cleanup_and_exit(msg => menu.message(msg));
				Process.exit(0);
			}
			bool write_file(string path, string contents) {
				try {
					return FileUtils.set_contents(path, contents);
				} catch(FileError e) {
				}
				return false;				
			}
			
			bool command_is_valid(string command_line) {
				try {
					string[] argvp;
					if (Shell.parse_argv(command_line, out argvp) == false)
						return false;
					if (argvp == null || argvp.length <= 0 || argvp[0] == null)
						return false;
					return (Environment.find_program_in_path(argvp[0]) != null);
				} catch(Error e) {
					return false;
				}
			} 
		}
	}

}
