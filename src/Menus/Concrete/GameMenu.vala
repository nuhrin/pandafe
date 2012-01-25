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
		protected override void populate_items(Gee.List<MenuItem> items) { 
			items.add(new MenuItem.custom("Run", null, "Running...", () => {
				game.run();
			}));
			if (game.parent != null) {
				var menu = new GameFolderMenu(game.parent);
				menu.add_item(new MenuItem.cancel_item("Return"));
				items.add(menu);
			}
		}		
	}

}
