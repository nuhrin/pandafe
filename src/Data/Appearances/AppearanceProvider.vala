/* AppearanceProvider.vala
 * 
 * Copyright (C) 2013 nuhrin
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

namespace Data.Appearances
{
	public class AppearanceProvider : EntityProvider<Appearance>
	{
		const string SUBFOLDER = "Preset";
		
		AppearanceEntityProvider package_appearance_provider;
		AppearanceEntityProvider local_appearance_provider;
		HashSet<string> package_appearance_ids;		
		HashSet<string> local_appearance_ids;
		HashSet<string> reserved_appearance_ids;
		HashMap<string,AppearanceInfo> appearance_info_hash;
		
		public AppearanceProvider(string root_folder) throws RuntimeError {
			base(root_folder);
			package_appearance_provider = new AppearanceEntityProvider(Path.build_filename(RuntimeEnvironment.system_data_dir(), SUBFOLDER), false);
			local_appearance_provider = new AppearanceEntityProvider(Path.build_filename(root_folder, SUBFOLDER), true);
		}
		
		public Appearance? get_appearance(string? id) {
			if (id == null)
				return null;
			ensure_appearance_info();
			
			if (id == AppearanceInfo.default.id)
				return new Appearance.default();
				
			Appearance? appearance = null;
			if (local_appearance_ids.contains(id) == true)
				appearance = local_appearance_provider.get_appearance(id);
			if (appearance == null && package_appearance_ids.contains(id) == true)
				appearance = package_appearance_provider.get_appearance(id);
			return appearance;
		}
		protected override Entity? get_entity(string id) { return get_appearance(id); }
		
		public Enumerable<AppearanceInfo> get_appearance_info() {
			ensure_appearance_info();
			var list = new ArrayList<AppearanceInfo>();
			list.add_all(appearance_info_hash.values);
			list.sort(AppearanceInfo.compare);
			list.add(AppearanceInfo.default);
			return new Enumerable<AppearanceInfo>(list);
		}
		
		public bool save_appearance(Appearance appearance, string id, out string? error) {
			error = null;
			if (id.strip() == "") {
				error = "Bad appearance id";
				return false;
			}
			ensure_appearance_info();
			if (package_appearance_ids.contains(id) == true || reserved_appearance_ids.contains(id) == true) {
				error = "Conflict with build-in appearance (id %s)".printf(id);
				return false;
			}
				
			if (appearance.id != id && local_appearance_ids.contains(id) == true) {
				error = "Conflict with existing appearance (id %s)".printf(id);
				return false;
			}
						
			string? original_id = appearance.id;
			if (original_id != null && original_id != id) {
				// safe rename: remove existing local appearance
				try {
					local_appearance_provider.remove(appearance);
				} catch {
				}				
			}
			
			try {
				local_appearance_provider.save(appearance, id);
			} catch(Error e) {
				error = e.message;
				return false;				
			}

			if (original_id != id) {
				if (original_id != null) {
					local_appearance_ids.remove(original_id);
					appearance_info_hash.unset(original_id);
				}			
				local_appearance_ids.add(id);
				appearance_info_hash[id] = new AppearanceInfo(id, appearance.name, true);
			}
						
			return true;
		}
		public bool remove_appearance(Appearance appearance, out string? error) {
			error = null;
			if (appearance.id != null && (package_appearance_ids.contains(appearance.id) || reserved_appearance_ids.contains(appearance.id))) {
				error = "Can't remove build-in appearance (id %s)".printf(appearance.id);
				return false;
			}
			try {
				local_appearance_provider.remove(appearance);
				local_appearance_ids.remove(appearance.id);
				appearance_info_hash.unset(appearance.id);
				return true;
			} catch(Error e) {
				error = e.message;
			}
			return false;
		}
				
		void ensure_appearance_info() {
			if (appearance_info_hash != null)
				return;
				
			appearance_info_hash = new HashMap<string,AppearanceInfo>();
			
			package_appearance_ids = new HashSet<string>();
			foreach(var info in package_appearance_provider.get_appearance_info()) {
				package_appearance_ids.add(info.id);
				appearance_info_hash[info.id] = info;
			}
			local_appearance_ids = new HashSet<string>();
			foreach(var info in local_appearance_provider.get_appearance_info()) {
				local_appearance_ids.add(info.id);
				appearance_info_hash[info.id] = info;
			}
			
			reserved_appearance_ids = new HashSet<string>();
			reserved_appearance_ids.add(AppearanceInfo.default.id);
		}
		
		class AppearanceEntityProvider : EntityProvider<Appearance>
		{
			string root_folder;
			bool is_local;
			public AppearanceEntityProvider(string root_folder, bool is_local) throws RuntimeError {
				base(root_folder);
				this.root_folder = root_folder;
				this.is_local = is_local;
			}
			
			public ArrayList<AppearanceInfo> get_appearance_info() {
				var list = new ArrayList<AppearanceInfo>();
				Enumerable<string> ids;
				try {
					ids = get_ids();
				} catch(Error e) {
					return list;
				}
				
				foreach(var id in ids) {
					Yaml.MappingNode mapping = null;
					try {
						mapping = load_document(id).root as Yaml.MappingNode;
					} catch(RuntimeError e) {
						warning("RuntimeError: %s", e.message);					
						continue;
					} catch(YamlError e) {
						warning("YamlError: %s", e.message);
						continue;
					}
					if (mapping == null)
						continue;
					
					var name_node = mapping.get_scalar("name") as Yaml.ScalarNode;
					if (name_node == null)
						continue;
					
					list.add(new AppearanceInfo(id, name_node.value, is_local));
				}
				
				return list;
			}
			
			public Appearance? get_appearance(string id) { return (Appearance?)get_entity(id); }			
			protected override Entity? get_entity(string id) { 
				try {
					return load(id);
				} catch(RuntimeError e) {
					warning("RuntimeError: %s", e.message);					
					return null;
				} catch(YamlError e) {
					warning("YamlError: %s", e.message);
					return null;
				} catch(FileError e) {
					warning("FileError: %s", e.message);
					return null;
				}
					
			}
			
		}
	}
}
