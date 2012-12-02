/* sdl-keyboard.vapi
 * 
 * Copyright (C) 2012 nuhrin
 * 
 * This file is part of Pandafe.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *      nuhrin <nuhrin@oceanic.to>
 */

[CCode (cprefix="SDL_", cheader_filename="SDL_keyboard.h")]
namespace SDL {
	[CCode (cname="SDL_EnableKeyRepeat")]
	public static int enable_key_repeat(int delay=DEFAULT_REPEAT_DELAY, int interval=DEFAULT_REPEAT_INTERVAL);
	[CCode (cname="SDL_GetKeyRepeat")]
	public static void get_key_repeat(out int delay, out int interval);

	public const int DEFAULT_REPEAT_DELAY;
	public const int DEFAULT_REPEAT_INTERVAL;
}
