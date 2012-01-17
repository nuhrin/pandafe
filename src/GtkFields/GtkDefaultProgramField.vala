using Gtk;
using Gee;
using Catapult;
using Catapult.Gui.Fields;
using Data;

namespace GtkFields
{
	public class GtkDefaultProgramField : StringSelectionField
	{
		Iterable<Program>? programs;
		public GtkDefaultProgramField(string id, string? label=null, Iterable<Program>? programs=null, Program? value) {
			base(id, label);
			if (programs != null)
				set_programs(programs);
			if (value != null)
				base.set_active_value(value.name);
		}

		public void set_programs(Iterable<Program> programs) {
			this.programs = programs;
			var names = new Enumerable<Program>(programs).select<string>(p=>p.name);
			base.set_items(names);
			make_clean();
		}

		public Program? active_program {
			owned get { return get_program(); }
		}
		protected Program? get_program() {
			if (active_index > -1) {
				string? active = base.active_item;
				foreach(var program in programs) {
					if (program.name == active)
						return program;
				}
			}
			return null;
		}
		protected void set_program(Program? program) {
			if (program == null)
				base.set_active_value(null);
			else
				base.set_active_value(program.name);
		}

		protected override Value get_field_value() { return get_program(); }
		protected override void set_field_value(Value value) { set_program((Program?)value); }

	}
}
