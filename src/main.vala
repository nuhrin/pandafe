using SDL;
using SDLTTF;
using SDLImage;

public class MainClass: Object {
	public static int main (string[] args)
	{
		ensure_pandafe_appdata();

		unowned SDL.Screen screen = inititialize_sdl();
		WindowManager.set_caption("Pandafe", "");
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
			font.render("Pandafe", {255,255,255}).blit(null, screen, {50,50});
			screen_needs_flip = true;
		}		
		if (SDLImage.init(0) == -1)
			GLib.error("Error initializing SDL_image: %s", SDL.get_error());
		var banner = SDLImage.read_xpm(Banner.BANNER_XPM);
		if (banner != null) {
			banner.blit(null, screen, {0, (int16)(screen.h - banner.h)});
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

	static void ensure_pandafe_appdata() {
		if (FileUtils.test(Config.LOCAL_CONFIG_DIR, FileTest.IS_DIR) == false) {
			if (FileUtils.test(Config.LOCAL_CONFIG_DIR, FileTest.EXISTS) == true)
				GLib.error("Local config directory '%s' exists but is not a directory.", Config.LOCAL_CONFIG_DIR);
		}
		// ensure appdata
		ensure_appdata_folder("fonts", false);
		ensure_appdata_folder("Platform");
		ensure_appdata_folder("Program");
		ensure_appdata_file("native_platform");
		ensure_appdata_file("platform_folders");
		

		// ensure preferences file
		if (ensure_appdata_file("preferences") == false)
			Data.save_preferences();
	}
	static void ensure_appdata_folder(string foldername, bool copy_files=true) {
		string target_path = Path.build_filename(Config.LOCAL_CONFIG_DIR, foldername);
		if (FileUtils.test(target_path, FileTest.IS_DIR) == true)
			return;
		if (FileUtils.test(target_path, FileTest.EXISTS) == true)
			GLib.error("Local config directory '%s' exists but is not a directory.", target_path);

		// check for source folder in the pkgconfigdir
		string source_path = Path.build_filename(Config.PACKAGE_DATADIR, foldername);
		if (FileUtils.test(source_path, FileTest.IS_DIR) == false)
			return;

		// create the target folder
		try {
			if (File.new_for_path(target_path).make_directory_with_parents() == false)
				GLib.error("Local config directory '%s' could not be created.", target_path);
		} catch(GLib.Error e) {
			GLib.error("Error creating local config directory '%s': %s", target_path, e.message);
		}
	
		if (copy_files == false)
			return;
			
		// copy all source folder files to local target folder
		try {
			var enumerator = File.new_for_path(source_path).enumerate_children(FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE);
			FileInfo file_info;
			while ((file_info = enumerator.next_file()) != null) {
				var name = file_info.get_name();
				var source = File.new_for_path(Path.build_filename(source_path, name));
				var destination = File.new_for_path(Path.build_filename(target_path, name));
				source.copy(destination, FileCopyFlags.NOFOLLOW_SYMLINKS);
			}
		}
		catch(GLib.Error e)
		{
			debug("Error while populating local config directory '%s': %s", target_path, e.message);
		}
	}
	static bool ensure_appdata_file(string filename) {
		string target_path = Path.build_filename(Config.LOCAL_CONFIG_DIR, filename);
		if (FileUtils.test(target_path, FileTest.IS_REGULAR) == true)
			return true;
		if (FileUtils.test(target_path, FileTest.EXISTS) == true)
			GLib.error("Local config file '%s' exists but is not a regular file.", target_path);
		
		// check for source file in the pkgconfigdir
		string source_path = Path.build_filename(Config.PACKAGE_DATADIR, filename);
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
			debug("Error while populating local config file '%s': %s", target_path, e.message);
		}
		return false;
	}
	
	static void cleanup_cache() {
		string gamelistcache_path = Path.build_filename(Config.LOCAL_CONFIG_DIR, Data.GameList.GameFolder.YAML_FOLDER_ROOT);
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
				debug("Error while cleaning up gamelist cache folder: %s", e.message);
			}
		}
	}
}
