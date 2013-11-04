/* PlatformProvider.vala
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
using Data.GameList;
using Data.Pnd;

namespace Data.Platforms
{
	public class PlatformProvider : EntityProvider<Platform>
	{		
		public const string NATIVE_PLATFORM_ID = "native_platform";
		public const string PLATFORM_FOLDER_ID = "platform_folders";
		HashMap<string,Platform> platform_id_hash;
		Gee.List<Platform> all_platforms;
		public PlatformProvider(string root_folder, Data.Programs.ProgramProvider program_provider) throws RuntimeError
		{
			base(root_folder);
			register_entity_provider<Program>(program_provider);
		}
		
		public signal void platform_folders_changed();
		public signal void platform_rescanned(Platform platform, string? new_selection_id);
		public signal void platform_folder_scanned(GameFolder folder);
		
		public Enumerable<Platform> get_all_platforms() {
			if (all_platforms == null) {
				ensure_platforms();
				all_platforms = new ArrayList<Platform>();
				all_platforms.add(get_native_platform());
				all_platforms = new Enumerable<Platform>(all_platforms)
					.concat(new Enumerable<Platform>(platform_id_hash.values))
					.sort((a,b) => a.name.casefold().collate(b.name.casefold()))
					.to_list();				
			}
			return new Enumerable<Platform>(all_platforms);
		}		
		
		public PlatformFolderData get_platform_folder_data() {
			if (_platform_folders == null) {
				try {
					_platform_folders = Data.data_interface().load<PlatformFolderData>(PLATFORM_FOLDER_ID, "");
				} catch(Error e) {
					if ((e is RuntimeError.FILE) == false)
						warning("Error while retrieving platform folder data: %s", e.message);
					_platform_folders = null;
				}
				if (_platform_folders == null)
					_platform_folders = new PlatformFolderData();				
			}
			return _platform_folders;
		}
		PlatformFolderData _platform_folders;
		public bool save_platform_folder_data(out string? error) {
			error = null;
			try {
				Data.data_interface().save(get_platform_folder_data(), PLATFORM_FOLDER_ID, "");
				platform_folders_changed();
				return true;
			}
			catch (Error e) {
				error = e.message;
			}
			return false;
		}
				
		public NativePlatform get_native_platform() {
			if (_native_platform == null) {
				try {
					_native_platform = load_native_platform();
				}
				catch (Error e) {
					if ((e is RuntimeError.FILE) == false)
						warning("Error while retrieving native platform: %s", e.message);
					_native_platform = null;
				}
				if (_native_platform == null) {
					_native_platform = new NativePlatform();
					_native_platform.categories.add(new NativePlatformCategory() { name = "Game" });
					try {
						Data.data_interface().save(get_native_platform(), NATIVE_PLATFORM_ID, "");
					}
					catch (Error e) {
					}
				}
				_native_platform.rescanned.connect(() => platform_rescanned(_native_platform, null));
				_native_platform.folder_scanned.connect(folder => platform_folder_scanned(folder));
				set_id(_native_platform, "pandora");
			}
			return _native_platform;
		}
		NativePlatform _native_platform;
		public bool save_native_platform(out string? error, owned ForEachFunc<GameFolder>? pre_scan_action=null) {
			error = null;
			try {
				var platform = get_native_platform();
				Data.data_interface().save(platform, NATIVE_PLATFORM_ID, "");
				platform.rescan((owned)pre_scan_action);
				return true;
			}
			catch (Error e) {
				error = e.message;
			}
			return false;
		}
		
		public Platform? get_platform(string id) {
			if (id == NATIVE_PLATFORM_ID)
				return get_native_platform();
			ensure_platforms();
			if (platform_id_hash.has_key(id) == true)
				return platform_id_hash[id];
			return null;
		}
		
		public void rescan_folder(GameFolder folder, string? new_selection_id=null) {
			platform_folder_scanned(folder);
			folder.rescan_children(null, new_selection_id);
			platform_rescanned(folder.platform, new_selection_id);
		}
		
		public bool save_platform(Platform platform, string id, out string? error, owned ForEachFunc<GameFolder>? pre_scan_action=null) {
			if (platform.platform_type == PlatformType.NATIVE)
				GLib.error("NativePlatform instance cannot be saved in this fashion. Use save_native_platform().");
			error = null;
			if (id.strip() == "") {
				error = "Bad platform id";
				return false;
			}
			if (platform.id != id && platform_id_hash.has_key(id) == true) {
				error = "Conflict with existing platform (id %s)".printf(id);
				return false;
			}
						
			string? original_id = platform.id;
			if (original_id != null && original_id != id) {
				// safe rename: remove existing platform
				try {
					remove(platform);
				} catch {
				}				
			}
			
			try {
				save(platform, id);
			} catch(Error e) {
				error = e.message;
				return false;				
			}

			if (original_id == null) {
				// newly saved
				platform.rescanned.connect(() => platform_rescanned(platform, null));
				platform.folder_scanned.connect(folder => platform_folder_scanned(folder));
			} else if (platform_id_hash.has_key(original_id) == true) {
				platform_id_hash.unset(original_id);
			}
			
			platform_id_hash[id] = platform;
			all_platforms = null;
			if (original_id != null && original_id != platform.id)
			{
				// update dependent entities
				try {
					Data.data_interface().save(get_platform_folder_data(), PLATFORM_FOLDER_ID, "");
				}
				catch (Error e) {
				}
			}
			
			// rebuild platform data and rescan
			platform.rebuild((owned)pre_scan_action);
			return true;
		}
		public bool remove_platform(Platform platform, out string? error) {
			error = null;
			try {
				remove(platform);
				platform_id_hash.unset(platform.id);
				all_platforms = null;
				return true;
			} catch(Error e) {
				error = e.message;
			}
			return false;
		}
		
		public void clear_cache() {
			platform_id_hash = null;
			all_platforms = null;
			_platform_folders = null;
			_native_platform = null;
		}
		
		protected override Entity? get_entity(string entity_id) {
			return get_platform(entity_id);			
		}
		
		void ensure_platforms() {
			if (platform_id_hash != null)
				return;
			platform_id_hash = new HashMap<string,Platform>();
			
			Enumerable<string> ids;
			try {
				ids = get_ids();
			} catch(Error e) {
				ids = Enumerable.empty<string>();
			}
			
			foreach(var id in ids) {
				var platform = load_platform(id);
				if (platform == null)
					continue;

				platform_id_hash[platform.id] = platform;
				platform.rescanned.connect(() => platform_rescanned(platform, null));
				platform.folder_scanned.connect(folder => platform_folder_scanned(folder));
			}
		}
		Platform? load_platform(string id)  {
			Yaml.MappingNode mapping;
			try {
				mapping = load_document(id).root as Yaml.MappingNode;
			} catch(RuntimeError e) {
				message("RuntimeError: %s", e.message);					
				return null;
			} catch(YamlError e) {
				message("YamlError: %s", e.message);
				return null;
			}
			
			var platformTypeNode = mapping.get_scalar("platform-type");
			if (platformTypeNode == null)
				return null;
			
			PlatformType platform_type = (PlatformType)parser.parse_value_of_type(platformTypeNode, typeof(PlatformType), PlatformType.NONE);
			switch(platform_type) {
				case PlatformType.ROM:
					var rom_platform = new RomPlatform();
					apply_yaml_node(rom_platform, mapping);
					set_id(rom_platform, id);
					return rom_platform;
				case PlatformType.PROGRAM:
					var program_platform = new ProgramPlatform();
					apply_yaml_node(program_platform, mapping);
					set_id(program_platform, id);
					return program_platform;
				default:
					break;
			}
			
			return null;
		}
		NativePlatform load_native_platform()  throws RuntimeError, YamlError
		{
			Yaml.MappingNode mapping = load_document(NATIVE_PLATFORM_ID, "").root as Yaml.MappingNode;
			var native_platform = new NativePlatform();
			apply_yaml_node(native_platform, mapping);
			return native_platform;
		}
	}	
}
