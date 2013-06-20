/* GameBrowserAppearanceMenu.vala
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
using Data;
using Fields;
using Menus.Fields;

namespace Menus.Concrete
{
	public class GameBrowserAppearanceMenu : Menu  
	{
		GameBrowserAppearance appearance;
		GameBrowserAppearance? default_appearance;
		GameBrowserAppearance appearance_edit;
		
		public GameBrowserAppearanceMenu(string name, GameBrowserAppearance appearance, GameBrowserAppearance? default_appearance=null) {
			base(name);
			this.appearance = appearance;
			this.default_appearance = default_appearance;			
			
			appearance_edit = (appearance != null) ? appearance.copy() : null;
			if (appearance_edit == null)
				appearance_edit = (default_appearance != null) ? default_appearance.copy() : null;
			if (appearance_edit == null)
				appearance_edit = new GameBrowserAppearance.default();
			if (appearance_edit.font == null)
				appearance_edit.font = GameBrowserAppearance.get_default_font_path();
			if (appearance_edit.font_size <= 0)
				appearance_edit.font_size = GameBrowserAppearance.DEFAULT_FONT_SIZE;
			if (appearance_edit.item_spacing <= 0)
				appearance_edit.item_spacing = GameBrowserAppearance.DEFAULT_ITEM_SPACING;
		}
			
		public signal void changed(GameBrowserAppearance appearance);
		
		protected override bool do_save() {
			appearance.background_color.copy_from(appearance_edit.background_color);
			appearance.item_color.copy_from(appearance_edit.item_color);
			appearance.selected_item_color.copy_from(appearance_edit.selected_item_color);
			if (appearance_edit.selected_item_background_color != null && appearance_edit.selected_item_background_color.spec != appearance_edit.background_color.spec)
				appearance.selected_item_background_color = appearance_edit.selected_item_background_color.copy();
			else
				appearance.selected_item_background_color = null;
			if (appearance_edit.header_footer_color != null && appearance_edit.header_footer_color.spec != appearance_edit.selected_item_color.spec)
				appearance.header_footer_color = appearance_edit.header_footer_color.copy();
			else
				appearance.header_footer_color = null;
			
			appearance.font = appearance_edit.font;
			appearance.font_size = appearance_edit.font_size;
			appearance.item_spacing = appearance_edit.item_spacing;
			
			return true;			
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			font = new FileField("font", "Font", null, "", "ttf", Path.build_filename(RuntimeEnvironment.system_data_dir(), "fonts"));
			font.set_minimum_menu_value_text_length(15);
			items.add(font);
			font_size = new IntegerField("font_size", "Font Size", null, GameBrowserAppearance.DEFAULT_FONT_SIZE, 
				GameBrowserAppearance.MIN_FONT_SIZE, GameBrowserAppearance.MAX_FONT_SIZE);
			items.add(font_size);
			item_spacing = new IntegerField("item_spacing", "Item Spacing", null, GameBrowserAppearance.DEFAULT_ITEM_SPACING, 1, 15);
			items.add(item_spacing);
			
			items.add(new MenuItemSeparator());
			
			background_color = new ColorField("background_color", "Background", "Background Color");
			items.add(background_color);
			item_color = new ColorField("item_color", "Item", "Item Color");
			items.add(item_color);
			selected_item_color = new ColorField("selected_item_color", "Selected Item", "Selected Item Color");
			items.add(selected_item_color);
			selected_item_background_color = new ColorField("selected_item_background_color", "Selected Background", "Selected Item Background Color");
			items.add(selected_item_background_color);
			header_footer_color = new ColorField("header_footer_color", "Header/Footer", "Header/Footer Text Color");
			items.add(header_footer_color);
			
			items.add(new MenuItemSeparator());			
			if (default_appearance != null && default_appearance.has_data()) {
				int defaults_index = items.size;
				items.add(new MenuItem.custom("Defaults", "Reset to the default appearance for the current context" , null, () => {
					if (default_appearance.font != null)
						font.value = default_appearance.font;
					if (default_appearance.font_size >= 0)
						font_size.value = default_appearance.font_size;
					if (default_appearance.item_spacing >= 0)
						item_spacing.value = default_appearance.item_spacing;
						
					if (default_appearance.background_color != null)
						background_color.value = default_appearance.background_color;
					if (default_appearance.item_color != null)
						item_color.value = default_appearance.item_color;
					if (default_appearance.selected_item_color != null)
						selected_item_color.value = default_appearance.selected_item_color;
					if (default_appearance.selected_item_background_color != null)
						selected_item_background_color.value = default_appearance.selected_item_background_color;
					else if (default_appearance.background_color != null)
						selected_item_background_color.value = default_appearance.background_color;
					if (default_appearance.header_footer_color != null)
						header_footer_color.value = default_appearance.header_footer_color;
					refresh(defaults_index);
				}));
			}
			items.add(new MenuItem.cancel_item());
			items.add(new MenuItem.save_item());
			initialize();
			font.changed.connect(on_font_change);
			font_size.changed.connect(on_font_change);
			item_spacing.changed.connect(on_font_change);

			background_color.changed.connect(on_color_change);
			background_color.selection_changed.connect((c) => {
				sync_selected_item_background = false;
				appearance_edit.background_color.copy_from(c);
				if (background_color.value.spec == selected_item_background_color.value.spec) {
					if (appearance_edit.selected_item_background_color != null)
						appearance_edit.selected_item_background_color.copy_from(c);
					else
						appearance_edit.selected_item_background_color = c.copy();
					sync_selected_item_background = true;
				}
				changed(appearance_edit);
			});		
			item_color.changed.connect(on_color_change);
			item_color.selection_changed.connect((c) => {
				appearance_edit.item_color.copy_from(c);
				changed(appearance_edit);
			});
			selected_item_color.changed.connect(on_color_change);
			selected_item_color.selection_changed.connect((c) => {
				appearance_edit.selected_item_color.copy_from(c);
				changed(appearance_edit);
			});
			selected_item_background_color.changed.connect(() => {
				sync_selected_item_background = false;
				on_color_change();
			});
			selected_item_background_color.selection_changed.connect((c) => {
				if (appearance_edit.selected_item_background_color != null)
					appearance_edit.selected_item_background_color.copy_from(c);
				else
					appearance_edit.selected_item_background_color = c.copy();
				changed(appearance_edit);
			});
			header_footer_color.changed.connect(on_color_change);
			header_footer_color.selection_changed.connect((c) => {
				if (appearance_edit.header_footer_color != null)
					appearance_edit.header_footer_color.copy_from(c);
				else
					appearance_edit.header_footer_color = c.copy();				
				changed(appearance_edit);
			});
			
		}
		protected override void cleanup() {
			font = null;
			font_size = null;
			background_color = null;
			item_color = null;
			selected_item_color = null;
			selected_item_background_color = null;
			header_footer_color = null;
			sync_selected_item_background = false;
		}
		
		void initialize() {
			font.value = appearance_edit.font;
			font_size.value = appearance_edit.font_size;
			background_color.value.copy_from(appearance_edit.background_color);
			item_color.value.copy_from(appearance_edit.item_color);
			selected_item_color.value.copy_from(appearance_edit.selected_item_color);			
			selected_item_background_color.value.copy_from(appearance_edit.selected_item_background_color ?? appearance_edit.background_color);
			header_footer_color.value.copy_from(appearance_edit.header_footer_color ?? appearance_edit.selected_item_color);
		}
		void on_font_change() {
			appearance_edit.font = font.value;
			appearance_edit.font_size = font_size.value;
			appearance_edit.item_spacing = item_spacing.value;
			changed(appearance_edit);
		}
		void on_color_change() {			
			appearance_edit.background_color.copy_from(background_color.value);			
			appearance_edit.item_color.copy_from(item_color.value);
			appearance_edit.selected_item_color.copy_from(selected_item_color.value);
			
			if (sync_selected_item_background == true) {
				if (appearance_edit.selected_item_background_color != null)
					appearance_edit.selected_item_background_color.copy_from(background_color.value);
			}  else {
				if (appearance_edit.selected_item_background_color != null)
					appearance_edit.selected_item_background_color.copy_from(selected_item_background_color.value);
				else
					appearance_edit.selected_item_background_color = selected_item_background_color.value.copy();					
			}
			
			if (appearance_edit.header_footer_color != null)
				appearance_edit.header_footer_color.copy_from(header_footer_color.value);
			else
				appearance_edit.header_footer_color = header_footer_color.value.copy();		
			
			if (sync_selected_item_background == true) {
				refresh(4);
				sync_selected_item_background = false;
			}					
			
			changed(appearance_edit);
		}
		
		FileField font;
		IntegerField font_size;
		IntegerField item_spacing;
		ColorField item_color;
		ColorField selected_item_color;
		ColorField selected_item_background_color;
		ColorField background_color;
		ColorField header_footer_color;
		bool sync_selected_item_background;
	}

}
