using SDL;
using SDLTTF;
using SDLImage;

public class MainClass: Object {
	public static int main (string[] args)
	{
		unowned SDL.Screen screen = inititialize_sdl();
		WindowManager.set_caption("Pandafe", "");
        
        ensure_pandafe_appdata(screen);        
		@interface = new InterfaceHelper(screen);
        new GameBrowser().run();

        SDL.quit();

		cleanup_cache();
 		return 0;
	}

    const int SCREEN_WIDTH = 800;
    const int SCREEN_HEIGHT = 480;
    const int SCREEN_DEPTH = 32;

	static unowned SDL.Screen inititialize_sdl() {
        if (SDL.init(InitFlag.VIDEO) == -1)
			GLib.error("Error initializing SDL: %s", SDL.get_error());
		if (SDL.enable_key_repeat() == -1)
			GLib.error("Error enabling key repeat: %s", SDL.get_error());

		unowned VideoInfo vidinfo = VideoInfo.get();
		bool needsFullscreenBlip = (vidinfo.current_w == SCREEN_WIDTH && vidinfo.current_h == SCREEN_HEIGHT);

		uint32 video_flags = SurfaceFlag.SWSURFACE | SurfaceFlag.NOFRAME;
		if (needsFullscreenBlip == true) {
			// initialize fullscreen to bring in front on xfce panel, etc
			video_flags = video_flags | SurfaceFlag.FULLSCREEN;
		}
		
        unowned SDL.Screen screen = Screen.set_video_mode(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_DEPTH, video_flags);
        if (screen == null)
            GLib.error("Error setting video mode %d:%d:%d: %s", SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_DEPTH, SDL.get_error());
		
		if (SDLTTF.init() == -1)
			GLib.error("Error initializing SDL_ttf: %s", SDL.get_error());				
		
		// show splash screen
		bool screen_needs_flip = false;
		var font = new Font(InterfaceHelper.FONT_MONO_DEFAULT, 20);
		if (font != null) {
			font.render("Pandafe " + Build.BUILD_VERSION, {255,255,255}).blit(null, screen, {50,50});
			screen_needs_flip = true;
		}		
		if (screen_needs_flip == true)
			screen.flip();				

		SDL.Cursor.show(0);

		if (needsFullscreenBlip == true) {
			// now leave fullscreen, to ensure fullscreen child windows work and for better compatibility with launched programs
			WindowManager.toggle_fullscreen(screen);
		}

		return screen;
	}

	static void ensure_pandafe_appdata(SDL.Screen* screen) {
		if (FileUtils.test(Build.LOCAL_CONFIG_DIR, FileTest.IS_DIR) == false) {
			if (FileUtils.test(Build.LOCAL_CONFIG_DIR, FileTest.EXISTS) == true)
				GLib.error("Local config directory '%s' exists but is not a directory.", Build.LOCAL_CONFIG_DIR);
		}
				
		// ensure appdata
		ensure_appdata_folder("fonts", false);
		var data_needs_update = determine_data_update_need();
		if (data_needs_update) {
			var font = new Font(InterfaceHelper.FONT_MONO_DEFAULT, 18);
			if (font != null) {
				font.render("Installing new and updated Program/Platform definitions...", {255,255,255}).blit(null, screen, {100,(int16)screen->h-40});
				screen->flip();
			}
			ensure_appdata_folder("Platform", false);
			// determine local platforms with settings that need merging on update
			var platforms_to_merge = Data.platforms().get_all_platforms()
				.of_type<Data.Platforms.RomPlatform>()
				.where(p=>p.rom_folder_root != null);
			// save user settings from local platforms
			var platform_rom_paths = new Gee.HashMap<string,string>();
			foreach(var platform in platforms_to_merge)
				platform_rom_paths[platform.id] = platform.rom_folder_root;			
			Data.platforms().clear_cache();

			// update Platform/Program definitions as appropriate
			ensure_appdata_folder("Platform", true, true);
			ensure_appdata_folder("Program", true, true);
			
			// merge previously saved user settings
			foreach(var id in platform_rom_paths.keys) {
				var platform = Data.platforms().get_platform(id) as Data.Platforms.RomPlatform;
				if (platform == null)
					continue;
				if (platform.rom_folder_root != platform_rom_paths[id]) {
					platform.rom_folder_root = platform_rom_paths[id];
					string? error;
					if (Data.platforms().save_platform(platform, id, out error) == false)
						warning("Error saving merged platform '%s': %s", id, error);					
				}
			}			
		} else {
			ensure_appdata_folder("Platform");
			ensure_appdata_folder("Program");
		}
		ensure_appdata_file("native_platform");
		ensure_appdata_file("platform_folders");
		

		// ensure preferences file
		if (ensure_appdata_file("preferences") == false)
			Data.save_preferences();
	}	
	static bool determine_data_update_need() {
		string path = Path.build_filename(Build.LOCAL_CONFIG_DIR, ".data-version-last-checked");
		if (FileUtils.test(path, FileTest.EXISTS) == true) {
			try {
				string last_checked_data_version = Build.BUILD_VERSION;
				if (FileUtils.get_contents(path, out last_checked_data_version) == true) {
					if (Build.BUILD_VERSION == last_checked_data_version)
						return false;					
				}
			} catch(GLib.Error e) {
				warning("Error reading %s: %s", path, e.message);
			}
		}
		try {
			FileUtils.set_contents(path, Build.BUILD_VERSION);
		} catch(GLib.Error e) {
			warning("Error writing %s: %s", path, e.message);
		}
		return true;
	}

