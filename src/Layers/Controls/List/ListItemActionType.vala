/* ListItemActionType.vala
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

namespace Layers.Controls.List
{
	public enum ListItemActionType
	{
		NONE,
		EDIT,
		INSERT_ABOVE,
		INSERT_BELOW,
		DELETE,
		MOVE;
		
		public unowned string name() {
			ensure_list_item_action_names();
			int index = (int)this;
			return list_item_action_names[index];
		}
		public static ListItemActionType from_name(string name) {
			ensure_list_item_action_names();
			for(int index=0;index<list_item_action_names.length;index++) {
				if (name == list_item_action_names[index])
					return (ListItemActionType)index;
			}
			warning("No ListItemActionType found for action name '%s'.", name);
			return ListItemActionType.NONE;
		}				
		
	}
	static string[] list_item_action_names;
	static void ensure_list_item_action_names() {
		if (list_item_action_names != null)
			return;
		list_item_action_names = {
			"",
			"Edit",
			"Insert Above",
			"Insert Below",
			"Delete",
			"Move"
		};	
	}
}
