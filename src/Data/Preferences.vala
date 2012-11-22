using Gee;
using Catapult;
using Fields;
using Menus;
using Menus.Fields;

namespace Data
{
	public class Preferences : Entity, MenuObject
	{		
		internal const string ENTITY_ID = "preferences";		

		public GameBrowserAppearance appearance { get; set; }
		public string? default_rom_path { get; set; }
		
		// yaml
		protected override string generate_id() { return ENTITY_ID; }

		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			if (appearance == null)
				appearance = new GameBrowserAppearance.default();
			
			return base.build_yaml_node(builder);
		}
		protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			base.apply_yaml_node(node, parser);
			if (appearance == null)
				appearance = new GameBrowserAppearance.default();
		}
		
		// menu
		protected void build_menu(MenuBuilder builder) {
			appearance_field = new GameBrowserAppearanceField("appearance", "Appearance", "Configure font and colors.", "Game Browser Appearance", appearance, new Data.GameBrowserAppearance.default());
			builder.add_field(appearance_field);
			var default_rom_path_field = builder.add_folder("default_rom_path", "Default Rom Path", "Used as starting path when selecting platform roms for the first time.", default_rom_path);
			default_rom_path_field.changed.connect(() => refreshed(1));			
		}
		protected bool save_object(Menus.Menu menu) {
			Data.save_preferences();
			if (appearance_field.has_changes() == true)
				@interface.game_browser_ui.set_appearance(appearance);
			return true;
		}		
		protected void release_fields() {
			appearance_field = null;
		}
		GameBrowserAppearanceField appearance_field;
	}
}