	static void ensure_appdata_folder(string foldername, bool copy_files=true, bool force_update=false) {
		string target_path = Path.build_filename(Build.LOCAL_CONFIG_DIR, foldername);
		bool target_path_exists = (FileUtils.test(target_path, FileTest.IS_DIR) == true);
		if (target_path_exists) {
			if (force_update == false)
				return;			
		} else if (FileUtils.test(target_path, FileTest.EXISTS) == true) {
			GLib.error("Local config directory '%s' exists but is not a directory.", target_path);
		}				
		
		// check for source folder in the pkgconfigdir
		string source_path = Path.build_filename(Build.PACKAGE_DATADIR, foldername);
		if (FileUtils.test(source_path, FileTest.IS_DIR) == false)
			return;

		// create the target folder
		if (target_path_exists == false) {
			try {
				if (File.new_for_path(target_path).make_directory_with_parents() == false)
					GLib.error("Local config directory '%s' could not be created.", target_path);
			} catch(GLib.Error e) {
				GLib.error("Error creating local config directory '%s': %s", target_path, e.message);
			}
		}
		
		if (copy_files == false)
			return;
			
		// copy all source folder files to local target folder, replacing target file if source file is newer
		try {
			var enumerator = File.new_for_path(source_path).enumerate_children("%s,%s".printf(FileAttribute.STANDARD_NAME, FileAttribute.TIME_MODIFIED), FileQueryInfoFlags.NONE);
			FileInfo source_info;
			while ((source_info = enumerator.next_file()) != null) {
				var name = source_info.get_name();
				var source = File.new_for_path(Path.build_filename(source_path, name));
				var destination = File.new_for_path(Path.build_filename(target_path, name));
				var destination_ok = destination.query_exists();
				if (destination_ok)
					destination_ok = file_is_newer(destination.query_info(FileAttribute.TIME_MODIFIED, FileQueryInfoFlags.NONE), source_info);
				if (destination_ok == false)
					source.copy(destination, FileCopyFlags.NOFOLLOW_SYMLINKS | FileCopyFlags.OVERWRITE);
			}
		}
		catch(GLib.Error e)
		{
			warning("Error while populating local config directory '%s': %s", target_path, e.message);
		}
	}
	static bool file_is_newer(FileInfo a, FileInfo b) {
		return (a.get_modification_time().tv_sec > b.get_modification_time().tv_sec);
	}
	
	static bool ensure_appdata_file(string filename) {
		string target_path = Path.build_filename(Build.LOCAL_CONFIG_DIR, filename);
		if (FileUtils.test(target_path, FileTest.IS_REGULAR) == true)
			return true;
		if (FileUtils.test(target_path, FileTest.EXISTS) == true)
			GLib.error("Local config file '%s' exists but is not a regular file.", target_path);
		
		// check for source file in the pkgconfigdir
		string source_path = Path.build_filename(Build.PACKAGE_DATADIR, filename);
		if (FileUtils.test(source_path, FileTest.IS_REGULAR) == false)
			return false;
		
		// copy source file to local target file
		try {
			var source = File.new_for_path(source_path);
			var destination = File.new_for_path(target_path);
			source.copy(destination, FileCopyFlags.NOFOLLOW_SYMLINKS);
			return true;
		}
		catch(GLib.Error e)
		{
			warning("Error while populating local config file '%s': %s", target_path, e.message);
		}
		return false;
	}
	
		
	static void cleanup_cache() {
		string gamelistcache_path = Path.build_filename(Build.LOCAL_CONFIG_DIR, Data.GameList.GameFolder.YAML_FOLDER_ROOT);
		if (FileUtils.test(gamelistcache_path, FileTest.EXISTS) == true) {
			try {
				var platform_ids = Data.platforms().get_all_platforms().select<string>(p=>p.id).to_list();
				var directory = File.new_for_path(gamelistcache_path);
				var enumerator = directory.enumerate_children("standard::*", FileQueryInfoFlags.NONE);
				FileInfo file_info;
				while ((file_info = enumerator.next_file ()) != null) {
					var type = file_info.get_file_type();
					var name = file_info.get_name();
					if (name.has_prefix(".") == true)
						continue;
					if (type == FileType.DIRECTORY) {
						if (platform_ids.contains(name) == false) {
							var unmatched_directory = File.new_for_path(Path.build_filename(gamelistcache_path, name));
							Utility.remove_directory_recursive(unmatched_directory);
						}
					}
				}
			}
			catch(GLib.Error e)
			{
				warning("Error while cleaning up gamelist cache folder: %s", e.message);
			}
		}
	}
}
