using Gee;
using Catapult;

namespace Data.GameList
{
	public class GameFolder : GameListNode
	{
		ArrayList<GameFolder> _child_folders;
		ArrayList<GameItem> _child_games;
		bool children_scanned = false;

		public GameFolder(string name, GameListProvider provider, GameFolder? parent) {
			base(name, provider, parent);
		}
		public GameFolder.root(string name, GameListProvider provider, string id) {
			base(name, provider, null, id);
		}

		public int child_count() {
			ensure_children();
			return ((_child_folders != null) ? _child_folders.size : 0) + ((_child_games != null) ? _child_games.size : 0);
		}

		public Enumerable<GameListNode> children()
		{
			return child_folders().concat(child_games());
		}

		public Enumerable<GameFolder> child_folders() {
			ensure_children();
			if (_child_folders == null)
				return Enumerable.empty<GameFolder>();
			return new Enumerable<GameFolder>(_child_folders);
		}
		public Enumerable<GameItem> child_games() {
			ensure_children();
			if (_child_games == null)
				return Enumerable.empty<GameItem>();
			return new Enumerable<GameItem>(_child_games);
		}

		public Enumerable<GameFolder> all_subfolders() {
			var all = child_folders();

			foreach(var folder in child_folders())
				all = all.concat(folder.all_subfolders());

			return all;
		}

		public Enumerable<GameItem> all_games() {
			var all = Enumerable.empty<GameItem>();

			foreach(var folder in child_folders())
				all = all.concat(folder.all_games());

			return all.concat(child_games());
		}

		void ensure_children() {
			if (children_scanned == true)
				return;
			provider.get_children(this, out _child_folders, out _child_games);
			children_scanned = true;
		}
	}
}
