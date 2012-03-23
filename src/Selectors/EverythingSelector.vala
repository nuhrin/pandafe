using Gee;
using SDL;
using SDLTTF;
using Catapult;
using Data;
using Data.GameList;

public class EverythingSelector : Selector {

	GameBrowserViewData view;
	public EverythingSelector(string id, int16 xpos, int16 ypos, GameBrowserViewData? view) {
		base(id, xpos, ypos);		
		this.view = view ?? new GameBrowserViewData(GameBrowserViewType.ALL_GAMES);
		Data.favorites().changed.connect(() => favorites_changed());
	}

	Gee.List<GameItem> items {
		get {
			if (_items == null) {
				loading();
				_items = get_view_games(view);
				_items.sort();
			}
			return _items;
		}
	}
	Gee.List<GameItem> _items;
	
	public unowned string view_name { get { return view.name; } }
	
	public void change_view(GameBrowserViewData view) {
		if (this.view.equals(view) == true)
			return;
		this.view = view;
		rebuild();
	}
	void favorites_changed() {
		if (view.view_type == GameBrowserViewType.FAVORITES)
			rebuild();
	}

	public GameItem? selected_game() {
		if (selected_index < 0)
			return null;
		return items[selected_index];
	}
	
	protected override void rebuild_items(int selection_index) {
		var node = (selection_index != -1) ? items[selection_index] : null;
		var previous_selection_id = (node != null) ? node.unique_id() : null;
		_items = null;
		int new_index = -1;
		if (previous_selection_id != null) {
			for(int index=0;index<items.size;index++) {
				var item = items[index];
				if (item.unique_id() == previous_selection_id) {
					new_index = index;
					break;
				}
			}
		}
		if (new_index != -1)
			select_item(new_index, false);
	}
	protected override int get_itemcount() { return items.size; }
	protected override string get_item_name(int index) {
		return items[index].name;
	}
	protected override string get_item_full_name(int index) {
		return items[index].full_name;
	}
	
	Gee.List<GameItem> get_view_games(GameBrowserViewData view) {
		var games = new ArrayList<GameItem>();
		var platforms = Enumerable.empty<Platform>();
		switch (view.view_type) {
			case GameBrowserViewType.FAVORITES:
			case GameBrowserViewType.ALL_GAMES:
				var folder_data = Data.platforms().get_platform_folder_data();
				platforms = (folder_data.folders.size > 0)
					? folder_data.get_all_platforms()
					: Data.platforms().get_all_platforms();
				break;
			case GameBrowserViewType.PLATFORM_FOLDER:
				if (view.platform_folder != null)
					platforms = view.platform_folder.get_all_platforms();
				break;
			default:
				break;
		}
		
		foreach(var platform in platforms) {
			var platform_games = platform.get_root_folder().all_games();
			if (view.view_type == GameBrowserViewType.FAVORITES)
				platform_games = platform_games.where(g=>g.is_favorite == true);
			games.add_all(platform_games.to_list());
		}	
		return games;
	}
}
