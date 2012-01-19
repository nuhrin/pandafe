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

		public signal void error(string error);
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
			return do_validation();
		}

		public abstract string get_value_text();
		public virtual Surface? get_value_rendering(Font* font) { return null; }

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
