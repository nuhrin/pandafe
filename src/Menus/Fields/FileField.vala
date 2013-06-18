/* FileField.vala
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

namespace Menus.Fields
{
	public class FileField : MenuItemField
	{
		string? _value;
		string? file_extensions;
		string? root_path;
		int _min_value_text_length;
		
		public FileField(string id, string name, string? help=null, string? path=null, string? file_extensions=null, string? root_path=null) {
			base(id, name, help);

			_value = path;
			this.file_extensions = file_extensions;
			this.root_path = root_path;
			_min_value_text_length = -1;
		}

		public new string? value {
			get { return _value; }
			set { change_value(value); }
		}

		public override string get_value_text() { return (_value == null) ? "" : Path.get_basename(_value); }
		public override int get_minimum_menu_value_text_length() { return _min_value_text_length; }
		public void set_minimum_menu_value_text_length(uint? length) { _min_value_text_length = (length != null) ? (int)length : -1; }

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((string?)value); }
		protected override bool has_value() { return (_value != null && _value.strip() != ""); }

		protected override void activate(MenuSelector selector) {
			var chooser = new FileChooser("file_chooser", "Choose file: " + name, file_extensions, root_path);
			var new_path = chooser.run(_value);
			if (new_path != null && change_value(new_path)) {			
				selector.update_selected_item_value();
				selector.update();
			}
		}
		
		bool change_value(string? new_value) {
			if (new_value == _value)
				return false;
			
			_value = new_value;
			changed();
			return true;
		}
	}
}
