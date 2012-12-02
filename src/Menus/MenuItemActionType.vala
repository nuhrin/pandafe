/* MenuItemActionType.vala
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

namespace Menus
{
	public enum MenuItemActionType
	{
		NONE,
		CANCEL,
		SAVE,
		QUIT,
		SAVE_AND_QUIT;	
		
		public unowned string name() {
			ensure_menu_item_action_names();
			int index = (int)this;
			return menu_item_action_names[index];
		}
		public static MenuItemActionType from_name(string name) {
			ensure_menu_item_action_names();
			for(int index=0;index<menu_item_action_names.length;index++) {
				if (name == menu_item_action_names[index])
					return (MenuItemActionType)index;
			}
			warning("No MenuItemActionType found for action name '%s'.", name);
			return MenuItemActionType.NONE;
		}				
	}
	static string[] menu_item_action_names;
	static void ensure_menu_item_action_names() {
		if (menu_item_action_names != null)
			return;
		menu_item_action_names = {
			"",
			"Cancel",
			"Save",
			"Quit",
			""
		};	
	}
}
