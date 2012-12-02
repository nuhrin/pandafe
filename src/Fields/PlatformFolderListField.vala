/* PlatformFolderListField.vala
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
using Catapult;
using Data;
using Data.Platforms;
using Layers.Controls;
using Layers.Controls.List;
using Menus;
using Menus.Fields;

namespace Fields
{
	public class PlatformFolderListField : ListField<PlatformFolder>
	{
		PlatformFolder? parent;
		public PlatformFolderListField(string id, string name, string? help=null, PlatformFolder folder, string? title=null) {
			base(id, name, help, folder.folders, title);
			this.parent = folder;
		}
		public PlatformFolderListField.root(string id, string name, string? help=null, Gee.List<PlatformFolder> folders) {
			base(id, name, help, folders);
		}
		
		protected override ListEditor<PlatformFolder> get_list_editor(string? title) {
			return new PlatformFolderListEditor(id, title ?? "Platform Folders", null, parent, value, n=>n.name);
		}
		
		class PlatformFolderListEditor : ListEditor<PlatformFolder>
		{
			PlatformFolder? parent;
			public PlatformFolderListEditor(string id, string name, string? help=null, PlatformFolder? parent, Gee.List<PlatformFolder> list, owned MapFunc<string?, PlatformFolder> get_name_string) {
				base(id, name, help, list, (owned)get_name_string);
				this.parent = parent;
			}
			protected override bool create_item(Rect selected_item_rect, out PlatformFolder item) {
				item = (parent == null)
					? new PlatformFolder.root("")
					: new PlatformFolder("", parent);
				return true;
			}
			protected override bool edit_list_item(ListItem<PlatformFolder> item, uint index) {
				return ObjectMenu.edit("Edit Platform Folder", item.value);
			}
			
		}
	}
}
