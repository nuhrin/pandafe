/* GameBrowserAppearanceField.vala
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

using Data;
using Menus;
using Menus.Concrete;
using Menus.Fields;
using Layers.Controls;

namespace Fields
{
	public class GameBrowserAppearanceField : MenuItemField
	{
		string? title;
		GameBrowserAppearance? appearance;
		GameBrowserAppearance? default_appearance;
		public GameBrowserAppearanceField(string id, string name, string? help=null, string? menu_title, GameBrowserAppearance? appearance, GameBrowserAppearance? default_appearance=null) {
			base(id, name, help);
			this.title = menu_title;
			this.appearance = appearance;
			this.default_appearance = default_appearance;
		}

		public new GameBrowserAppearance? value {
			get { return appearance; }
			set { change_value(value); }
		}

		public override string get_value_text() { return ""; }
		public override int get_minimum_menu_value_text_length() { return 0; }

		protected override Value get_field_value() { return appearance; }
		protected override void set_field_value(Value value) { change_value((GameBrowserAppearance?)value); }
		protected override bool has_value() { return (appearance != null && appearance.has_data()); }
		protected override bool is_menu_item() { return true; }

		protected override void activate(MenuSelector selector) {
			var new_appearance = appearance;
			if (new_appearance == null) {
				new_appearance = (default_appearance != null)
					? default_appearance.copy()
					: new GameBrowserAppearance.default();
			}
			var menu = new GameBrowserAppearanceMenu(title ?? "Appearance", new_appearance, default_appearance);
			menu.saved.connect(() => {
				if (default_appearance != null && new_appearance.matches(default_appearance) == true)
					change_value(null);
				else 
					change_value(new_appearance);
			});
			new MenuBrowser(menu).run();
		}
		
		bool change_value(GameBrowserAppearance? new_value) {
			appearance = new_value;
			changed();
			return true;
		}
	}
}
