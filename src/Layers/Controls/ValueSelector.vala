/* ValueSelector.vala
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
using SDLTTF;
using Gee;

namespace Layers.Controls
{
	public class ValueSelector<G> : ValueSelectorBase<G>
	{		
		MapFunc<string, G> getItemName;
		
		public ValueSelector(string id, int16 xpos, int16 ypos, int16 max_width, owned MapFunc<string, G> getItemName, Iterable<G>? items=null, uint selected_index=0) {
			base(id, xpos, ypos, max_width, items, selected_index);
			this.getItemName = (owned)getItemName;			
		}
		
		protected override string get_item_name(int index) {
			return getItemName(get_item_at(index));
		}
	}
}
