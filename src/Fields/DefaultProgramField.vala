using Gee;
using Catapult;
using Data;
using Menus.Fields;

namespace Fields
{
	public class DefaultProgramField : StringSelectionField
	{
		Iterable<Program>? programs;
		public DefaultProgramField(string id, string name, string? help=null, Iterable<Program>? programs=null, Program? value) {
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

	}
}
