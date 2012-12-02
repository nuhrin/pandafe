/* PlatformSelectorOverlay.vala
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
using SDL;
using SDLTTF;
using Layers.MenuBrowser;
using Layers.Controls;

namespace Layers.GameBrowser
{
	public class PlatformSelectorOverlay : SelectorOverlay<Platform>
	{
		public class PlatformSelectorOverlay(Platform? current_platform) {
			// get all platforms
			var folder_data = Data.platforms().get_platform_folder_data();
			var platforms = (folder_data.folders.size > 0)
				? folder_data.get_all_platforms().to_list()
				: Data.platforms().get_all_platforms().to_list();
			// find index of current_platform
			int found_index=-1;
			for(int index=0;index<platforms.size;index++) {
				var platform = platforms[index];
				if (found_index == -1 && current_platform != null && current_platform.id == platform.id)
					found_index = index;
			}
			uint selected_index = (found_index > 0) ? (uint)found_index : 0;
			base("Change Platform", "Select a new platform...", (MapFunc<string,Platform>)get_platform_name, platforms, selected_index);
			this.can_select_single_item = true;
		}
		static string get_platform_name(owned Platform platform) { return platform.name; }
		
		protected override string? get_selection_help(Platform selected_item) {
			return "Show %s games".printf(selected_item.name);
		}
	}
}
