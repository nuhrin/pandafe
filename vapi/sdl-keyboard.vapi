[CCode (cprefix="SDL_", cheader_filename="SDL_keyboard.h")]
namespace SDL {
	[CCode (cname="SDL_EnableKeyRepeat")]
	public static int enable_key_repeat(int delay=DEFAULT_REPEAT_DELAY, int interval=DEFAULT_REPEAT_INTERVAL);
	[CCode (cname="SDL_GetKeyRepeat")]
	public static void get_key_repeat(out int delay, out int interval);

	public const string DEFAULT_REPEAT_DELAY;
	public const string DEFAULT_REPEAT_INTERVAL;
}
