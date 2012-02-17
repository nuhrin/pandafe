using Catapult;
using Menus;
using Menus.Fields;

namespace Data.Options
{
	public abstract class Option : Object, MenuObject
	{
		public string name { get; set; }
		public string? help { get; set; }
		public string option { get; set; }
		
		public abstract OptionType option_type { get; }
		
		// menu
		protected void build_menu(MenuBuilder builder) {
			builder.add_string("name", "Name", null, name);
			builder.add_string("option", "Option", "-o, --option, etc", option);
			build_edit_fields(builder);
			builder.add_string("help", "Help", "Help text to display during option selection", help);
		}
		protected abstract void build_edit_fields(MenuBuilder builder);
//~ 		protected bool apply_menu(Menu menu) {
//~ 			name = menu.get_field<StringField>("name").value;
//~ 			option = menu.get_field<StringField>("option").value;
//~ 			help = menu.get_field<StringField>("help").value;
//~ 			return apply_edit_fields(menu);
//~ 		}
//~ 		protected abstract bool apply_edit_fields(Menu menu);
		
		// field
		public abstract MenuItemField get_setting_field(string? setting);
		public abstract string get_setting_value_from_field(MenuItemField field);
		
		// 
		public abstract string get_option_from_setting_value(string? setting);		
	}
}
