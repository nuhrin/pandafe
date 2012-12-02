/* PlatformProgramSettingsMap.vala
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
using Data.Programs;

namespace Data.Platforms
{
	public class PlatformProgramSettingsMap :  HashMap<string,ProgramDefaultSettings>, IYamlObject
	{
		public PlatformProgramSettingsMap() {
			base();
		}
		public PlatformProgramSettingsMap.clone(PlatformProgramSettingsMap basis) {
			this();
			foreach(var key in basis.keys) {
				var settings = basis[key];
				var new_settings = new ProgramDefaultSettings();
				new_settings.merge_override(settings);
				this[key] = new_settings;
			}
		}
		
		// yaml
		protected Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			return builder.populate_mapping_with_map_items(this);
		}
		protected void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return;
			foreach(var scalar_key in mapping.scalar_keys()) {
				var settings_mapping = mapping[scalar_key] as Yaml.MappingNode;
				if (settings_mapping == null)
					continue;
				this[scalar_key.value] = parser.parse<ProgramDefaultSettings>(settings_mapping, new ProgramDefaultSettings());
			}
		}
	}
}
