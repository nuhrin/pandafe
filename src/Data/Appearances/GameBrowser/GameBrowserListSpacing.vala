/* GameBrowserListSpacing.vala
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

using Menus;
using Menus.Fields;

namespace Data.Appearances.GameBrowser
{
	public class GameBrowserListSpacing : GameBrowserAreaBase<GameBrowserListSpacing>
	{	
		const int DEFAULT_TOP_SPACING = 25;
		const int DEFAULT_BOTTOM_SPACING = 25;
		const int DEFAULT_LEFT_SPACING = 0;
		const int DEFAULT_RIGHT_SPACING = 0;
		const int DEFAULT_ITEM_SPACING = 6;
		const int DEFAULT_ITEM_PADDING = 30;
		
		construct {
		}
		public GameBrowserListSpacing.default() {
			top = DEFAULT_TOP_SPACING;
			bottom = DEFAULT_BOTTOM_SPACING;
			left = DEFAULT_LEFT_SPACING;
			right = DEFAULT_RIGHT_SPACING;
			item_v = DEFAULT_ITEM_SPACING;
			item_h = DEFAULT_ITEM_PADDING;
		}
		
		public int top { get; set; }
		public int bottom { get; set; }
		public int left { get; set; }
		public int right { get; set; }
		public int item_v { get; set; }
		public int item_h { get; set; }
		
		public int16 top_resolved() { return (int16)((top > 0) ? top : DEFAULT_TOP_SPACING); }
		public int16 bottom_resolved() { return (int16)((bottom > 0) ? bottom : DEFAULT_BOTTOM_SPACING); }
		public int16 left_resolved() { return (int16)((left >= 0) ? left : DEFAULT_LEFT_SPACING); }
		public int16 right_resolved() { return (int16)((right >= 0) ? right : DEFAULT_RIGHT_SPACING); }
		public int16 item_v_resolved() { return (int16)((item_v > 0) ? item_v : DEFAULT_ITEM_SPACING); }
		public int16 item_h_resolved() { return (int16)((item_h >= 0) ? item_h : DEFAULT_ITEM_PADDING); }

		public override GameBrowserListSpacing copy() {
			var copy = new GameBrowserListSpacing();
			copy.top = top;
			copy.bottom = bottom;
			copy.left = left;
			copy.right = right;
			copy.item_v = item_v;
			copy.item_h = item_h;
			return copy;			
		}
		public override void copy_from(GameBrowserListSpacing other) {
			top = other.top;
			bottom = other.bottom;
			left = other.left;
			right = other.right;
			item_v = other.item_v;
			item_h = other.item_h;
		}
		
		protected override void attribute_changed() { @interface.game_browser_ui.list.spacing.update_attributes(this); }
		protected override void color_changed() { }
		protected override void appearance_changed() { @interface.game_browser_ui.list.spacing.update_appearance(this); }
		protected override string get_appearance_description() { return "Game Browser List Spacing"; }
		
		protected override void build_area_fields(MenuBuilder builder)
		{
			add_spacing_field(builder, "top", "Top", "Spacing above list", top_resolved(), 1, 50);
			add_spacing_field(builder, "bottom", "Bottom", "Spacing below list", bottom_resolved(), 1, 50);
			add_spacing_field(builder, "left", "Left", "Spacing to the left of list", left_resolved(), 0, 100);
			add_spacing_field(builder, "right", "Right", "Spacing to the right of list", right_resolved(), 0, 100);
			builder.add_separator();
			add_spacing_field(builder, "item_v", "Item V", "Vertical spacing between items", item_v_resolved(), 1, 15);			
			add_spacing_field(builder, "item_h", "Item H", "Horizonal padding on left/right of items", item_h_resolved(), 0, 50);
		}
		IntegerField add_spacing_field(MenuBuilder builder, string id, string name, string help, int value, int min_value, int max_value, uint step=1) {
			var field = new IntegerField(id, name, help, value, min_value, max_value, step);
			field.changed.connect(() => {
				this.set_property(field.id, field.value);
				attribute_changed();
			});
			builder.add_field(field);
			return field;
		}
		protected override void cleanup_area_fields() {
		}
	}
}
