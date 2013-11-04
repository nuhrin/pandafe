/* ProgramMenu.vala
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
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			if (allow_edit) {
				items.add(new MenuItem.custom("Edit", "Edit the program definition", null, () => {
					if (ObjectMenu.edit("Program: " + program.name, program) == true) {
						saved();
					}
				}));
			}
			var app = program.get_app();				
			items.add(new MenuItem.custom("Run", "Run the program using its default command", "", () => {
				if (app == null) {
					error("App (%s) not found.".printf(program.app_id));
					return;
				}
				Spawning.spawn_app(app, false);
			}));
			
			items.add(new MenuItemSeparator());
			items.add(new GameAppMenu.AppTerminalFolderItem(app, program.name));
			items.add(new GameAppMenu.AppFileManagerFolderItem(app, program.name));
		}						
	}
}
