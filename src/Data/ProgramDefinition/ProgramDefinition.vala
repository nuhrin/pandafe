using Gee;
using Catapult;
using Catapult.Helpers;

using pandafe.Data.ProgramDefinition;

public class ProgramDefinition : NamedEntity
{
	construct {
		OptionSet = new pandafe.Data.ProgramDefinition.OptionSet();
		DefaultOptionState = new OptionSetState();
		OptionValueDelimiter = "";
		ListValueDelimiter = "";
		Arguments = new ArrayList<ProgramArgument>();
	}

	public string Version { get; set; }
	internal OptionSet OptionSet { get; private set; }
	public OptionSetState DefaultOptionState { get; private set; }
	public string OptionValueDelimiter { get; set; }
	public string ListValueDelimiter { get; set; }
	public bool ArgumentsBeforeOptions { get; set; }

	public string get_default_option_string() {
		return get_option_string(DefaultOptionState);
	}
	public string get_option_string(OptionSetState state) {
		return OptionSet.get_option_string(state, OptionValueDelimiter);
	}

	// ProgramArgument related
	public Gee.List<ProgramArgument> Arguments { get; private set; }
	public int PrimaryArgumentIndex {
		get { return primaryArgumentIndex; }
		set {
			if (value < 0 || value >= Arguments.size)
				return;
			primaryArgumentIndex = value;
		}
	}
	int primaryArgumentIndex;
	internal ProgramArgument? get_primary_argument() { return (primaryArgumentIndex < 0 || primaryArgumentIndex >= Arguments.size) ? null : Arguments[primaryArgumentIndex]; }

	protected override string generate_id() {
		string id = Name + "_" + Version;
		return RegexHelper.NonWordCharacters.replace(id, "").down();
	}
}
