/* MenuBrowserItem.vala
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
using SDL;

namespace Menus
{
	public class MenuBrowserItem : SubMenuItem, MenuItem
	{	
		Menu _menu;
		MenuItemActivationAction? activate_action;
		ArrayList<ulong> handlers;
		
		public MenuBrowserItem(string name, string? help=null, Menu menu, owned MenuItemActivationAction? action=null) {
			base(name, help);
			set_menu(menu);
			this.activate_action = (owned)action;
			handlers = new ArrayList<ulong>();
		}
		public Menu menu { get { return _menu; } }
		public void set_menu(Menu menu) { _menu = menu; }		

		public bool on_activation(MenuSelector selector) {
			if (activate_action != null)
				activate_action();
			return true;
		}
		
		public override void activate(MenuSelector selector) { 
			if (on_activation(selector) == false)
				return;
			
			handlers.add(_menu.cancelled.connect(() => cancelled()));
			handlers.add(_menu.saved.connect(() => saved()));
			handlers.add(_menu.finished.connect(() => finished()));

			new MenuBrowser(menu).run();
			
			foreach(var handler in handlers)
				_menu.disconnect(handler);
			handlers.clear();
		}
		
		public override bool is_menu_item() { return true; }
	}
}
