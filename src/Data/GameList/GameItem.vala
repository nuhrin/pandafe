namespace Data.GameList
{
	public class GameItem : GameListNode
	{
		public GameItem(string name, GameListProvider provider, GameFolder parent, string? id=null) {
			base(name, provider, parent, id);
		}

		public uint run() { return provider.run_game(this); }

	}
}
