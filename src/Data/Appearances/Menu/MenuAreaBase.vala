/* MenuAreaBase.vala
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

using Catapult;
using Menus;

namespace Data.Appearances.Menu
{
	public abstract class MenuAreaBase<G> : MenuAppearanceBase<G>, AppearanceAreaType<G>
	{
		protected const string DEFAULT_HEADER_FOOTER_COLOR = "#FFFFFF";
		
		construct {
			initialize_with_defaults();
		}
		protected MenuAreaBase.default() { initialize_with_defaults(); }
		
		string _font;
		int _font_size;
		protected unowned string get_font() { return _font; }
		protected void set_font(string font) { _font = font; }
		protected int get_font_size() { return _font_size; }
		protected void set_font_size(int size) { _font_size = size; }
		protected virtual bool monospace_font_required() { return false; }
		
		// yaml
		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) { return build_yaml_node_implementation(builder); }
		protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) { apply_yaml_node_implementation(node, parser); }

		// menu			
		protected abstract void font_changed();
		protected abstract void build_additional_fields(MenuBuilder builder);
		protected abstract void cleanup_additional_fields();
		protected override void build_menu(MenuBuilder builder) { build_menu_implementation(builder); }			
		protected override void cleanup_fields() { cleanup_fields_implementation(); }
	}
}
