namespace Data.GameList
{
	public interface IGameListNode : Object
	{
		protected abstract GameListProvider provider { get; }
		public abstract GameFolder? parent { get; }

		public abstract string id { get; }
		public abstract string name { get; }
		public abstract string full_name { get; }

		public string unique_id() { return provider.get_unique_id(this); }
		public Platform platform() { return provider.platform; }

		public static int compare(IGameListNode a, IGameListNode b) {
			return a.name.ascii_casecmp(b.name);
		}
	}
}
