using Gee;
using Catapult;
using Data.GameList;
using Data.Pnd;

namespace Data.Platforms
{
	public class PlatformProvider : EntityProvider<Platform>
	{		
		public const string NATIVE_PLATFORM_ID = "native_platform";
		public const string PLATFORM_FOLDER_ID = "platform_folders";
		HashMap<string,Platform> platform_id_hash;
		Gee.List<Platform> all_platforms;
		public PlatformProvider(string root_folder) throws RuntimeError
		{
			base(root_folder);			
		}
		
		public signal void platform_folders_changed();
		public signal void platform_rescanned(Platform platform);
		public signal void platform_folder_scanned(GameFolder folder);
		
		public Enumerable<Platform> get_all_platforms() {
			if (all_platforms == null) {
				ensure_platforms();
				all_platforms = new ArrayList<Platform>();
				all_platforms.add(get_native_platform());
				all_platforms = new Enumerable<Platform>(all_platforms)
					.concat(new Enumerable<Platform>(platform_id_hash.values))
					.sort((a,b) => a.name.casefold().collate(b.name.casefold()))
					.to_list();				
			}
			return new Enumerable<Platform>(all_platforms);
		}		
		
		public PlatformFolderData get_platform_folder_data() {
			if (_platform_folders == null) {
				try {
					_platform_folders = Data.data_interface().load<PlatformFolderData>(PLATFORM_FOLDER_ID, "");
				} catch(Error e) {
					if ((e is RuntimeError.FILE) == false)
						debug("Error while retrieving platform folder data: %s", e.message);
					_platform_folders = null;
				}
				if (_platform_folders == null)
					_platform_folders = new PlatformFolderData();				
			}
			return _platform_folders;
		}
		PlatformFolderData _platform_folders;
		public bool save_platform_folder_data(out string? error) {
			error = null;
			try {
				Data.data_interface().save(get_platform_folder_data(), PLATFORM_FOLDER_ID, "");
				platform_folders_changed();
				return true;
			}
			catch (Error e) {
				error = e.message;
			}
			return false;
		}
				
		public NativePlatform get_native_platform() {
			if (_native_platform == null) {
				try {
					_native_platform = Data.data_interface().load<NativePlatform>(NATIVE_PLATFORM_ID, "");
				}
				catch (Error e) {
					if ((e is RuntimeError.FILE) == false)
						debug("Error while retrieving native platform: %s", e.message);
					_native_platform = null;
				}
				if (_native_platform == null) {
					_native_platform = new NativePlatform();
					_native_platform.categories.add(new NativePlatformCategory() { name = "Game" });
					try {
						Data.data_interface().save(get_native_platform(), NATIVE_PLATFORM_ID, "");
					}
					catch (Error e) {
					}
				}
				_native_platform.rescanned.connect(() => platform_rescanned(_native_platform));
				_native_platform.folder_scanned.connect(folder => platform_folder_scanned(folder));
			}
			return _native_platform;
		}
		NativePlatform _native_platform;
		public bool save_native_platform(out string? error, owned ForallFunc<GameFolder>? pre_scan_action=null) {
			error = null;
			try {
				var platform = get_native_platform();
				Data.data_interface().save(platform, NATIVE_PLATFORM_ID, "");
				platform.rescan((owned)pre_scan_action);
				return true;
			}
			catch (Error e) {
				error = e.message;
			}
			return false;
		}
		
		public Platform? get_platform(string id) {
			if (id == NATIVE_PLATFORM_ID)
				return get_native_platform();
			ensure_platforms();
			if (platform_id_hash.has_key(id) == true)
				return platform_id_hash[id];
			return null;
		}
		
		public bool save_platform(Platform platform, string id, out string? error, owned ForallFunc<GameFolder>? pre_scan_action=null) {
			if (platform.platform_type == PlatformType.NATIVE)
				GLib.error("NativePlatform instance cannot be saved in this fashion. Use save_native_platform().");
			error = null;
			if (id.strip() == "") {
				error = "Bad platform id";
				return false;
			}
			if (platform.id != id && platform_id_hash.has_key(id) == true) {
				error = "Conflict with existing platform (id %s)".printf(id);
				return false;
			}
						
			string? original_id = platform.id;
			if (original_id != null && original_id != id) {
				// safe rename: remove existing platform
				try {
					remove(platform);
				} catch {
				}				
			}
			
			try {
				save(platform, id);
			} catch(Error e) {
				error = e.message;
				return false;				
			}

			if (original_id == null) {
				// newly saved
				platform.rescanned.connect(() => platform_rescanned(platform));
				platform.folder_scanned.connect(folder => platform_folder_scanned(folder));
			} else if (platform_id_hash.has_key(original_id) == true) {
				platform_id_hash.unset(original_id);
			}
			
			platform_id_hash[id] = platform;
			all_platforms = null;
			
			// rebuild platform folders
			platform.rebuild_folders((owned)pre_scan_action);
			return true;
		}
		public bool remove_platform(Platform platform, out string? error) {
			error = null;
			try {
				remove(platform);
				platform_id_hash.unset(platform.id);
				all_platforms = null;
				return true;
			} catch(Error e) {
				error = e.message;
			}
			return false;
		}
		
		protected override Entity? get_entity(string entity_id) {
			return get_platform(entity_id);			
		}
		
		void ensure_platforms() {
			if (platform_id_hash != null)
				return;
			platform_id_hash = new HashMap<string,Platform>();
			Enumerable<Platform> platforms = null;
			try {
				platforms = load_all(false);
			} catch(Error e) {
			}
			foreach(var platform in platforms) {
				platform_id_hash[platform.id] = platform;
				platform.rescanned.connect(() => platform_rescanned(platform));
				platform.folder_scanned.connect(folder => platform_folder_scanned(folder));
			}
		}
	}	
}
