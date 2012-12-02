/* PndAppField.vala
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

using Layers.Controls;
using Data.Pnd;
using Menus.Fields;

namespace Fields
{
	public class PndAppField : MenuItemField
	{
		AppItem? _value;
		public PndAppField(string id, string name, string? help=null, string? app_id=null, string? pnd_id=null) {
			base(id, name, help);
			_value = Data.pnd_data().get_app(app_id, pnd_id);
		}

		public new AppItem? value {
			get { return _value; }
			set { change_value(value); }
		}		
		public string pnd_app_id { get { return (value != null) ? value.id : ""; } }
		public string pnd_id { get { return (value != null) ? value.package_id : ""; } }

		public override string get_value_text() { 
			if (_value == null)
				return "";
			
			return _value.title;
		}
		public override int get_minimum_menu_value_text_length() { return -1; }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((AppItem?)value); }
		protected override bool has_value() { return (_value != null); }

		protected override void activate(Menus.MenuSelector selector) {
			var chooser = new PndAppChooser("app_chooser", "Choose App: " + name);
			AppItem? new_app = chooser.run(_value);
			if (new_app != null && change_value(new_app)) {			
				selector.update_selected_item_value();
				selector.update();
			}
		}
		
		bool change_value(AppItem? new_value) {
			if (new_value == _value) {
				if (new_value.id == pnd_app_id && new_value.package_id == pnd_id)
					return false;
			}
			_value = new_value;
			changed();
			return true;
		}
	}
}
