/* build-info.vapi
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

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "build-info.h")]
namespace Build {
	public const string PACKAGE_DATADIR;
	public const bool IS_PND;
	
	[CCode (cheader_filename = "config.h")]
	public const string PND_APP_ID;
	[CCode (cheader_filename = "version.h")]
	public const string BUILD_VERSION;		
}
