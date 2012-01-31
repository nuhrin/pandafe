using Data;
using Menus.Fields;
using Menus.Concrete;

namespace Fields
{
	public class ProgramSettingsField : MenuItemField
	{
		Program program;
		ProgramSettings settings;
		public ProgramSettingsField(string id, string name, string? help=null, Program program, ProgramSettings settings) {
			base(id, name, help);
			this.program = program;
			this.settings = settings;
		}

		public new ProgramSettings value {
			get { return settings; }
			set { change_value(value); }
		}		
		
		public override string get_value_text() { return "..."; }

		protected override Value get_field_value() { return settings; }
		protected override void set_field_value(Value value) { change_value((ProgramSettings)value); }

		protected override void activate(Menus.MenuSelector selector) {
			if (ProgramSettingsMenu.edit(program, settings) == true)
				changed();
		}
		
		void change_value(ProgramSettings new_value) {
			settings = new_value;
			changed();			
		}
	}
}
