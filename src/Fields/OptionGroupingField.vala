/* OptionGroupingField.vala
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

using Data;
using Data.Options;
using Data.Programs;
using Menus;
using Menus.Fields;
using Menus.Concrete;

namespace Fields
{
	public class OptionGroupingField : MenuItemField, SubMenuItem
	{
		OptionGrouping grouping;
		OptionGroupingMenu _menu;
		
		public OptionGroupingField(string id, string name, string? help=null, OptionGrouping grouping, ProgramSettings settings, ProgramSettings? default_settings, string program_name, string? title_prefix=null) {
			base(id, name, help);
			this.grouping = grouping;
			_menu = new OptionGroupingMenu(grouping, settings, default_settings, program_name, title_prefix);
			_menu.cancelled.connect(() => cancelled());
			_menu.saved.connect(() => saved());
			_menu.finished.connect(() => finished());
		}
		
		public Menus.Menu menu { get { return _menu; } }

		public new OptionGrouping value {
			get { return grouping; }
			set { change_value(value); }
		}
		
		public void populate_settings_from_fields(ProgramSettings target_settings) {
			_menu.populate_settings_from_fields(target_settings);
		}
		
		public override string get_value_text() { return ""; }
		public override int get_minimum_menu_value_text_length() { return 0; }
		public override bool is_menu_item() { return true; }

		protected override Value get_field_value() { return grouping; }
		protected override void set_field_value(Value value) { change_value((OptionGrouping)value); }
		protected override bool has_value() { return true; }

		protected override void activate(Menus.MenuSelector selector) {
			new MenuBrowser(_menu).run();
		}
		
		void change_value(OptionGrouping new_value) {
			grouping = new_value;
			changed();
		}
	}
}
