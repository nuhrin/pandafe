using Gee;
using Catapult;
using Data.Platforms;
using Data.Programs;

namespace Data.GameList
{
	public class ProgramGameList : GameListProvider
	{
		string root_folder_name;
		public ProgramGameList(ProgramPlatform platform) {
			base(platform);
			program_platform = platform;
			if (platform.program != null) {
				root_folder_name = platform.program.name;				
			} else {
				root_folder_name = "unknown-program";
			}
		}
		public weak ProgramPlatform program_platform { get; private set; }

		public override SpawningResult run_game(GameItem game) {
			var game_settings = Data.get_game_settings(game);
			
			var program = program_platform.program;
			if (program == null)				
				return new SpawningResult.error("No program found to run '%s'.".printf(game.name));			
			
			ProgramSettings? settings = null;
			if (game_settings != null && game_settings.program_settings.has_key(program.app_id) == true)
				settings = game_settings.program_settings[program.app_id];
			
			return Spawning.spawn_program(program, true, settings, game.id);
		}
		public override Program? get_program_for_game(GameItem game) {
			return program_platform.program;
		}
		
		public override string get_unique_name(IGameListNode node) { return node.id; }
		
		protected override bool get_children(GameFolder folder, out ArrayList<GameFolder> child_folders, out ArrayList<GameItem> child_games) {
			child_folders = null;
			child_games = null;
			if (program_platform.program == null) 
				return false;
			var app = program_platform.program.get_app();
			if (app == null)
				return false;
				
			// mount pnd
			var mountset = Data.pnd_mountset();
			bool is_new_mount = (mountset.is_mounted(app.package_id) == false && 
								 mountset.mount(app.id, app.package_id) == true);
			var mounted_path = mountset.get_mounted_path(app.package_id);
			if (mounted_path == null && is_new_mount == true) {
				mountset.unmount(app.package_id);
				return false;
			}
	
			// run get games script and unmount pnd if appropriate
			var result = Spawning.spawn_program(program_platform.program, false, null, null, ProgramPlatform.GET_GAMES_SCRIPT_NAME, program_platform.get_games_script);
			if (is_new_mount)
				mountset.unmount(app.package_id);
			
			// show any error
			var successful = (result.success == true || (result.exit_status != 0 && program_platform.program.expected_exit_code == result.exit_status));
			if (successful == false) {
				result.show_result_dialog("Error running Get Games script for " + program_platform.program.name);
				return false;
			}
			
			// parse output of script into expected sequence node
			Yaml.SequenceNode sequence = null;
			try {
				var sb = new StringBuilder();
				sb.append("---\n");
				sb.append((result.standard_output ?? "").strip());
				var reader = new Yaml.DocumentReader.from_string(sb.str);
				sequence = reader.read_document().root as Yaml.SequenceNode;
			} catch(Error e) {
				warning("Error parsing get-games script output: %s", e.message);
			}
			if (sequence == null)
				return false;
			
			// parse game items from sequence
			var parser = new Yaml.NodeParser();				
			var parsed_games = new ArrayList<GameItem>();
			foreach(var game_node in sequence.items()) {
				GameItem? parsed_game = parser.parse<GameItem?>(game_node, null);
				if (parsed_game != null) {
					GameItem.set_provider(parsed_game, this);
					GameItem.set_parent(parsed_game, folder);
					parsed_games.add(parsed_game);
				}
			}			
			if (parsed_games.size > 0) {
				child_games = parsed_games;
				return true;
			}
			
			return false;						
		}
		protected override GameFolder create_root_folder() { return new GameFolder.root(root_folder_name, this, ""); }		
				
	}
}
