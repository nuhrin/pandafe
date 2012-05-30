using Data.Platforms;

namespace Data
{
	public enum GameBrowserViewType {
		BROWSER,
		FAVORITES,
		MOST_RECENT,
		MOST_PLAYED,
		ALL_GAMES,
		PLATFORM_FOLDER
	}
	public class GameBrowserViewData {
		string _name;
		public GameBrowserViewData(GameBrowserViewType view_type) {
			this.view_type = view_type;
			switch(view_type) {
				case GameBrowserViewType.BROWSER:
					_name = "Browser";
					break;
				case GameBrowserViewType.FAVORITES:
					_name = "Favorites";
					break;
				case GameBrowserViewType.MOST_RECENT:
					_name = "Most Recent";
					break;
				case GameBrowserViewType.MOST_PLAYED:
					_name = "Most Played";
					break;
				case GameBrowserViewType.ALL_GAMES:
					_name = "All Games";
					break;
				default:
					GLib.error("Unsupported GameBrowserViewType");
			}
		}
		public GameBrowserViewData.folder(PlatformFolder folder) {
			_name = folder.path();
			view_type = GameBrowserViewType.PLATFORM_FOLDER;
			platform_folder = folder;
		}
		public unowned string name { get { return _name; } }
		public GameBrowserViewType view_type { get; private set; }
		public PlatformFolder? platform_folder { get; private set; }
		
		public bool equals(GameBrowserViewData? other) {
			if (other == null)
				return false;
			if (view_type != GameBrowserViewType.PLATFORM_FOLDER)
				return (view_type == other.view_type);
				
			if (other.platform_folder == null)
				return false;
			
			return (platform_folder.path() == other.platform_folder.path());				
		}
	}
}
