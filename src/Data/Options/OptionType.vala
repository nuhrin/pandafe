/* OptionType.vala
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

namespace Data.Options
{
	public enum OptionType
	{
		NONE,
		FLAG,
		MULTIPLE_CHOICE,
		STRING,
		INTEGER,
		DOUBLE,
		GROUPING;
		
		public Option? create_option(OptionSet parent) {
			switch(this) {
				case OptionType.FLAG:
					return new FlagOption(parent);
				case OptionType.MULTIPLE_CHOICE:
					return new MultipleChoiceOption(parent);
				case OptionType.STRING:
					return new StringOption(parent);
				case OptionType.INTEGER:
					return new IntegerOption(parent);
				case OptionType.DOUBLE:
					return new DoubleOption(parent);
				case OptionType.GROUPING:
					return new OptionGrouping(parent);
				default:
					break;
			}
			return null;
		}
		public string name() {
			ensure_option_type_names();
			int index=(int)this;
			if (index == 0)
				return "";
			if (index > option_type_names.length)
				return "";
			return option_type_names[index - 1];
		}
		public static unowned string[] get_names() {
			ensure_option_type_names();
			return option_type_names;
		}
		
		public static Option? create_option_from_name(string name, OptionSet parent) {
			ensure_option_type_names();
			for(int index=0;index<option_type_names.length;index++) {
				if (name == option_type_names[index])
					return ((OptionType)index + 1).create_option(parent);
			}
			warning("No OptionType found for name '%s'.", name);
			return null;
		}
	}
	static string[] option_type_names;
	static void ensure_option_type_names() {
		if (option_type_names != null)
			return;
		option_type_names = {
			"Flag",			
			"Multiple Choice",
			"String",
			"Integer",
			"Double",
			"Grouping"
		};	
	}
}
