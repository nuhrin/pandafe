/* gobject-patch.vapi
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

[CCode (cprefix = "G", lower_case_cprefix = "g_", cheader_filename = "glib.h", gir_namespace = "GObject", gir_version = "2.0")]
namespace GLibPatch {
	[CCode (lower_case_csuffix = "flags")]
  	public class FlagsClass : GLib.TypeClass {
    	public unowned FlagsValue? get_first_value (uint value);
    	public unowned FlagsValue? get_value_by_name (string name);
    	public unowned FlagsValue? get_value_by_nick (string name);
    	public uint mask;
    	public uint n_values;
    	[CCode (array_length_cname = "n_values")]
    	public FlagsValue[] values;
	}

	[CCode (has_type_id = false)]
	public struct FlagsValue {
    	public int value;
    	public unowned string value_name;
    	public unowned string value_nick;
  	}
}
