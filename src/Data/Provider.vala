using Gee;
using Catapult;
using Data.Pnd;

namespace Data
{
	public DataInterface data_interface() { return Provider.instance().data_interface; }

	public Gee.List<Platform> platforms() { return Provider.instance().get_platforms(); }
	public NativePlatform native_platform() { return Provider.instance().get_native_platform(); }
	public bool save_native_platform() { return Provider.instance().save_native_platform(); }
	public void flush_platforms() { Provider.instance().flush_platforms(); }

	public Preferences preferences() { return Provider.instance().get_preferences(); }
	public bool save_preferences() { return Provider.instance().save_preferences(); }

	public GameBrowserState browser_state() { return Provider.instance().get_browser_state(); }
	public bool save_browser_state() { return Provider.instance().save_browser_state(); }

	public PndData pnd_data() { return Provider.instance().get_pnd_data(); }
	public PndData rescan_pnd_data() { return Provider.instance().rescan_pnd_data(); }

	public MountSet pnd_mountset() { return Provider.instance().get_mountset(); }

	public class Provider
	{
		static Provider _instance;
		public static Provider instance() {
			if (_instance == null)
				_instance = new Provider();
			return _instance;
		}

		public DataInterface data_interface { get; private set; }
		public Provider() {
			try {
				data_interface = new DataInterface(Config.LOCAL_CONFIG_DIR);
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
				if (platform_ids.size == 0) {
					try {
						_platforms = data_interface.load_all<Platform>()
							.sort((a,b) => strcmp(a.name, b.name))
							.to_list();
						_platforms.insert(0, get_native_platform());
					} catch (Error e) {
						debug("Error while loading platforms: %s", e.message);
					}
					return _platforms;
				}
				foreach(var id in platform_ids) {
					try {
						if (id == NativePlatform.ENTITY_ID) {
							_platforms.add(get_native_platform());
							continue;
						}
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
						debug("Error while loading platform '%s': %s", id, e.message);
					}
				}
			}
			return _platforms;
		}
		Gee.List<Platform> _platforms;

		public NativePlatform get_native_platform() {
			if (_native_platform == null) {
				try {
					debug("try load native_platform");
					_native_platform = data_interface.load<NativePlatform>(NativePlatform.ENTITY_ID, "");
					debug("finished loading native_platform");
				}
				catch (Error e) {
					debug("Error while retrieving native platform: %s", e.message);
					_native_platform = null;
				}
				if (_native_platform == null) {
					_native_platform = new NativePlatform();
					_native_platform.categories.add(new NativePlatformCategory() { name = "Games" });
					save_native_platform();
				}
			}
			return _native_platform;
		}
		NativePlatform _native_platform;
		public bool save_native_platform() {
			var platform = get_native_platform();
			try {
				data_interface.save(platform, NativePlatform.ENTITY_ID, "");
				return true;
			}
			catch (Error e) {
				debug("Error while saving native platform: %s", e.message);
			}
			return false;
		}
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
