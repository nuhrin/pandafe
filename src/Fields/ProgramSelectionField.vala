/* ProgramSelectionField.vala
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
using Catapult;
using Data;
using Menus.Fields;

namespace Fields
{
	public class ProgramSelectionField : StringSelectionField
	{
		Iterable<Program>? programs;
		public ProgramSelectionField(string id, string name, string? help=null, Iterable<Program>? programs=null, Program? value) {
			base(id, name, help);
			if (programs != null)
				set_programs(programs);
			if (value != null)
				base.set_field_value(value.name);			
		}

		public void set_programs(Iterable<Program> programs) {
			this.programs = programs;
			var names = new Enumerable<Program>(programs).select<string>(p=>p.name);
			base.set_items(names);
		}

		public Program? selected_program {
			owned get { return get_program(); }
		}
		protected Program? get_program() {
			var selected = (string?)base.get_field_value();
			if (selected == null)
				return null;
				
			foreach(var program in programs) {
				if (program.name == selected)
					return program;				
			}
			return null;
		}
		protected void set_program(Program? program) {
			if (program == null)
				base.set_field_value((string?)null);
			else
				base.set_field_value(program.name);
		}

		protected override Value get_field_value() { return get_program(); }
		protected override void set_field_value(Value value) { set_program((Program?)value); }
		protected override bool has_value() { return (selected_program != null); }

	}
}
