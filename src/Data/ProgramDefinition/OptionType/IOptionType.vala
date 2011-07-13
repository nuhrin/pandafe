using Gtk;
using Catapult;

namespace yayafe.Data.ProgramDefinition.OptionType
{
	public interface IOptionType : IYamlObject
	{
		public abstract string Name { get; }
		public abstract string Description { get; }
		public abstract Type Type { get; }
		public abstract Widget get_widget(string name, string desc, string datakey, OptionData data, Value val);
		public abstract Widget get_type_widget(OptionData data);
		public abstract OptionData get_default_data();
		public abstract string get_option_string(string optionText, string optionDelim, OptionData data, Value val);
	}
}