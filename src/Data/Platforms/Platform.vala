/* Platform.vala
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
using Data;
using Data.GameList;
using Data.Programs;
using Data.Platforms;
using Menus;

public enum PlatformType 
{
	NONE,
	ROM,
	PROGRAM,
	NATIVE
}

public abstract class Platform : NamedEntity, MenuObject
{
	protected Platform(PlatformType platform_type) {
		this.platform_type = platform_type;
	}
	public PlatformType platform_type { get; private set; }
	public GameBrowserAppearance? appearance { get; set; }
	
	public string platform_type_description() {
		if (platform_type == PlatformType.PROGRAM)
			return "Program Platform";
		else if (platform_type == PlatformType.NATIVE)
			return "Native Platform";
		return "Platform";
	}
	
	// game launching
	public abstract SpawningResult run_game(GameItem game);
	public abstract Program? get_program(string? program_id=null);
	public abstract Program? get_program_for_game(GameItem game);
	public abstract bool supports_game_settings { get; }
	
	// runtime data
	protected void ensure_runtime_data() {
		if (initialized == true)
			return;
		initialize_runtime_data();
		initialized = true;
	}
	protected abstract void initialize_runtime_data();
	protected bool initialized { get; private set; }
	
	// scanning
	public void rebuild(owned ForEachFunc<GameFolder>? pre_scan_action=null) {
		initialize_runtime_data();
		initialized = true;
		rescan((owned)pre_scan_action);
	}
	public void rescan(owned ForEachFunc<GameFolder>? pre_scan_action=null) {
		remove_platform_gamelist_cache();
		rescan_init();
		get_root_folder().rescan_children((owned)pre_scan_action);
		rescanned();
	}
	public signal void rescanned();
	public signal void folder_scanned(GameFolder folder);
	protected virtual void rescan_init() { }		
	void remove_platform_gamelist_cache() {
		if (this.id == null)
			return;
		string gamelistcache_path = Path.build_filename(Build.LOCAL_CONFIG_DIR, Data.GameList.GameFolder.CACHE_FOLDER_ROOT, this.id);
		if (FileUtils.test(gamelistcache_path, FileTest.IS_DIR) == true) {
			try {
				var directory = File.new_for_path(gamelistcache_path);
				Utility.remove_directory_recursive(directory);
			} catch(GLib.Error e) {
				warning("error remove platform '%s' gamelist cache: %s", this.id, e.message);
			}
		}
	}

	// game list
	public abstract GameFolder get_root_folder();
	public virtual string get_nearest_folder_path(string folder_path) {
		if (folder_path == null)
			return "";
		string[] parts = folder_path.strip().split("/");
		if (parts.length == 0)
			return "";
		var folder = get_root_folder();
		foreach(var part in parts) {
			bool found = false;
			foreach(var child in folder.child_folders()) {
				if (child.name == part){
					found = true;
					folder = child;
					break;
				}
			}
			if (found == false)
				break;
		}
		return folder.unique_name();
	}
	public virtual GameFolder? get_folder(string unique_name) {
		if (unique_name == null || unique_name == "")
			return null;

		return get_root_folder().get_descendant_folder(unique_name);
	}
	public GameFolder? get_folder_by_id(string unique_id) {
		if (unique_id == null || unique_id == "")
			return null;
		
		var root_folder = get_root_folder();
		if (unique_id == root_folder.unique_id())
			return root_folder;

		return root_folder.get_descendant_folder_by_id(unique_id);
	}	
	public abstract string get_unique_node_name(IGameListNode node);
	public virtual string get_unique_node_id(IGameListNode node) { return get_unique_node_name(node); }	
	public virtual string get_folder_display_name(GameFolder folder) { return folder.name; }
	public virtual string get_unique_folder_display_name(GameFolder folder) { return get_unique_node_name(folder); }
	public virtual string get_folder_display_path(string? folder_path) { return folder_path ?? "";  }
	public abstract bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games);
	
	// yaml
	protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
		var mapping = new Yaml.MappingNode();
		unowned ObjectClass klass = this.get_class();
	    var properties = klass.list_properties();
	    
	    builder.add_item_to_mapping("name", name, mapping);
	    builder.add_item_to_mapping("platform-type", platform_type, mapping);
	    if (appearance != null)
			builder.add_item_to_mapping("appearance", appearance, mapping);
	    
	    foreach(var prop in properties) {
			if (prop.name == "appearance" || prop.name == "name" || yaml_use_default_for_property(prop.name) == false)
				continue;
			
			builder.add_object_property_to_mapping(this, prop.name, mapping);
		}
		
		build_yaml_additional(mapping, builder);
		
		return mapping;
	}
	protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
		var mapping = node as Yaml.MappingNode;
		if (mapping == null)
			return;
			
		foreach(var key_node in mapping.scalar_keys()) {
			if (key_node.value == "platform-type" || yaml_use_default_for_property(key_node.value) == false)
				continue;
				
			parser.set_object_property(this, key_node.value, mapping[key_node]);				
		}
		
		apply_yaml_additional(mapping, parser);		
	}
	protected virtual bool yaml_use_default_for_property(string property) { return true; }
	protected virtual void build_yaml_additional(Yaml.MappingNode mapping, Yaml.NodeBuilder builder) { }
	protected virtual void apply_yaml_additional(Yaml.MappingNode mapping, Yaml.NodeParser parser) { }
	
	// menu
	protected abstract void build_menu(MenuBuilder builder);	
	protected virtual bool save_object(Menus.Menu menu) {
		string? error;
		if (Data.platforms().save_platform(this, generate_id(), out error, f=> menu.message("Scanning folder '%s'...".printf(f.unique_name()))) == false) {
			menu.error(error);
			return false;
		}
		return true;		
	}	
	protected virtual void release_fields() { }	
}
