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
