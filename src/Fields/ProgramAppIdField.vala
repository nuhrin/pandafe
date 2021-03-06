/* ProgramAppIdField.vala
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
using Data.Pnd;
using Menus.Fields;
using Layers.Controls;

namespace Fields
{
	public class ProgramAppIdField : MenuItemField
	{
		string _app_id;
		public ProgramAppIdField(string id, string name, string? help=null, AppIdType app_id_type, string? app_id) {
			base(id, name, help);
			_app_id = app_id ?? "";
			this.app_id_type = app_id_type;
		}

		public new string value {
			owned get { return _app_id; }
			set { change_value(value); }
		}
		public AppIdType app_id_type	{ get; set; }
		
		public override string get_value_text() { return _app_id; }
		public override int get_minimum_menu_value_text_length() { return 15; }

		protected override Value get_field_value() { return _app_id; }
		protected override void set_field_value(Value value) { change_value((string)value); }
		protected override bool has_value() { return (_app_id != null && _app_id.strip() != ""); }

		protected override void activate(Menus.MenuSelector selector) {
			string? new_value = null;
			if (app_id_type == AppIdType.EXACT) {
				var chooser = new PndAppChooser("app_chooser", "Choose App");
				var selected_app = chooser.run(Data.pnd_data().get_app(_app_id));
				if (selected_app != null)
					new_value = selected_app.id;			
			} else {
				var rect = selector.get_selected_item_value_entry_rect();
				if (rect != null) {
					var entry = new TextEntry(id + "_entry", rect.x, rect.y, (int16)rect.w, _app_id);
					new_value = entry.run() ?? "";					
				}
			}
			if (new_value != null && change_value(new_value.strip())) {
				selector.update_selected_item_value();
				selector.update();
			}
		}
		protected override bool do_validation() {
			if (_app_id.strip() == "") {
				error(name + " is required.");
				return false;
			}
			if (app_id_type == AppIdType.REGEX) {
				try {
					new Regex(_app_id);
				} catch(RegexError e) {
					error("Invalid regex: " + _app_id);
					return false;
				}
			}
			return true;
		}
		
		bool change_value(string new_value) {
			if (new_value == _app_id)
				return false;
			_app_id = new_value;
			changed();
			return true;	
		}
	}
}
