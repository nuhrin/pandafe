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

//		test_romlist(args);
//		return 0;

		unowned SDL.Screen screen = inititialize_sdl();
        new GameBrowser(screen).run();

        SDL.quit();

 		return 0;
	}
    const int SCREEN_WIDTH = 800;
    const int SCREEN_HEIGHT = 480;
    const int SCREEN_DEPTH = 32;


	static unowned SDL.Screen inititialize_sdl() {
        if (SDL.init(InitFlag.VIDEO) == -1)
			GLib.error("Error initializing SDL: %s", SDL.get_error());

		uint32 video_flags = SurfaceFlag.SWSURFACE | SurfaceFlag.NOFRAME;
        unowned SDL.Screen screen = Screen.set_video_mode(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_DEPTH, video_flags);
        if (screen == null)
            GLib.error("Error setting video mode %d:%d:%d: %s", SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_DEPTH, SDL.get_error());

		if (SDLTTF.init() == -1)
			GLib.error("Error initializing SDL_ttf: %s", SDL.get_error());

		if (SDL.enable_key_repeat() == -1)
			GLib.error("Error enabling key repeat: %s", SDL.get_error());

		return screen;
    }

}
