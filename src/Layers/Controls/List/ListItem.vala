/* ListItem.vala
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
	public abstract class ListItem<G> : Object
	{			
		G _value;
		public ListItem(G value) {
			_value = value;			
		}				
		
		public G value {
			get { return _value; }
			set {
				_value = value;
				on_value_set();
			}
		}
		
		public abstract unowned string name { get; }
		
		protected virtual void on_value_set() { }
		protected unowned G get_unowned_value() { return _value; }				
	}
}
