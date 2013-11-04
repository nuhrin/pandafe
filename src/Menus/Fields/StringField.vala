/* StringField.vala
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
using Layers.Controls;

namespace Menus.Fields
{
	public class StringField : MenuItemField
	{
		string _value;
		string? character_mask_regex;
		string? value_mask_regex;
		int _min_value_text_length;
		
		public StringField(string id, string name, string? help=null, string? value=null, string? character_mask_regex=null, string? value_mask_regex=null) {
			base(id, name, help);
			_value = value;
			this.character_mask_regex = character_mask_regex;
			this.value_mask_regex = value_mask_regex;
			_min_value_text_length = -1;
		}

		public new string value {
			get { return _value; }
			set { change_value(value); }
		}

		public signal void text_changed(string text);

		public override string get_value_text() { return _value ?? ""; }
		public override int get_minimum_menu_value_text_length() { return _min_value_text_length; }
		public void set_minimum_menu_value_text_length(uint? length) { _min_value_text_length = (length != null) ? (int)length : -1; }

		public void add_entry_validator(owned Predicate<string> is_valid, string error_if_invalid) {
			if (_validators == null)
				_validators = new ArrayList<Validator>();
			_validators.add(new Validator((owned)is_valid, error_if_invalid));
		}

		protected override Value get_field_value() { return _value; }
		protected override void set_field_value(Value value) { change_value((string)value); }
		protected override bool has_value() { return (_value != null && _value.strip() != ""); }

		protected override void activate(MenuSelector selector) {
			var rect = selector.get_selected_item_value_entry_rect();
			if (rect != null) {
				var entry = new TextEntry(id + "_entry", rect.x, rect.y, (int16)rect.w, _value, character_mask_regex, value_mask_regex);
				if (_validators != null) {
					foreach(var validator in _validators)
						entry.add_validator((value) => validator.is_valid(value), validator.error);
				}
				entry.validation_error.connect((msg) => {
					error("%s: %s".printf(name, msg ?? "not valid for some reason..."));
				});
				entry.error_cleared.connect(() => error_cleared());
				entry.text_changed.connect((text) => text_changed(text));
				change_value(entry.run());
				selector.update_selected_item_value();
				selector.update();
			}
		}
		
		bool change_value(string new_value) {
			_value = new_value;
			changed();
			return true;
		}
		
		class Validator {
			Predicate<string> predicate;
			string _error;
			public Validator(owned Predicate<string> is_valid, string error_if_invalid) {
				predicate = (owned)is_valid;
				_error = error_if_invalid;
			}
			public bool is_valid(string value) { return predicate(value); }
			public unowned string error { get { return _error; } }
		}
		ArrayList<Validator> _validators;

	}
}
