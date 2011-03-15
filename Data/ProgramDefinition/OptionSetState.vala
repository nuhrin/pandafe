using Gee;
using YamlDB;

namespace yayafe.Data.ProgramDefinition
{
	public class OptionSetState : Object
	{
		HashMap<int, Value?> optionValueHash = new HashMap<int, Value?>();

		public new Value? get(int id) {
			if (optionValueHash.has_key(id))
				return optionValueHash[id];
			return null;
		}
		public new void set(int id, Value value) {
			optionValueHash[id] = value;
		}

		public void clear() { optionValueHash.clear(); }
	}
}
