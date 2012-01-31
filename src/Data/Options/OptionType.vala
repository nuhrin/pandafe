
namespace Data.Options
{
	public enum OptionType
	{
		NONE,
		FLAG,
		STRING_SELECTION;
		
		public static unowned string[] get_names() {
			ensure_option_type_names();
			return option_type_names;
		}
		public Option? create_option() {
			switch(this) {
				case OptionType.FLAG:
					return new FlagOption();
				case OptionType.STRING_SELECTION:
					return new StringSelectionOption();
				default:
					break;
			}
			return null;
		}
		public static Option? create_option_from_name(string name) {
			ensure_option_type_names();
			for(int index=0;index<option_type_names.length;index++) {
				if (name == option_type_names[index])
					return ((OptionType)index + 1).create_option();
			}
			warning("No OptionType found for name '%s'.", name);
			return null;
		}
	}
	static string[] option_type_names;
	static void ensure_option_type_names() {
		if (option_type_names != null)
			return;
		option_type_names = {
			"Flag",
			"String Selection"
		};	
	}
}
