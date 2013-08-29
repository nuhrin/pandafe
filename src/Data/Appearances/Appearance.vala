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
using Data.Appearances.GameBrowser;
using Data.Appearances.Menu;
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
	public void set_temp_name(string name) { _temp_name = name; }
	string _temp_name;
	void appearance_changed<G>(AppearanceType<G> appearance) {
		var type = appearance.get_type();
		if (type == typeof(GameBrowserAppearance))
			@interface.game_browser_ui.update_appearance(game_browser);
		else if (type == typeof(MenuAppearance))
			@interface.menu_ui.update_appearance(menu);
	}
	protected void build_menu(MenuBuilder builder) {
		var display_name = this.name ?? _temp_name ?? "";
		name_field = builder.add_string("name", "Name", null, this.name);
		name_field.set_minimum_menu_value_text_length(10);
		name_field.required = true;
		game_browser.set_name(display_name);
		menu.set_name(display_name);
		
		builder.add_separator();
		
		var game_browser_field = add_appearance_field<GameBrowserAppearance>(builder, "game_browser", "Browser", display_name + ": Game Browser Appearance", 
																			 "Game Browser Appearance", game_browser);
		var menu_field = add_appearance_field<MenuAppearance>(builder, "menu", "Menu", display_name + ": Menu Appearance", "Menu Appearance", menu);
					
		builder.add_separator();
		
		name_field.changed.connect(() => {
			display_name = name_field.value;
			if (display_name == null || display_name == "")
				display_name = _temp_name ?? "";
			game_browser.set_name(display_name);
			menu.set_name(display_name);
			game_browser_field.menu.title = display_name + ": Game Browser Appearance";
			((GameBrowserAppearance)game_browser_field.value).set_name(display_name);
			menu_field.menu.title = display_name + ": Menu Appearance";
			((MenuAppearance)menu_field.value).set_name(display_name);
		});		
		
	}
	ObjectBrowserField add_appearance_field<G>(MenuBuilder builder, string id, string name, string title, string help, AppearanceType<G> appearance) {
		var copy = (AppearanceType<G>)appearance.copy();
		copy.set_name(appearance.name);
		var field = new ObjectBrowserField(id, name, title, help, copy);
		field.menu.set_metadata("header_footer_reveal", "true");
		
		if (field_handlers == null)
			field_handlers = new Gee.HashMultiMap<MenuItemField, ulong>();
		field_handlers.set(field, field.cancelled.connect(() => {
			appearance_changed<G>(appearance);
			copy.copy_from(appearance);
		}));	
		field_handlers.set(field, field.saved.connect(() =>  {
			appearance.copy_from(copy);
		}));
		
		builder.add_field(field);
		
		return field;
	}
	protected void release_fields(bool was_saved) {
		name_field = null;
		
		if (field_handlers != null) {
			foreach(var field in field_handlers.get_keys()) {
				foreach(ulong handler in field_handlers[field])
					field.disconnect(handler);
			}
			field_handlers.clear();
		}
	}
	protected bool save_object(Menus.Menu menu) {
		string? error;
		if (Data.appearances().save_appearance(this, generate_id(), out error) == false) {
			menu.error(error);
			GLib.warning(error);
			return false;
		}
		return true;
	}
	Menus.Fields.StringField name_field;
	Gee.HashMultiMap<MenuItemField, ulong> field_handlers;
}
