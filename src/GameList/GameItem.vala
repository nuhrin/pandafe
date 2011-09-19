namespace Data.GameList
{
	public class GameItem : GameListNode
	{
		public GameItem(string name, GameListProvider provider, GameFolder parent, string? id=null, string? full_name=null) {
			base(name, provider, parent, id, full_name);
		}

		public uint run() { return provider.run_game(this); }

	}
}
