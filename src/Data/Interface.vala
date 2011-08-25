using Gee;
using Catapult;
using Data.Pnd;

namespace Data
{
	public DataInterface data_interface() { return Interface.instance().data_interface; }

	public Gee.List<Platform> platforms() { return Interface.instance().get_platforms(); }
	public void flush_platforms() { Interface.instance().flush_platforms(); }

	public Preferences preferences() { return Interface.instance().get_preferences(); }
	public bool save_preferences() { return Interface.instance().save_preferences(); }

	public GameBrowserState browser_state() { return Interface.instance().get_browser_state(); }
	public bool save_browser_state() { return Interface.instance().save_browser_state(); }

	public PndData pnd_data() { return Interface.instance().get_pnd_data(); }
	public PndData rescan_pnd_data() { return Interface.instance().rescan_pnd_data(); }

	public MountSet pnd_mountset() { return Interface.instance().get_mountset(); }

	public class Interface
	{
		static Interface _instance;
		public static Interface instance() {
			if (_instance == null)
				_instance = new Interface();
			return _instance;
		}

		public DataInterface data_interface { get; private set; }
		public Interface() {
			try {
				data_interface = new DataInterface("PandafeData");
			} catch (Error e) {
				error("Unable to create DataInterface instance: %s", e.message);
				//assert_not_reached();
			}
		}

		public Preferences get_preferences() {
			if (_preferences == null) {
				try {
					_preferences = data_interface.load<Preferences>(Preferences.ENTITY_ID, "");
				}
				catch (Error e) {
					debug("Error while retrieving preferences: %s", e.message);
					_preferences = new Preferences();
				}
			}
			return _preferences;
		}
		Preferences _preferences;
		public bool save_preferences() {
			var prefs = get_preferences();
			try {
				data_interface.save(prefs, Preferences.ENTITY_ID, "");
				return true;
			}
			catch (Error e) {
				debug("Error while saving preferences: %s", e.message);
			}
			return false;
		}

		public GameBrowserState get_browser_state() {
			if (_browser_state == null) {
				try {
					_browser_state = data_interface.load<GameBrowserState>(GameBrowserState.ENTITY_ID, "");
				}
				catch (Error e) {
					debug("Error while retrieving game browser state: %s", e.message);
					_browser_state = new GameBrowserState();
				}
			}
			return _browser_state;
		}
		GameBrowserState _browser_state;
		public bool save_browser_state() {
			var state = get_browser_state();
			try {
				data_interface.save(state, GameBrowserState.ENTITY_ID, "");
				return true;
			}
			catch (Error e) {
				debug("Error while saving game browser state: %s", e.message);
			}
			return false;
		}

		public Gee.List<Platform> get_platforms() {
			if (_platforms == null) {
				_platforms = new ArrayList<Platform>();
				var platform_ids = get_preferences().platform_order;
				foreach(var id in platform_ids) {
					try {
						var platform = data_interface.load<Platform>(id);
						if (platform.platform_type == PlatformType.ROM) {
							if (platform.rom_folder_root == null)
								platform.rom_folder_root = "";
							if (platform.rom_filespec == null)
								platform.rom_filespec = "*";
						}
						_platforms.add(platform);
					}
					catch (Error e) {
						debug("Error while retrieving platform '%s': %s", id, e.message);
					}
				}
			}
			return _platforms;
		}
		Gee.List<Platform> _platforms;

		public void flush_platforms() {
			_platforms = null;
		}

		public PndData get_pnd_data() {
			if (_pnd_data == null) {
				try {
					var cache = data_interface.load<PndCache>(PndData.CACHED_DATA_ID, PndData.CACHED_DATA_FOLDER);
					_pnd_data = new PndData(data_interface, cache);
				}
				catch (Error e) {
					debug("Error while retrieving pnd data: %s", e.message);
					return rescan_pnd_data();
				}
			}
			return _pnd_data;
		}
		PndData _pnd_data;
		public PndData rescan_pnd_data() {
			_pnd_data = new PndData(data_interface);
			_pnd_data.rescan();
			return _pnd_data;
		}

		public MountSet get_mountset() {
			if (_mountset_config == null)
				_mountset_config = new MountSet();
			return _mountset_config;
		}
		MountSet _mountset_config;

	}
}
