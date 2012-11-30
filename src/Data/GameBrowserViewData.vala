using Data.Platforms;

namespace Data
{
	public enum GameBrowserViewType {
		ALL_GAMES,
		FAVORITES,
		MOST_RECENT,
		MOST_PLAYED,
		PLATFORM,
		PLATFORM_LIST,
		PLATFORM_FOLDER
	}
	public class GameBrowserViewData {
		string _name;
		string _help;
		bool _involves_everything;
		public GameBrowserViewData(GameBrowserViewType view_type) {
			this.view_type = view_type;
			switch(view_type) {
				case GameBrowserViewType.ALL_GAMES:
					_name = "All Games";
					_help = "Show all games";
					_involves_everything = true;
					break;
				case GameBrowserViewType.FAVORITES:
					_name = "Favorites";
					_help = "Show games marked as favorites";
					_involves_everything = true;
					break;
				case GameBrowserViewType.MOST_RECENT:
					_name = "Most Recent";
					_help = "Show games played, ordered by when last played";
					_involves_everything = true;
					break;
				case GameBrowserViewType.MOST_PLAYED:
					_name = "Most Played";
					_help = "Show games played, ordered by play count";
					_involves_everything = true;
					break;
				case GameBrowserViewType.PLATFORM:
					_name = "Platform";
					_help = "Show games for the current platform";
					break;
				case GameBrowserViewType.PLATFORM_LIST:
					_name = "Platform List";
					_help = "Show list of all (enabled) platforms";
					break;
				case GameBrowserViewType.PLATFORM_FOLDER:
					_name = "Platform Folders";
					_help = "Show grouped list of platforms";
					break;
				default:
					GLib.error("Unsupported GameBrowserViewType");
			}
		}
		public GameBrowserViewType view_type { get; private set; }
		public unowned string name { get { return _name; } }
		public unowned string help { get { return _help; } }
		public bool involves_everything { get { return _involves_everything; } }
		
		public bool equals(GameBrowserViewData? other) {
			if (other == null)
				return false;
			return (view_type == other.view_type);			
		}
	}
}
