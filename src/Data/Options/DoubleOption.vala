/* DoubleOption.vala
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

using Catapult;
using Menus;
using Menus.Fields;

namespace Data.Options
{
	public class DoubleOption : Option
	{
		public DoubleOption(OptionSet parent) {
			base(parent);
		}
		public override OptionType option_type { get { return OptionType.DOUBLE; } }
		public double min_value { get; set; }
		public double max_value { get; set; }
		public double step { get; set; }
		public uint precision { get; set; }
		public double default_value { get; set; }
		public bool include_option_for_default_value { get; set; }
		
		// menu
		protected override void build_edit_fields(MenuBuilder builder) {
			builder.add_double("min_value", "Minimum Value", null, min_value, double.MIN, double.MAX, 0.1, 3);
			builder.add_double("max_value", "Maximum Value", null, max_value, double.MIN, double.MAX, 0.1, 3);
			builder.add_double("step", "Step", null, step, 0.01, double.MAX, 0.1, 3);
			builder.add_uint("precision", "Precision", null, precision, 0, 10);
			builder.add_double("default_value", "Default Value", null, default_value, double.MIN, double.MAX, 0.1, 3);
			builder.add_bool("include_option_for_default_value", "Include for Default", null, include_option_for_default_value);
		}
		protected override bool is_option_required() { return true; }
		
		// setting field
		public override MenuItemField get_setting_field(string? setting) {
			return new DoubleField(name, name, help, get_setting_value(setting), min_value, max_value, step, precision);
		}
		public override string get_setting_value_from_field(MenuItemField field) {
			return get_value_string((field as DoubleField).value);
		}
		
		// setting
		public override string get_option_from_setting_value(string? setting) {
			double value = get_setting_value(setting);
			if (value == default_value && include_option_for_default_value == false)
				return "";
			
			return option + get_value_string(value);
		}
		
		string get_value_string(double value) {
			return "%%.%uf".printf(precision).printf(value);
		}
		
		double get_setting_value(string? setting) {
			double val = (setting != null)
				? double.parse(setting)
				: default_value;
			
			if (val < min_value)
				val = min_value;
			if (val > max_value)
				val = max_value;
			
			return val;
		}
	}
}
