using Data;
using Data.Programs;
using Menus.Fields;
using Menus.Concrete;

namespace Fields
{
	public class ProgramSettingsField : MenuItemField
	{
		Program program;
		ProgramSettings settings;		
		protected int _clockspeed;
		public ProgramSettingsField(string id, string name, string? help=null, Program program, ProgramSettings settings) {
			base(id, name, help);
			this.program = program;
			this.settings = settings;
			_clockspeed = -1;
		}

		public new ProgramSettings value {
			get { return settings; }
			set { change_value(value); }
		}
		
		public void set_clockspeed(uint clockspeed) { 
			_clockspeed = (int)clockspeed;
		}
		
		public override string get_value_text() { return "..."; }
		public override int get_minimum_menu_value_text_length() { return 3; }

		protected override Value get_field_value() { return settings; }
		protected override void set_field_value(Value value) { change_value((ProgramSettings)value); }
		protected override bool has_value() { return true; }

		protected override void activate(Menus.MenuSelector selector) {
			if (ProgramSettingsMenu.edit(program, settings, _clockspeed) == true)
				changed();
		}
		
		void change_value(ProgramSettings new_value) {
			settings = new_value;
			changed();
		}
	}
	
	public class ProgramDefaultSettingsField : MenuItemField
	{
		Program program;
		ProgramDefaultSettings settings;		
		protected int _clockspeed;
		string? _extra_arguments;		
		public ProgramDefaultSettingsField(string id, string name, string? help=null, Program program, ProgramDefaultSettings settings) {
			base(id, name, help);
			this.program = program;
			this.settings = settings;
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
		
		protected override Value get_field_value() { return settings; }
		protected override void set_field_value(Value value) { change_value((ProgramDefaultSettings)value); }

		protected override void activate(Menus.MenuSelector selector) {
			if (ProgramSettingsMenu.edit_default(program, settings, _clockspeed, _extra_arguments) == true)
				changed();
		}
		
		void change_value(ProgramDefaultSettings new_value) {
			settings = new_value;
			changed();
		}
	}
		
}
