using Gee;
using Catapult;

namespace Data.GameList
{
	public abstract class GameListProvider
	{
		public GameFolder root_folder {
			get {
				if (_root == null)
					_root = create_root_folder();
				return _root;
			}
		}
		GameFolder _root;

		public abstract bool run_game(GameItem game);

		public abstract bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games);
		public abstract string get_unique_id(GameListNode node);

		protected abstract GameFolder create_root_folder();
	}
}
