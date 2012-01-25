using Fields;
using Menus.Fields;
using Data.GameList;

namespace Menus.Concrete
{
	public class GameMenu : Menu  
	{	
		GameItem game;
		public GameMenu(GameItem game) {
			base("Game: " + game.full_name);
			this.game = game;
			ensure_items();		
		}
		
		public override bool do_cancel() {
			return true;
		}
	
		public override bool do_save() {
			return true;
		}
				
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new RunGameItem(game));
			if (game.parent != null)
				items.add(new GameFolderMenu(game.parent));
			items.add(new MenuItem.cancel_item("Return"));			
		}
		
		class RunGameItem : MenuItem {
			GameItem game;
			public RunGameItem(GameItem game) {
				base("Run");				
				this.game = game;
			}
			public override void activate(MenuSelector selector) {
				selector.menu.message("Running...");
				game.run();
				selector.menu.message("");
			}
		}
	}

}
