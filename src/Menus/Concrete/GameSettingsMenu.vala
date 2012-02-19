using Gee;
using Catapult;
using Fields;
using Menus.Fields;
using Data.GameList;
using Data.Options;
using Data.Programs;

namespace Menus.Concrete
{
	public class GameSettingsMenu : Menu  
	{	
		GameItem game;
		GameSettings game_settings;
		GameProgramSelectionField program_field;
		ClockSpeedField clockspeed_field;
		HashMap<Option,MenuItemField> field_hash;
		
		public GameSettingsMenu(GameItem game) {
			base("Settings: " + game.full_name);
			this.game = game;
			game_settings = Data.get_game_settings(game) ?? new GameSettings();
			var platform = game.platform();
			//var valid_programs = new Enumerable<Program>(platform.programs)
			//	.where(p=>p.get_app() != null);
			program = (game_settings.selected_program_id != null)
				? platform.get_program(game_settings.selected_program_id) ?? platform.default_program
				: platform.default_program;			
			program_field = new GameProgramSelectionField("program", "Program", null, platform.programs, program);
			program_field.changed.connect(()=> {
				program = program_field.selected_program;
				program_changed = true;
				refresh(0);
			});			
		}
		public Program? program { get; private set; }
		public bool program_changed { get; private set; }
				
		protected override void do_refresh(uint select_index) {
			clear_items();
			ensure_items();
		}
		protected override void populate_items(Gee.List<MenuItem> items) {
			items.add(program_field);
			if (program != null) {
				var settings = new ProgramSettings();
				settings.merge_override(program.default_settings);
				if (game_settings.program_settings.has_key(program.app_id))
					settings.merge_override(game_settings.program_settings[program.app_id]);
				field_hash = new HashMap<Option,MenuItemField>();
				foreach(var option in program.options) {
					var grouping = option as OptionGrouping;
					if (grouping != null) {
						var field = grouping.get_grouping_field(program.name, settings);
						field_hash[option] = field;
						items.add(field);
						continue;
					}
					string? setting = null;
					if (settings.has_key(option.setting_name) == true)
						setting = settings[option.setting_name];
					var field = option.get_setting_field(setting);
					field_hash[option] = field;
					items.add(field);
				}
				clockspeed_field = new ClockSpeedField("clockspeed", "Clockspeed", null, settings.clockspeed, 150, 1000, 5);
				items.add(clockspeed_field);				
			} else {
				field_hash = null;
			}			
			items.add(new MenuItem.cancel_item());
			items.add(new MenuItem.save_item());
		}
		protected override bool do_save() {
			game_settings.selected_program_id = (program != null) ? program.app_id : null;
				
			if (program != null) {
				var settings = new ProgramSettings();
				foreach(var option in program.options) {
					var field = field_hash[option];
					var grouping_field = field as OptionGroupingField;
					if (grouping_field != null)
						grouping_field.populate_settings_from_fields(settings);
					else
						settings[option.setting_name] = option.get_setting_value_from_field(field);
				}
				settings.clockspeed = clockspeed_field.value;
				game_settings.program_settings[program.app_id] = settings;			
			}
			
			Data.save_game_settings(game_settings, game);		
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
