/* ObjectBrowserItem.vala
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

using SDL;

namespace Menus
{
	public class ObjectBrowserItem : MenuItem
	{		
		public ObjectBrowserItem(string name, string? help=null, Object obj) {
			base(name, help);
			this.object = obj;
		}
		public Object object { get; set; }
		public bool was_saved { get; private set; }
		
		public signal void cancelled();
		public signal void saved();
		public signal void finished();
		
		public override void activate(MenuSelector selector) {
			was_saved = ObjectMenu.edit(name, object);
			if (was_saved == true)
				saved();
			else
				cancelled();
			finished();
		}
		
		public override bool is_menu_item() { return true; }
	}
}
