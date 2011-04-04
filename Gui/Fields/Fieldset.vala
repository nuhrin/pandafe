using Gee;
using YamlDB;

namespace yayafe.Gui.Fields
{
	public class Fieldset : Object, Iterable<Field>
	{
		HashMap<string, Field> fieldHash;
		ArrayList<string> nameList;
		Enumerable<Field> fieldEnumerable;

		construct {
			fieldHash = new HashMap<string, Field>();
			nameList = new ArrayList<string>();
			fieldEnumerable = new Enumerable<string>(nameList)
				.select<Field>(name=>fieldHash[name]);
		}

		public Type element_type { get { return typeof(Field); } }
		public Iterator<Field> iterator() { return fieldEnumerable.iterator(); }
		public Enumerable<Field> enumerable() { return fieldEnumerable; }

		public void add(Field field) {
			if (fieldHash.has_key(field.name) == true)
				nameList.remove(field.name);
			nameList.add(field.name);
			fieldHash[field.name] = field;
		}

		public bool contains(string name) { return fieldHash.has_key(name); }
		public new Field get(string name) { return fieldHash[name]; }
		

	}
}