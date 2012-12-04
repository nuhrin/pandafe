/* MenuItemField.vala
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
using SDLTTF;

namespace Menus.Fields
{
	public abstract class MenuItemField : MenuItem
	{
		bool is_dirty;
		public MenuItemField(string id, string name, string? help=null) {
			base(name, help);
			this.id = id;
		}
		public string id { get; private set; }

		public Value value {
			owned get { return get_field_value(); }
			set { set_field_value(value); }
		}
		public virtual signal void changed() { on_changed(); }
		public virtual bool has_changes() { return is_dirty; }
		public virtual void make_clean() { is_dirty = false; }

		public signal void message(string message);
		public signal void error(string error);
		public signal void error_cleared();
		public void add_validator(owned Predicate<Value?> is_valid, string error_if_invalid) {
			if (_validators == null)
				_validators = new ArrayList<Validator>();
			_validators.add(new Validator((owned)is_valid, error_if_invalid));
		}
		public bool validate() {
			if (_validators != null) {
				foreach(var validator in _validators) {
					if (validator.is_valid(value) == false) {
						this.error(validator.error);
						return false;
					}
				}
			}
			if (required == true && has_value() == false) {
				this.error("%s is required.".printf(name));
				return false;
			}
			
			return do_validation();
		}
		public bool required { get; set; }

		public abstract string get_value_text();
		public abstract int get_minimum_menu_value_text_length();
		
		public virtual Surface? get_value_rendering(Font* font) { return null; }

		public override bool handles_keydown_event(KeyboardEvent event) {
			if (event.keysym.mod == KeyModifier.NONE) {
				switch(event.keysym.sym) {
					case KeySymbol.LEFT:
						return true;
					case KeySymbol.RIGHT:
						return true;
					default:
						break;
				}
			}
			return false;
		}
		public override bool process_keydown_event(KeyboardEvent event) {
			if (event.keysym.mod == KeyModifier.NONE) {
				switch(event.keysym.sym) {
					case KeySymbol.LEFT:
						return select_previous();
					case KeySymbol.RIGHT:
						return select_next();
					default:
						break;
				}
			}
			return false;
		}
		//public override bool process_keyup_event(KeyboardEvent event) { return false; }

		protected abstract Value get_field_value();
		protected abstract void set_field_value(Value value);
		protected abstract bool has_value();
		
		protected virtual bool do_validation() { return true; }
		
		protected virtual void on_changed() { is_dirty = true; }
		protected virtual bool select_previous() { return false; }
		protected virtual bool select_next() { return false; }
		
		class Validator {
			Predicate<Value?> predicate;
			string _error;
			public Validator(owned Predicate<Value?> is_valid, string error_if_invalid) {
				predicate = (owned)is_valid;
				_error = error_if_invalid;
			}
			public bool is_valid(Value value) { return predicate(value); }
			public unowned string error { get { return _error; } }
		}
		ArrayList<Validator> _validators;
	}
}
