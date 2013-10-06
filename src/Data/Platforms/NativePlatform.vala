/* NativePlatform.vala
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
using Data.Platforms;
using Data.Pnd;
using Menus;
using Fields;

public class NativePlatform : Platform
{
	public NativePlatform() {
		base(PlatformType.NATIVE);
		name = "Pandora";
		categories = new ArrayList<NativePlatformCategory>();
	}

	public Gee.List<NativePlatformCategory> categories { get; set; }

	// game launching			
	public override SpawningResult run_game(GameItem game) {
		var app = get_game_app(game);
		if (app != null)
			return Spawning.spawn_app(app, false);				
		
		return new SpawningResult.error("Unable to run pnd '%s' (%s).".printf(game.name, game.id));
	}
	public AppItem? get_game_app(GameItem game) {
		var ids = game.id.split("|");
		var pnd = Data.pnd_data().get_pnd(ids[0]);
		if (pnd == null)
			return null;
		return pnd.get_app(ids[1]);
	}
	public override Program? get_program_for_game(GameItem game) { return null; }
	public override Program? get_program(string? program_id=null) { return null; }
	public override bool supports_game_settings { get { return false; } }

	// runtime data	
	protected override void initialize_runtime_data() {					
		main_categories = new ArrayList<string>();
		platform_category_hash = new HashMap<string, NativePlatformCategory>();
		var pnddata = Data.pnd_data();
		foreach(var category in this.categories) {
			if (pnddata.get_category(category.name) != null) {
				main_categories.add(category.name);
				platform_category_hash[category.name] = category;
			}
		}
		if (main_categories.size == 0)
			main_categories.add_all(pnddata.get_main_category_names().to_list());
		root_folder = (main_categories.size == 1)
			? new GameFolder.root("", this, main_categories[0])
			: new GameFolder.root(this.name, this, "");
	}
	ArrayList<string> main_categories;
	HashMap<string, NativePlatformCategory> platform_category_hash;	
	GameFolder root_folder;
	
	// game list
	public override GameFolder get_root_folder() {
		ensure_runtime_data();
		return root_folder;
	}	
	
	public override string get_unique_node_name(IGameListNode node) {
		if (node is GameItem || node.parent == null || node.parent.name == "")
			return node.name;
		return "%s/%s".printf(node.parent.name, node.name);
	}
	public override string get_unique_node_id(IGameListNode node) {
		if (node is GameItem || node.parent == null || node.parent.id == "")
			return node.id;
		return "%s/%s".printf(node.parent.id, node.id);
	}

	protected override bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games) {
		ensure_runtime_data();
		var folder_list = new ArrayList<GameFolder>();
		var game_list = new ArrayList<GameItem>();
		add_subfolders(folder, folder_list);
		child_folders = folder_list;
		add_games(folder, game_list);
		child_games = game_list;
		return true;
	}
	void add_subfolders(GameFolder folder, ArrayList<GameFolder> folder_list) {
		if (folder.id == "") {
			foreach(var category in main_categories)
				folder_list.add(new GameFolder(category, this, folder));
		} else if (folder.parent == null || folder.parent.id == "") {
			var native_category = platform_category_hash[folder.id];
			var excluded_hash = new HashSet<string>();
			excluded_hash.add_all(native_category.excluded_subcategories);
			var category = Data.pnd_data().get_category(folder.id);
			if (category != null) {
				foreach(var subcategory in category.subcategories) {
					if (excluded_hash.contains(subcategory.name) == false)
						folder_list.add(new GameFolder(subcategory.name, this, folder));
				}
			}
		}
		folder_list.sort(IGameListNode.compare);
	}
	void add_games(GameFolder folder, ArrayList<GameItem> game_list) {
		if (folder.id == "")
			return;

		CategoryBase category = null;
		NativePlatformCategory native_category = null;
		if (folder.parent == null || folder.parent.id == "") {
			category = Data.pnd_data().get_category(folder.id);
			if (category != null)
				native_category = platform_category_hash[category.name];
		} else {
			var main_category = Data.pnd_data().get_category(folder.parent.id);
			if (main_category != null) {
				native_category = platform_category_hash[main_category.name];
				category = main_category.get_subcategory(folder.id);
			}
		}

		if (category != null) {
			var excluded_hash = new HashSet<string>();
			excluded_hash.add(Build.PND_APP_ID);
			if (native_category != null)
				excluded_hash.add_all(native_category.excluded_apps);				
			var title_game_hash = new HashMap<string, GameItem?>();
			var title_packageid_hash = new HashMap<string, string>();
			foreach(var app in category.apps) {
				if (excluded_hash.contains(app.id) == true)
					continue;
				GameItem game = GameItem.create(app.title, this, folder, "%s|%s".printf(app.get_fullpath(), app.id));
				if (title_game_hash.has_key(app.title) == true) {
					var old_game_item = title_game_hash[app.title];
					if (old_game_item != null) {
						GameItem.set_full_name(old_game_item, "%s (%s)".printf(app.title, title_packageid_hash[app.title]));
						title_game_hash[app.title] = null;
					}
					GameItem.set_full_name(game, "%s (%s)".printf(app.title, app.package_id));
				} else {
					title_game_hash[app.title] = game;
					title_packageid_hash[app.title] = app.package_id;
				}
				game_list.add(game);
			}
			game_list.sort(IGameListNode.compare);
		}
	}
	

	// yaml
	protected override string generate_id() {
		assert_not_reached();
	}
	protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
		var mapping = new Yaml.MappingNode();
		if (appearance != null)
			mapping.set_scalar("appearance", builder.build_value(appearance));
		builder.add_item_to_mapping("categories", categories, mapping);
		return mapping;
	}
	protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
		parser.populate_object_properties_from_mapping(this, node as Yaml.MappingNode);
	}
	
	// menu
	protected override void build_menu(MenuBuilder builder) {
		var categories_field = new NativePlatformCategoryListField("categories", "Included Categories", 
			"If specified, only apps in these categories will be included." , categories);
		builder.add_field(categories_field);
		
//~ 		var appearance_field = new GameBrowserAppearanceField("appearance", "Appearance", null, name + " Appearance", appearance, Data.preferences().appearance);
//~ 		builder.add_field(appearance_field);
	}
	protected override bool save_object(Menus.Menu menu) {
		string? error;
		if (Data.platforms().save_native_platform(out error, f=> menu.message("Scanning category '%s'...".printf(f.unique_name()))) == false) {
			menu.error(error);
			return false;
		}
		return true;
	}	
}
