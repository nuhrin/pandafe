/* GameSettingsMenu.vala
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
using Fields;
using Menus.Fields;
using Data.GameList;
using Data.Options;
using Data.Platforms;
using Data.Programs;

namespace Menus.Concrete
{
	public class GameSettingsMenu : Menu  
	{	
		string game_id;
		string game_name;
		Platform platform;
		RomPlatform rom_platform;
		GameSettings game_settings;
		GameProgramSelectionField? program_field;
		ClockSpeedField clockspeed_field;
		HashMap<Option,MenuItemField> field_hash;
		
		public GameSettingsMenu(GameItem game) {
			var platform = game.platform;			
			this.custom(game.id, game.full_name, platform, Data.get_game_settings(game) ?? new GameSettings() { platform = platform.id });
		}
		public GameSettingsMenu.custom(string game_id, string game_name, Platform platform, GameSettings settings) {
			base("Game Settings: " + game_name);
			this.game_id = game_id;
			this.game_name = game_name;
			game_settings = settings;
			this.platform = platform;
			rom_platform = platform as RomPlatform;
			program = platform.get_program(game_settings.selected_program_id);						
		}
		public Program? program { get; private set; }
		public bool program_changed { get; private set; }
		
		protected override void populate_items(Gee.List<MenuItem> items) {
			if (rom_platform != null) {
				program_field = new GameProgramSelectionField("program", "Program", "Change the program to use for this game", rom_platform.programs, program);
				field_connect(program_field, (f)=> f.changed.connect(()=> {
					program = program_field.selected_program;
					program_changed = true;
					refresh(0);
				}));
				if (rom_platform.programs.size < 2)
					program_field.enabled = false;
				items.add(program_field);
			}
			if (program != null) {
				var default_settings = new ProgramSettings();
				default_settings.merge_override(program.default_settings);
				var settings = new ProgramSettings();
				settings.merge_override(default_settings);
				if (game_settings.program_settings.has_key(program.app_id))
					settings.merge_override(game_settings.program_settings[program.app_id]);
				field_hash = new HashMap<Option,MenuItemField>();
				foreach(var option in program.options) {
					var grouping = option as OptionGrouping;
					if (grouping != null) {
						var field = grouping.get_grouping_field(settings, default_settings, game_name);
						field_hash[option] = field;
						items.add(field);
						continue;
					}
					string? setting = null;
					if (settings.has_key(option.setting_name) == true)
						setting = settings[option.setting_name];
					var field = option.get_setting_field(setting);
					if (option.locked == true)
						continue;
					field_hash[option] = field;
					items.add(field);
				}
				clockspeed_field = new ClockSpeedField("clockspeed", "Clockspeed", null, settings.clockspeed, 150, 1000, 5);
				items.add(clockspeed_field);
			} else {
				field_hash = null;
			}
			items.add(new MenuItemSeparator());
			var reset_index = items.size;
			items.add(new MenuItem.custom("Reset", "Reset settings to defaults", "", () => {
				if (program != null && game_settings.program_settings.has_key(program.app_id) == true)
					game_settings.program_settings.unset(program.app_id);				
				refresh(reset_index);
			}));
			items.add(new MenuItem.cancel_item());
			items.add(new MenuItem.save_item());
		}
		protected override void cleanup() {
			field_hash = null;
			program_field = null;			
			clockspeed_field = null;
		}
		protected override bool do_save() {
			game_settings.selected_program_id = (program != null) ? program.app_id : null;
				
			if (program != null) {
				var settings = new ProgramSettings();
				foreach(var option in program.options) {
					if (option.locked == true)
						continue;
					var field = field_hash[option];
					var grouping_field = field as OptionGroupingField;
					if (grouping_field != null)
						grouping_field.populate_settings_from_fields(settings);
					else {
						settings[option.setting_name] = option.get_setting_value_from_field(field);
					}
				}
				settings.clockspeed = clockspeed_field.value;
				game_settings.program_settings[program.app_id] = settings;			
			}
			
			Data.Provider.instance().save_game_settings(game_settings, game_id);
			return true;
		}
		
		class GameProgramSelectionField : ProgramSelectionField
		{
			public GameProgramSelectionField(string id, string name, string? help=null, Iterable<Program>? programs=null, Program? value) {
				base(id, name, help, programs, value);
			}
			public override int get_minimum_menu_value_text_length() {
				var program = get_program();
				return (program != null) ? program.name.length : 0;
			}
		}
				
	}

}
