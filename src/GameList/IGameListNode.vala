namespace Data.GameList
{
	public interface IGameListNode : Object, Gee.Comparable<IGameListNode>
	{
		protected abstract GameListProvider provider { get; }
		public abstract GameFolder? parent { get; }

		public abstract string id { get; }
		public abstract string name { get; }
		public abstract string full_name { get; }

		public string unique_id() { return provider.get_unique_id(this); }
		public Platform platform() { return provider.platform; }
	}
}
