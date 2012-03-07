using Gee;
using Catapult;

namespace Data.GameList
{
	public class GameFolder : Object, Gee.Comparable<IGameListNode>, IGameListNode
	{
		public const string YAML_FOLDER_ROOT = "GameListCache";

		string? _id;
		string _name;
		GameListProvider _provider;
		GameFolder? _parent;
		ArrayList<GameFolder> _child_folders;
		ArrayList<GameItem> _child_games;
		bool children_loaded = false;

		public GameFolder(string name, GameListProvider provider, GameFolder? parent) {
			_name = name;
			_provider = provider;
			_parent = parent;
		}
		public GameFolder.root(string name, GameListProvider provider, string? id=null) {
			_name = name;
			_provider = provider;
			_id = id;
		}

		protected GameListProvider provider { get { return _provider; } }
		public GameFolder? parent { get { return _parent; } }

		public string id { get { return (_id != null) ? _id : _name; } }
		public string name { get { return _name; } }
		public string full_name { get { return _name; } }

		public int child_count() {
			ensure_children();
			return ((_child_folders != null) ? _child_folders.size : 0) + ((_child_games != null) ? _child_games.size : 0);
		}

		public int compare_to(IGameListNode other) {
			return Utility.strcasecmp(this.name, other.name);
		}

		public Enumerable<IGameListNode> children() {
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
		public GameFolder? get_descendant_folder(string unique_name) {
			foreach(var folder in all_subfolders()) {
				if (folder.unique_name() == unique_name)
					return folder;
			}
			return null;
		}
		public GameFolder? get_descendant_folder_by_id(string unique_id) {
			foreach(var folder in all_subfolders()) {
				if (folder.unique_id() == unique_id)
					return folder;
			}
			return null;
		}

		public Enumerable<GameItem> all_games() {
			var all = Enumerable.empty<GameItem>();

			foreach(var folder in child_folders())
				all = all.concat(folder.all_games());

			return all.concat(child_games());
		}

		public signal void rescanned();
		public void rescan_children(bool recursive=false, owned ForallFunc<GameFolder>? pre_scan_action=null) {
			if (children_loaded == false)
				load_children_yaml();
			scan_children(recursive, (owned)pre_scan_action);
		}
		public void update_cache() {
			var cache = new GameFolderCache();
			if (_child_folders != null) {
				foreach(var subfolder in _child_folders)
					cache.subfolders.add(subfolder._name);
			}
			if (_child_games != null)
				cache.games = _child_games;

			// attempt to save
			try {
				Data.data_interface().save(cache, GameFolderCache.YAML_ID, get_yaml_folder());
			} catch(Error e) {
				debug("Error saving cache for folder '%s': %s", get_yaml_folder(), e.message);
			}
		}

		void ensure_children() {
			if (children_loaded == true)
				return;
			if (load_children_yaml() == false)
				scan_children(false);
		}
		bool load_children_yaml() {
			var folder_path = get_yaml_folder();
			GameFolderCache cache = null;
			try {
				cache = Data.data_interface().load<GameFolderCache>(GameFolderCache.YAML_ID, folder_path);
			} catch(Error e) {
				//debug("Error loading cache for folder '%s': %s", folder_path, e.message);
			}
			if (cache == null)
				return false;

			if (cache.subfolders.size == 0) {
				_child_folders = null;
			} else {
				_child_folders = new ArrayList<GameFolder>();
				foreach(var subfolder in cache.subfolders) {
					_child_folders.add(new GameFolder(subfolder, _provider, this));
				}
			}
			if (cache.games.size == 0) {
				_child_games = null;
			} else {
				_child_games = cache.games;
				foreach(var game in _child_games) {
					GameItem.set_provider(game, _provider);
					GameItem.set_parent(game, this);
				}
			}

			children_loaded = true;
			return true;
		}
		void scan_children(bool recursive, owned ForallFunc<GameFolder>? pre_scan_action=null) {
			if (pre_scan_action != null)
				pre_scan_action(this);
			
			ArrayList<GameItem> games;
			provider.scan_children(this, out _child_folders, out games);
			// todo: reapply game settings from already loaded games, once thats present
			_child_games = games;

			update_cache();
			children_loaded = true;
			rescanned();
			
			if (recursive == true && _child_folders != null) {
				foreach(var subfolder in _child_folders)
					subfolder.scan_children(true, (owned)pre_scan_action);
			}
		}

		string get_yaml_folder() {
			if (_yaml_folder == null) {
				_yaml_folder = (_parent == null)
					? Path.build_filename(YAML_FOLDER_ROOT, provider.platform.id)
					: Path.build_filename(_parent.get_yaml_folder(), name);
			}
			return _yaml_folder;
		}
		string _yaml_folder;
	}
}
