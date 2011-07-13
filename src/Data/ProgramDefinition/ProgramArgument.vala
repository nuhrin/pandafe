using Catapult;
using pandafe.Data.ProgramDefinition.OptionType;

namespace pandafe.Data.ProgramDefinition
{
	public class ProgramArgument : Object
	{
		public string Name { get; set; }
		public string Description { get; set; }

		public bool IsRequired { get; set; }

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

	}
}
