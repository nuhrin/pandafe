/* AppearancePreset.vala
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
using Data.Appearances;
using Fields;
using Menus;
using Menus.Fields;

public class Appearance : NamedEntity, MenuObject
{
	construct {			
		name = "(Default)";
		game_browser = new GameBrowserAppearance.default();
		menu = new MenuAppearance.default();
	}
	
	public Appearance.default() {
		name = "(Default)";
		game_browser = new GameBrowserAppearance.default();
		menu = new MenuAppearance.default();
	}
	
	public GameBrowserAppearance game_browser { get; set; }
	public MenuAppearance menu { get; set; }
	
	public Appearance copy() {
		var copy = new Appearance();
		copy.name = name;
		copy.game_browser = game_browser.copy();
		copy.menu = menu.copy();
		return copy;
	}
	
	// menu
	public signal void game_browser_font_changed(GameBrowserAppearance appearance);
	public signal void game_browser_color_changed(GameBrowserAppearance appearance);
	public signal void menu_font_changed(MenuAppearance appearance);
	public signal void menu_color_changed(MenuAppearance appearance);
		
	protected void build_menu(MenuBuilder builder) {
		name_field = builder.add_string("name", "Name", null, this.name);
		name_field.set_minimum_menu_value_text_length(10);
		name_field.required = true;
	
		var game_browser_field = new ObjectBrowserField("game_browser", "Browser", "Game Browser Appearance: " + this.name, "Game Browser Appearance", game_browser);
		game_browser_field.menu.set_metadata("header_footer_reveal", "true");
		game_browser_font_changed_handler = game_browser.font_changed.connect(() => game_browser_font_changed(game_browser));
		game_browser_color_changed_handler = game_browser.color_changed.connect(() => game_browser_color_changed(game_browser));
		builder.add_field(game_browser_field);
				
		var menu_field = new ObjectBrowserField("menu", "Menu", "Menu Appearance: " + this.name, "Menu Appearance", menu);
//~ 		menu_field.menu.set_metadata("header_footer_reveal", "true");
		menu_font_changed_handler = menu.font_changed.connect(() => menu_font_changed(menu));
		menu_color_changed_handler = menu.color_changed.connect(() => menu_color_changed(menu));
		builder.add_field(menu_field);
					
		builder.add_separator();
	}
	protected void release_fields(bool was_saved) {
		name_field = null;
		game_browser.disconnect(game_browser_font_changed_handler);
		game_browser.disconnect(game_browser_color_changed_handler);
		menu.disconnect(menu_font_changed_handler);
		menu.disconnect(menu_color_changed_handler);
	}
	protected bool save_object(Menus.Menu menu) {
		GLib.message("saving appearance '%s'...", name);
		string? error;
		if (Data.appearances().save_appearance(this, generate_id(), out error) == false) {
			menu.error(error);
			GLib.warning(error);
			return false;
		}
		return true;
	}
	Menus.Fields.StringField name_field;
	ulong game_browser_font_changed_handler;
	ulong game_browser_color_changed_handler;
	ulong menu_font_changed_handler;
	ulong menu_color_changed_handler;
}
