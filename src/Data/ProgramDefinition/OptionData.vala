using Gee;
using Catapult;

namespace yayafe.Data.ProgramDefinition
{
	public class OptionData : Object
	{
		HashMap<string, Value?> dataHash = new HashMap<string, Value?>();

		public new Value? get(string property) {
			if (dataHash.has_key(property))
				return dataHash[property];
			return null;
		}
		public new void set(string property, Value value) {
			dataHash[property] = value;
		}

		public string[] get_names() { return dataHash.keys.to_array(); }

		public void clear() { dataHash.clear(); }
	}
}
