/* ListEditor.vala
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
using Gee;
using Layers.Controls.List;

namespace Layers.Controls
{
	public abstract class ListEditor<G> : ListEditorBase<G>
	{
		MapFunc<string, G> get_name_string;
		public ListEditor(string id, string title, string? help=null, Gee.List<G> list, owned MapFunc<string, G> get_name_string) {
			base(id, title, help, list);
			this.get_name_string = (owned)get_name_string;
		}
		
		protected override ListItem<G> get_list_item(G item) {
			return new GenericListItem<G>(item, (owned)get_name_string);
		}
		
	}
}
