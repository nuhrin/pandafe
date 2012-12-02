/* ProgramDefaultSettingsField.vala
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
using Data.Options;
using Data.Programs;
using Menus.Fields;
using Menus.Concrete;

namespace Fields
{	
	public class ProgramDefaultSettingsField : MenuItemField
	{
		string program_name;
		ProgramDefaultSettings settings;
		OptionSet options;
		protected int _clockspeed;
		string? _extra_arguments;		
		public ProgramDefaultSettingsField(string id, string name, string? help=null, string program_name, ProgramDefaultSettings settings, OptionSet options) {
			base(id, name, help);
			this.program_name = program_name;
			this.settings = new ProgramDefaultSettings();
			this.settings.merge_override(settings);
			this.options = options;
			_clockspeed = -1;
		}

		public new ProgramDefaultSettings value {
			get { return settings; }
			set { change_value(value); }
		}
		
		public void set_program_name(string program_name) {
			this.program_name = program_name;
		}
		public void set_options(OptionSet options) {
			this.options = options;
		}
		
		public void set_clockspeed(uint clockspeed) { 
			_clockspeed = (int)clockspeed;
		}
		public void set_extra_arguments(string extra_arguments) {
			_extra_arguments = extra_arguments;
		}
		
		public override string get_value_text() { return "..."; }
		public override int get_minimum_menu_value_text_length() { return 3; }
		protected override bool has_value() { return true; }
		
		protected override Value get_field_value() { return settings; }
		protected override void set_field_value(Value value) { change_value((ProgramDefaultSettings)value); }

		protected override void activate(Menus.MenuSelector selector) {
			if (ProgramDefaultSettingsMenu.edit(program_name, settings, options) == true)
				changed();
		}
		
		void change_value(ProgramDefaultSettings new_value) {
			settings = new_value;
			changed();
		}
	}
		
}
