using Gee;
using Fields;
using Menus.Fields;
using Data;

namespace Menus.Concrete
{
	public class ChangeViewMenu : Menu
	{
		Platform? current_platform;
		uint _initial_selection_index;
		public ChangeViewMenu(GameBrowserViewData? current_view, Platform? current_platform) {
			base("Change View");
			this.selected_view = current_view;
			this.current_platform = current_platform;
		}
		
		public GameBrowserViewData? selected_view { get; private set; }
		
		public override uint initial_selection_index() { return _initial_selection_index; }
		public override string? initial_help() { return "Select a new view..."; }
		
		protected override void populate_items(Gee.List<MenuItem> items) {
			add_menu_item(GameBrowserViewType.ALL_GAMES, items);
			add_menu_item(GameBrowserViewType.FAVORITES, items, (Data.favorites().is_empty() == false));
			var games_run_list_has_data = (Data.games_run_list_is_empty() == false);
			add_menu_item(GameBrowserViewType.MOST_PLAYED, items, games_run_list_has_data);
			add_menu_item(GameBrowserViewType.MOST_RECENT, items, games_run_list_has_data);
			add_menu_item(GameBrowserViewType.PLATFORM, items, (current_platform != null));
			add_menu_item(GameBrowserViewType.PLATFORM_LIST, items);
			add_menu_item(GameBrowserViewType.PLATFORM_FOLDER, items);
		}
		void add_menu_item(GameBrowserViewType view_type, Gee.List<MenuItem> items, bool enabled=true) {
			if (enabled && selected_view != null && selected_view.view_type == view_type)
				_initial_selection_index = items.size;
			var item = new ViewMenuItem(new GameBrowserViewData(view_type));
			item.enabled = enabled; 
			items.add(item);
		}
		
		class ViewMenuItem : MenuItem
		{
			GameBrowserViewData view;
			public ViewMenuItem(GameBrowserViewData view) {
				base.with_action(MenuItemActionType.SAVE, view.name, view.help);
				this.view = view;
			}
			public override void activate(MenuSelector selector) { 
				var menu = selector.menu as ChangeViewMenu;
				if (menu != null)
					menu.selected_view = view;
			}
		}
	}
}
