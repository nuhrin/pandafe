using SDL;
using SDLTTF;

public class MainClass: Object {
	//static Options options;
	public static int main (string[] args)
	{
//~ 		try {
//~ 			options = Options.parse(ref args);
//~ 		} catch(OptionError e) {
//~ 			print("%s\n", e.message);
//~ 			return 1;
//~ 		}
//~ //		if (options.Testset != null) {
//~ //		TestRunner.run_requested_tests(options);
//~ //		return 0;
//~ //		}
//~

//		test_app_categories();
//		return 0;

		ensure_pandafedata_folder();

		unowned SDL.Screen screen = inititialize_sdl();
		WindowManager.set_caption("Pandafe", "");
		InterfaceHelper @interface = new InterfaceHelper(screen);
        new GameBrowser(@interface).run();

        SDL.quit();

 		return 0;
	}
    const int SCREEN_WIDTH = 800;
    const int SCREEN_HEIGHT = 480;
    const int SCREEN_DEPTH = 32;

	static unowned SDL.Screen inititialize_sdl() {
        if (SDL.init(InitFlag.VIDEO) == -1)
			GLib.error("Error initializing SDL: %s", SDL.get_error());

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

		if (SDL.enable_key_repeat() == -1)
			GLib.error("Error enabling key repeat: %s", SDL.get_error());

		if (needsFullscreenBlip == true) {
			// now leave fullscreen, to ensure fullscreen child windows work and for better compatibility with launched programs
			WindowManager.toggle_fullscreen(screen);
		}

		return screen;
    }

	static void ensure_pandafedata_folder() {
		if (FileUtils.test(Config.LOCAL_CONFIG_DIR, FileTest.IS_DIR) == false) {
			if (FileUtils.test(Config.LOCAL_CONFIG_DIR, FileTest.EXISTS) == true)
				GLib.error("Local config directory '%s' exists but is not a directory.", Config.LOCAL_CONFIG_DIR);
		}
		string platforms_path = Path.build_filename(Config.LOCAL_CONFIG_DIR, "Platform");
		if (FileUtils.test(platforms_path, FileTest.IS_DIR) == true)
			return;

		if (FileUtils.test(platforms_path, FileTest.EXISTS) == true)
			GLib.error("Local config directory '%s' exists but is not a directory.", platforms_path);

		// check for default platforms in the pkgconfigdir
		string package_platforms_path = Path.build_filename(Config.PACKAGE_DATADIR, "Platform");
		if (FileUtils.test(package_platforms_path, FileTest.IS_DIR) == false)
			return;

		// create the local Platform folder
		try {
			if (File.new_for_path(platforms_path).make_directory_with_parents() == false)
				GLib.error("Local config directory '%s' could not be created.", platforms_path);
		} catch(GLib.Error e) {
			GLib.error("Error creating local config directory '%s': %s", platforms_path, e.message);
		}

		// copy all package platforms to local Platform folder
		try {
			var enumerator = File.new_for_path(package_platforms_path).enumerate_children(FILE_ATTRIBUTE_STANDARD_NAME, FileQueryInfoFlags.NONE);
			FileInfo file_info;
			while ((file_info = enumerator.next_file()) != null) {
				var name = file_info.get_name();
				var source = File.new_for_path(Path.build_filename(package_platforms_path, name));
				var destination = File.new_for_path(Path.build_filename(platforms_path, name));
				source.copy(destination, FileCopyFlags.NONE);
			}
		}
		catch(GLib.Error e)
		{
			debug("Error while populating local config directory '%s': %s", platforms_path, e.message);
		}

		// create preferences file
		Data.save_preferences();
	}
}
