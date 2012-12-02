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

	public override bool supports_game_settings { get { return false; } }
	public override Program? get_program(string? program_id=null) { return null; }

	protected override GameListProvider create_provider() { return new PndList(); }

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
