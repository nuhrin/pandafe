using Catapult;
using yayafe.Data.ProgramDefinition.OptionType;

namespace yayafe.Data.ProgramDefinition
{
	public class Option : Object
	{
		public int ID { get; set; }
		public string Name { get; set; }
		public string Description { get; set; }
		public string OptionText { get; set; }

		public IOptionType OptionType
		{
			get { return option_type; }
			set {
				option_type = value;
				Data = option_type.get_default_data();
			}
		}
		IOptionType option_type;
		public OptionData Data { get; private set; }

		public new Value? get_data(string property) {
			return Data[property];
		}
		public new void set_data(string property, Value value) {
			Data[property] = value;
		}
	}
}
