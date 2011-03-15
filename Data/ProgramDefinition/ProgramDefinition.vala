using Gee;
using YamlDB;
using yayafe.Data.ProgramDefinition;

public class ProgramDefinition : NamedEntity
{
	construct {
		OptionSet = new yayafe.Data.ProgramDefinition.OptionSet();
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
	public int PrimaryArgumentIndex {
		get { return primaryArgumentIndex; }
		set {
			if (value < 0 || value >= ArgumentCount)
				return;
			primaryArgumentIndex = value;
		}
	}
	int primaryArgumentIndex;
	internal ProgramArgument? get_primary_argument() { return (primaryArgumentIndex < 0 || primaryArgumentIndex >= ArgumentCount) ? null : Arguments[primaryArgumentIndex]; }
	public int ArgumentCount { get { return Arguments.size; } }
	public ProgramArgument get_argument_at(int index) { return Arguments[index]; }

	internal Gee.List<ProgramArgument> Arguments { get; set; }
}
