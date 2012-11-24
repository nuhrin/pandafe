using Data.Programs;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class ProgramMenu : Menu  
	{	
		Program program;
		bool allow_edit;
		public ProgramMenu(Program program, bool allow_edit=true, string? help=null) {
			base("Program: " + program.name, help ?? "Show a menu for the current program");
			this.program = program;
			this.allow_edit = allow_edit;
			ensure_items();		
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			if (allow_edit) {
				items.add(new MenuItem.custom("Edit", "Edit the program definition", null, () => {
					if (ObjectMenu.edit("Program: " + program.name, program) == true) {
						saved();
					}
				}));
			}
			items.add(new MenuItem.custom("Run", "Run the program using its default command", "", () => {
				var app = program.get_app();
				if (app == null) {
					error("App (%s) not found.".printf(program.app_id));
					return;
				}
				Spawning.spawn_app(app, false);
			}));			
		}						
	}
}
