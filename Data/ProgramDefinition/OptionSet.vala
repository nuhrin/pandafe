using YamlDB;

namespace yayafe.Data.ProgramDefinition
{
	public class OptionSet : Object
	{
		construct {
			RootPath = new OptionPath() { Name = "Root", Description = "Top level path" };
		}
		public OptionPath RootPath { get; internal set; }
		public int GetDepth() { return greatest_depth(RootPath, 0); }
		public int GetNextOptionId() { return max_option_id(RootPath)+1; }

		public string get_option_string(OptionSetState state, string default_delimiter) {
			return GetOptionString(default_delimiter, state, RootPath).chug();
		}
		string GetOptionString(string default_delimiter, OptionSetState state, OptionPath path) {
			string optionStr = "";
			foreach(var child in path.ChildPaths)
				optionStr += GetOptionString(default_delimiter, state, child);
			foreach(var option in path.Options) {
				if (option.OptionType == null)
					continue;
				string str = option.OptionType.get_option_string(option.OptionText, default_delimiter, option.Data, state[option.ID]);
				if(str != "")
					optionStr += str+" ";
			}
			return optionStr;
		}
		int greatest_depth(OptionPath path, int current_depth) {
			int max = current_depth;
			if (path.Depth > current_depth)
				max = path.Depth;
			foreach(var child in path.ChildPaths)
				max = greatest_depth(child, max);
			return max;
		}
		int max_option_id(OptionPath path) {
			int max = -1;
			foreach(var option in path.Options) {
				if (option.ID > max)
					max = option.ID;
			}
			foreach(var child in path.ChildPaths) {
				int childMax = max_option_id(child);
				if (childMax > max)
					max = childMax;
			}
			return max;
		}
	}
}
