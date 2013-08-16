/* AppearanceField.vala
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
using Layers.Controls;
using Menus;	
using Menus.Fields;

namespace Fields
{
	public class AppearanceField : MenuItemField, SubMenuItem
	{
		Appearance? _appearance;
		AppearanceMenu _menu;
		string _menu_title;
		
		public AppearanceField(string id, string name, string? help=null, Appearance? appearance=null) {
			base(id, name, help);
			_menu_title = help ?? name;
			_appearance = appearance;
		}
		public new Appearance? value {
			owned get { return _appearance; }
			set { change_value(value); }
		}
		
		public Menus.Menu menu { 
			get { 
				_menu = create_menu();
				return _menu;
			}
		}
		public signal void appearance_changed(Appearance appearance);
		public signal void game_browser_font_changed(GameBrowserAppearance appearance);
		public signal void game_browser_color_changed(GameBrowserAppearance appearance);
		public signal void menu_font_changed(MenuAppearance appearance);
		public signal void menu_color_changed(MenuAppearance appearance);		
				
		public override string get_value_text() { return ""; }
		public override int get_minimum_menu_value_text_length() { return 0; }
		
		protected override Value get_field_value() { return _appearance; }
		protected override void set_field_value(Value value) { change_value((Appearance)value); }
		protected override bool has_value() { return true; }
		protected override bool is_menu_item() { return true; }

		protected override void activate(Menus.MenuSelector selector) {
			assert_not_reached();	
		}

		void change_value(Appearance? appearance) {
			if (_appearance != appearance) {
				_appearance = appearance;
				changed();
			}
		}
		
		AppearanceMenu create_menu() {
			var menu = new AppearanceMenu(name, _appearance);
			menu.title = _menu_title;
			menu.game_browser_font_changed.connect((a) => game_browser_font_changed(a));
			menu.game_browser_color_changed.connect((a) => game_browser_color_changed(a));
			menu.menu_font_changed.connect((a) => menu_font_changed(a));
			menu.menu_color_changed.connect((a) => menu_color_changed(a));
			menu.appearance_changed.connect((a) => appearance_changed(a));
			menu.saved.connect(() => this.saved());
			menu.cancelled.connect(() => this.cancelled());
			menu.finished.connect(() => change_value(_menu.appearance));
			menu.set_metadata("header_footer_reveal", "true");
			return menu;
		}
		
		public class AppearanceMenu : Menus.Menu {
			Appearance? _appearance;
			Enumerable<AppearanceInfo> all_appearance_info;
			AppearanceInfo? current_appearance_info;
			
			public AppearanceMenu(string name, Appearance? appearance) {
				base(name);
				update_appearance_info(appearance);
			}

			void update_appearance_info(Appearance? appearance) {
				_appearance = appearance;
				current_appearance_info = null;
				all_appearance_info = Data.appearances().get_appearance_info();
				if (_appearance != null && _appearance.id != null)
					current_appearance_info = all_appearance_info.where(ai=>ai.id == _appearance.id).first();
				if (current_appearance_info == null)
					current_appearance_info = AppearanceInfo.default;
			}
			public signal void game_browser_font_changed(GameBrowserAppearance appearance);
			public signal void game_browser_color_changed(GameBrowserAppearance appearance);
			public signal void menu_font_changed(MenuAppearance appearance);
			public signal void menu_color_changed(MenuAppearance appearance);
			public signal void appearance_changed(Appearance appearance);
			public Appearance? appearance { get { return _appearance; } }
			
			protected override void populate_items(Gee.List<Menus.MenuItem> items) {
				appearance_info_field = new ValueSelectionField<AppearanceInfo>("appearance_info", "Preset", null, ai=>ai.name, ai=>ai, 
																				all_appearance_info, current_appearance_info);				
				
				appearance_info_field.changed.connect(() => {
					current_appearance_info = appearance_info_field.value;
					var was_null_appearance = (_appearance == null);
					_appearance = Data.appearances().get_appearance(current_appearance_info.id);
					if (_appearance != null) {
						appearance_changed(_appearance);
						refresh(0);
					} else if (was_null_appearance == false) {
						appearance_changed(new Appearance.default());
						refresh(0);
					}
				});
				items.add(appearance_info_field);
				items.add(new MenuItemSeparator());
				
				if (_appearance == null && current_appearance_info != AppearanceInfo.default) {
					// invalid
					error("Invalid appearance (id: %s)".printf(current_appearance_info.id));
					return;
				}
				
				if (current_appearance_info.is_local && _appearance != null) {
					var edit_item = ObjectMenu.get_browser_item("Edit", "Edit Appearance: " + _appearance.name, "Edit this appearance", _appearance);
					edit_item.menu.set_metadata("header_footer_reveal", "true");
					_appearance.game_browser_font_changed.connect((gba) => game_browser_font_changed(gba));
					_appearance.game_browser_color_changed.connect((gba) => game_browser_color_changed(gba));
					_appearance.menu_font_changed.connect((ma) => menu_font_changed(ma));
					_appearance.menu_color_changed.connect((ma) => menu_color_changed(ma));
					edit_item.menu.saved.connect(() => {
						update_appearance_info(_appearance);
						refresh(1);
					});
					items.add(edit_item);
				}
				
				var copy = (_appearance != null) ? _appearance.copy() : new Appearance.default();
				string copy_name = copy.name + "(Copy)";
				copy.name = null;
				copy.game_browser_font_changed.connect((gba) => game_browser_font_changed(gba));
				copy.game_browser_color_changed.connect((gba) => game_browser_color_changed(gba));
				copy.menu_font_changed.connect((ma) => menu_font_changed(ma));
				copy.menu_color_changed.connect((ma) => menu_color_changed(ma));					
				var copy_item = ObjectMenu.get_browser_item("Copy", "Edit Appearance: " + copy_name, "Edit a copy of this appearance", copy);
				copy_item.menu.set_metadata("header_footer_reveal", "true");
				copy_item.menu.saved.connect(() => {
					update_appearance_info(copy);
					refresh(0);
				});
				copy_item.menu.cancelled.connect(() => {
					appearance_changed(_appearance ?? new Appearance.default());
				});
				items.add(copy_item);
				
				if (current_appearance_info.is_local && _appearance != null) {
					items.add(new MenuItemSeparator());
					items.add(new RemoveItem(this));		
				}
			}
			protected override void cleanup() {
				appearance_info_field = null;
			}
			
			ValueSelectionField<AppearanceInfo> appearance_info_field;
			
			class RemoveItem : Menus.MenuItem 
			{
				AppearanceMenu menu;
				public RemoveItem(AppearanceMenu menu) {
					base("Remove", "Remove this appearance");
					this.menu = menu;
				}
				
				public signal void removed();
				
				public override void activate(MenuSelector selector) {
					var rect = selector.get_selected_item_rect();
					var confirmed = new DeleteConfirmation("confirm_appearance_delete", rect.x, rect.y).run();
					if (confirmed == false)
					  return;
					  
					string? error;
					if (Data.appearances().remove_appearance(menu._appearance, out error) == false) {
						selector.menu.error(error);
						return;
					}
					
					menu.update_appearance_info(null);
					menu.appearance_changed(new Appearance.default());
					menu.refresh(0);					
				}
				
				public override bool is_menu_item() { return true; }				
			}
		}
	}
}
