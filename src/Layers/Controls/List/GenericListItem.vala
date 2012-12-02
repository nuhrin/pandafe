/* GenericListItem.vala
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

namespace Layers.Controls.List
{
	public class GenericListItem<G> : ListItem<G>
	{	
		MapFunc<string?, G> get_name_string;
		
		public GenericListItem(G value, owned MapFunc<string?, G> get_name_string) {
			base(value);
			this.get_name_string = (owned)get_name_string;
		}				
		
		public override unowned string name {
			get {
				_name = get_name_string(get_unowned_value()) ?? "";
				return _name;
			}
		}
		string _name;
	}
}
