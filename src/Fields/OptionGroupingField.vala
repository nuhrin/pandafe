using Data;
using Data.Options;
using Data.Programs;
using Menus;
using Menus.Fields;
using Menus.Concrete;

namespace Fields
{
	public class OptionGroupingField : MenuItemField, SubMenuItem
	{
		OptionGrouping grouping;
		ProgramSettings settings;
		OptionGroupingMenu _menu;
		
		public OptionGroupingField(string id, string name, string? help=null, OptionGrouping grouping, string program_name, ProgramSettings settings) {
			base(id, name, help);
			this.grouping = grouping;
			this.settings = settings;
			_menu = new OptionGroupingMenu(program_name, grouping, settings);
			_menu.cancelled.connect(() => cancelled());
			_menu.saved.connect(() => saved());
			_menu.finished.connect(() => finished());
		}
		
		public Menu menu { get { return _menu; } }

		public new OptionGrouping value {
			get { return grouping; }
			set { change_value(value); }
		}
		
		public void populate_settings_from_fields(ProgramSettings target_settings) {
			_menu.populate_settings_from_fields(target_settings);
		}
		
		public override string get_value_text() { return ""; }
		public override int get_minimum_menu_value_text_length() { return 0; }
		public override bool is_menu_item() { return true; }

		protected override Value get_field_value() { return settings; }
		protected override void set_field_value(Value value) { change_value((OptionGrouping)value); }
		protected override bool has_value() { return true; }

		protected override void activate(Menus.MenuSelector selector) {
			new MenuBrowser(_menu, 40, 40).run();
		}
		
		void change_value(OptionGrouping new_value) {
			grouping = new_value;
			changed();
		}
	}
}
