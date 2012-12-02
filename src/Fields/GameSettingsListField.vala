/* GameSettingsListField.vala
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
using Layers.Controls;
using Layers.Controls.List;
using Menus;
using Menus.Concrete;
using Menus.Fields;

namespace Fields
{
	public class GameSettingsListField : ListField<GameSettings>
	{
		Gee.List<GameSettings> settings_list;
		public GameSettingsListField(string id, string name, string? help=null, string? title=null) {
			base(id, name, help, new ArrayList<GameSettings>(), title);
		}
		protected override void activate(MenuSelector selector) {
			if (settings_list == null) {
				try {
					settings_list = Data.data_interface().load_all<GameSettings>(false)
						.sort((a,b) => Utility.strcasecmp(a.id, b.id))
						.to_list();
				}
				catch {
					settings_list = new ArrayList<GameSettings>();
				}
			}
			if (settings_list.size == 0)
				this.message("No game settings found.");
			else
				base.activate(selector);
		}
		protected override ListEditor<GameSettings> get_list_editor(string? title) {			
			return new GameSettingsListEditor(id, title ?? name, null, settings_list, p=>p.id);
		}
		
		class GameSettingsListEditor : ListEditor<GameSettings>
		{
			public GameSettingsListEditor(string id, string name, string? help=null, Gee.List<GameSettings> list, owned MapFunc<string?, GameSettings> get_name_string) {
				base(id, name, help, list, (owned)get_name_string);
				save_on_return = true;
			}
			protected override bool create_item(Rect selected_item_rect, out GameSettings item) {
				item = null;
				return false;
			}
			protected override bool edit_list_item(ListItem<GameSettings> item, uint index) {
				var settings = item.value;
				if (settings.platform == null)
					return false;
				var platform = Data.platforms().get_platform(settings.platform);
				if (platform == null)
					return false;
				
				bool saved = false;
				var menu = new GameSettingsMenu.custom(settings.id, settings.id, platform, settings);
				menu.saved.connect(() => saved=true);
				new MenuBrowser(menu).run();
				return saved;
			}
			protected override bool confirm_deletion() { return true; }
			protected override bool on_delete(ListItem<GameSettings> item) {
				try {
					Data.data_interface().remove(item.value);
					return true;
				} catch(GLib.Error e) {
					warning(e.message);
				}
				return false;
			}
			protected override bool can_insert() { return false; }
			protected override string? get_cancel_item_text() { return null; }
			protected override string? get_save_item_text() { return "Return"; }
		}
	}
}
