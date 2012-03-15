using Data.Platforms;

namespace Data
{
	public enum GameBrowserViewType {
		BROWSER,
		FAVORITES,
		ALL_GAMES,
		PLATFORM_FOLDER_GAMES
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
				case GameBrowserViewType.ALL_GAMES:
					_name = "All Games";
					break;
				default:
					GLib.error("Unsupported GameBrowserViewType");
			}
		}
		public GameBrowserViewData.folder(PlatformFolder folder) {
			_name = "All %s Games".printf(folder.path());
			view_type = GameBrowserViewType.PLATFORM_FOLDER_GAMES;
			platform_folder = folder;
		}
		public unowned string name { get { return _name; } }
		public GameBrowserViewType view_type { get; private set; }
		public PlatformFolder? platform_folder { get; private set; }
		
		public bool equals(GameBrowserViewData? other) {
			if (other == null)
				return false;
			if (view_type != GameBrowserViewType.PLATFORM_FOLDER_GAMES)
				return (view_type == other.view_type);
				
			if (other.platform_folder == null)
				return false;
			
			return (platform_folder.path() == other.platform_folder.path());				
		}
	}
}
