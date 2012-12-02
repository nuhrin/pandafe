/* PlatformNode.vala
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

using Gee;
using Catapult;
using Fields;
using Menus;
using Menus.Fields;

namespace Data.Platforms
{
	public class PlatformNode : Object, PlatformListNode
	{
		PlatformFolder _parent;
		public PlatformNode(Platform platform, PlatformFolder? parent) {
			this.platform = platform;
			_parent = parent;
		}
		
		public string name { 
			get { return platform.name; }
			set { assert_not_reached(); }
		}
		
		public Platform platform { get; private set; }		
		public PlatformFolder? parent { get { return _parent; } }
	}
}
