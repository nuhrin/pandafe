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
using Data.Appearances.GameBrowser;
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
		string gamelistcache_path = Path.build_filename(RuntimeEnvironment.user_config_dir(), Data.GameList.GameFolder.CACHE_FOLDER_ROOT, this.id);
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
	public Enumerable<GameItem> all_games() {
		Gee.List<GameItem> games;
		if (load_cache(out games) == true)
			return new Enumerable<GameItem>(games);
		
		var list = this.get_root_folder().all_games().to_list();
		save_cache(list, null);

		return new Enumerable<GameItem>(list);
	}
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
	
	// game list cache
	const string CACHE_FILENAME = "everything";
	public void update_cache_for_folder(GameFolder folder, string? new_selection_id) {
		save_cache(this.get_root_folder().all_games().to_list(), new_selection_id);
		Data.platforms().platform_rescanned(this, new_selection_id);
	}
	bool load_cache(out Gee.List<GameItem> games) {
		games = null;
		// attempt to load
		try {
			string contents;
			if (FileUtils.get_contents(Path.build_filename(RuntimeEnvironment.user_config_dir(), GameFolder.CACHE_FOLDER_ROOT, this.id, CACHE_FILENAME), out contents) == false)
				throw new FileError.FAILED("unspecified error");
			var lines = contents.strip().split("\n");
			if (lines.length == 0)
				return false;

			var hash = new HashMap<string,GameFolder>();
			games = new ArrayList<GameItem>();
			
			foreach(var line in lines) {
				var parts = line.split("||");
				if (parts.length < 3 || parts[0].length != 1)
					throw new FileError.FAILED("invalid cache file format: %s".printf(line));
				//print("%s\n", line);
				
				GameFolder folder = null;
				var key = parts[1];
				var name = parts[2];
				if (parts[0] == "f") {
					// folder
					if (key == "p") {
						folder = this.get_root_folder();
						hash[hash.size.to_string()] = folder;
						continue;
					}
					if (hash.has_key(key) == false)
						continue; // parent folder not found (possibly not yet parsed?)
					var parent = hash[key];
					folder = new GameFolder(name, parent.platform, parent);
					hash[hash.size.to_string()] = folder;
					continue;
				}
				
				if (parts[0] != "g" || parts.length != 5)
					throw new FileError.FAILED("invalid game format");					
				if (hash.has_key(key) == false)
					continue; // folder not found for key
				
				// game
				folder = hash[key];
				var id = parts[3];
				var full_name = parts[4];
				if (id == "")
					id = null;
				if (full_name == "")
					full_name = null;
				games.add(GameItem.create(name, folder.platform, folder, id, full_name));
			}
			
			return true;
		} catch(Error e) {
			games = null;
		}
		return false;
	}
	void save_cache(Gee.List<GameItem> games, string? new_selection_id) {
		// attempt to save
		try {
			var sb = new StringBuilder();
			var hash = new HashMap<GameFolder,string>();
			
			if (games.size == 0)
				add_folder_line("p", this.id, sb);
			
			foreach(var game in games) {
				ensure_folder_store(game.parent, hash, sb);
				game.add_cache_line(sb, hash[game.parent]);
			}
			if (FileUtils.set_contents(Path.build_filename(RuntimeEnvironment.user_config_dir(), GameFolder.CACHE_FOLDER_ROOT, this.id, CACHE_FILENAME), sb.str) == false)
				throw new FileError.FAILED("unspecified error");			
		} catch(Error e) {
			warning("Error saving all games cache: %s", e.message);
		}
	}
	void ensure_folder_store(GameFolder folder, HashMap<GameFolder,string> hash, StringBuilder sb) {
		if (hash.has_key(folder) == true)
			return;
		
		if (folder.parent == null) {
			hash[folder] = hash.size.to_string();
			add_folder_line("p", folder.platform.id, sb);
			return;
		}
		
		ensure_folder_store(folder.parent, hash, sb);
		hash[folder] = hash.size.to_string();
		add_folder_line(hash[folder.parent], folder.name, sb);
	}
	void add_folder_line(string parent_id, string name, StringBuilder sb) {
		sb.append("f||%s||%s\n".printf(parent_id, name));
	}
	
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
	protected virtual void release_fields(bool was_saved) { }	
}
