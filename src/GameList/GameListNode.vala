namespace Data.GameList
{
	public abstract class GameListNode
	{
		string? _id;
		string? _full_name;
		protected GameListNode(string name, GameListProvider provider, GameFolder? parent=null, string? id=null, string? full_name=null) {
			this.name = name;
			this.provider = provider;
			this.parent = parent;
			this._id = id;
			this._full_name = full_name;
		}
		protected GameListProvider provider { get; private set; }
		public string name { get; private set; }
		public string full_name { get { return (_full_name != null) ? _full_name : name; } }
		public GameFolder? parent { get; private set; }
		public string id { get { return (_id != null) ? _id : name; } }
		public string unique_id() { return provider.get_unique_id(this); }

		public static int compare(GameListNode a, GameListNode b) {
			return strcmp(a.name, b.name);
		}

	}
}
