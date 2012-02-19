using Data;
using Data.Programs;
using Menus.Fields;
using Menus.Concrete;

namespace Fields
{	
	public class ProgramDefaultSettingsField : MenuItemField
	{
		Program program;
		ProgramDefaultSettings settings;
		protected int _clockspeed;
		string? _extra_arguments;		
		public ProgramDefaultSettingsField(string id, string name, string? help=null, Program program) {
			base(id, name, help);
			this.program = program;
			_clockspeed = -1;
		}

		public new ProgramDefaultSettings value {
			get { return settings; }
			set { change_value(value); }
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
		
		protected override Value get_field_value() { return program.default_settings; }
		protected override void set_field_value(Value value) { change_value((ProgramDefaultSettings)value); }

		protected override void activate(Menus.MenuSelector selector) {
			if (ProgramDefaultSettingsMenu.edit(program, _clockspeed, _extra_arguments) == true)
				changed();
		}
		
		void change_value(ProgramDefaultSettings new_value) {
			program.default_settings = new_value;
			changed();
		}
	}
		
}
